import Foundation
import AppKit
import SwiftUI

public final class AleBarWindowController: NSWindowController {
    public static let shared = AleBarWindowController()
    
    private var trackingArea: NSTrackingArea?
    
    private init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 60),
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
        
        let hostingView = NSHostingView(rootView: AleBarView())
        panel.contentView = hostingView
        
        super.init(window: panel)
        
        setupMouseTracking(for: panel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMouseTracking(for panel: NSPanel) {
        guard let view = panel.contentView else { return }
        let area = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(area)
        self.trackingArea = area
    }
    
    public func show() {
        guard let panel = window as? NSPanel else { return }
        positionWindow()
        panel.alphaValue = 0.0
        panel.orderFrontRegardless()
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1.0
        }
    }
    
    public func hide() {
        guard let panel = window as? NSPanel else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            Task { @MainActor in
                panel.orderOut(nil)
            }
        })
    }
    
    public func positionWindow() {
        guard let panel = window,
              let screen = NSScreen.main else { return }
        
        panel.contentView?.layoutSubtreeIfNeeded()
        let fittingSize = panel.contentView?.fittingSize ?? NSSize(width: 480, height: 64)
        let panelWidth = max(fittingSize.width, 460)
        let panelHeight = max(fittingSize.height, 64)
        
        let screenRect = screen.frame
        let visibleRect = screen.visibleFrame
        
        // Menu bar height calculation
        let menuBarHeight = max(screenRect.maxY - visibleRect.maxY, 26)
        let barY = screenRect.maxY - menuBarHeight - panelHeight - 6
        
        var barX: CGFloat
        if AppState.shared.notchAvoidanceEnabled {
            // Center smoothly below the notch
            barX = (screenRect.width - panelWidth) / 2
        } else if let statusFrame = StatusItemController.shared.statusItemFrame {
            // Align near status item
            barX = statusFrame.maxX - panelWidth
            barX = max(16, min(barX, screenRect.maxX - panelWidth - 16))
        } else {
            barX = (screenRect.width - panelWidth) / 2
        }
        
        panel.setFrame(NSRect(x: barX, y: barY, width: panelWidth, height: panelHeight), display: true)
    }
    
    public override func mouseExited(with event: NSEvent) {
        // When cursor leaves the bar, trigger auto-hide if enabled
        Task { @MainActor in
            if AppState.shared.autoHideEnabled && AppState.shared.isAleBarVisible {
                TriggersEngine.shared.scheduleAutoHide(after: 1.5) {
                    AppState.shared.hideAleBar()
                }
            }
        }
    }
    
    public override func mouseEntered(with event: NSEvent) {
        TriggersEngine.shared.cancelAutoHide()
    }
}
