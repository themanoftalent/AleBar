import Foundation
import AppKit
import SwiftUI

public final class CommandBarWindowController: NSWindowController {
    public static let shared = CommandBarWindowController()
    
    private init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 380),
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
        guard let panel = window as? NSPanel,
              let screen = NSScreen.main else { return }
        
        let screenRect = screen.frame
        let fittingSize = NSSize(width: 540, height: 360)
        let x = (screenRect.width - fittingSize.width) / 2
        let y = screenRect.maxY - fittingSize.height - 140
        
        panel.setFrame(NSRect(x: x, y: y, width: fittingSize.width, height: fittingSize.height), display: true)
        panel.alphaValue = 0.0
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            panel.animator().alphaValue = 1.0
        }
    }
    
    public func hide() {
        guard let panel = window as? NSPanel else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.12
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            Task { @MainActor in
                panel.orderOut(nil)
            }
        })
    }
}
