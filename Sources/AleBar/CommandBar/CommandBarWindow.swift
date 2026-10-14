import Foundation
import AppKit
import SwiftUI

public final class KeyablePanel: NSPanel {
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
}

public final class CommandBarWindowController: NSWindowController {
    public static let shared = CommandBarWindowController()
    
    private var localKeyMonitor: Any?
    
    private init() {
        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 380),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.animationBehavior = .utilityWindow
        
        let hostingView = NSHostingView(rootView: CommandBarView())
        panel.contentView = hostingView
        
        super.init(window: panel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show() {
        guard let panel = window as? KeyablePanel,
              let screen = NSScreen.main else { return }
        
        let screenRect = screen.frame
        let fittingSize = NSSize(width: 560, height: 380)
        let x = (screenRect.width - fittingSize.width) / 2
        let y = screenRect.maxY - fittingSize.height - 140
        
        panel.setFrame(NSRect(x: x, y: y, width: fittingSize.width, height: fittingSize.height), display: true)
        panel.alphaValue = 0.0
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        setupKeyMonitor()
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.16
            panel.animator().alphaValue = 1.0
        }
    }
    
    public func hide() {
        removeKeyMonitor()
        guard let panel = window as? KeyablePanel else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.12
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            Task { @MainActor in
                panel.orderOut(nil)
            }
        })
    }
    
    private func setupKeyMonitor() {
        removeKeyMonitor()
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard self != nil else { return event }
            
            // Escape (53) -> close
            if event.keyCode == 53 {
                Task { @MainActor in
                    AppState.shared.hideCommandBar()
                }
                return nil
            }
            
            // Arrow Down (125)
            if event.keyCode == 125 {
                Task { @MainActor in
                    let maxIdx = max(0, AppState.shared.items.count - 1)
                    AppState.shared.commandBarSelectedIndex = min(AppState.shared.commandBarSelectedIndex + 1, maxIdx)
                }
                return nil
            }
            
            // Arrow Up (126)
            if event.keyCode == 126 {
                Task { @MainActor in
                    AppState.shared.commandBarSelectedIndex = max(AppState.shared.commandBarSelectedIndex - 1, 0)
                }
                return nil
            }
            
            return event
        }
    }
    
    private func removeKeyMonitor() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }
}
