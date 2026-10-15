import Foundation
import AppKit
import SwiftUI

public final class MenuBarOverlayWindowController: NSWindowController {
    public static let shared = MenuBarOverlayWindowController()
    
    private init() {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        // Position directly behind menu items so they remain visible and sharp
        panel.level = NSWindow.Level(Int(CGWindowLevelForKey(.mainMenuWindow)) - 1)
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true // Critical: permits clicking through to native menu bar
        
        let hostingView = NSHostingView(rootView: MenuBarOverlayView())
        panel.contentView = hostingView
        
        super.init(window: panel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func screenParametersChanged() {
        updateFrame()
    }
    
    public func updateFrame() {
        guard let panel = window,
              let screen = NSScreen.main else { return }
        
        let screenRect = screen.frame
        let visibleRect = screen.visibleFrame
        let menuBarHeight = max(screenRect.maxY - visibleRect.maxY, 26.0)
        
        let overlayFrame = NSRect(
            x: screenRect.minX,
            y: screenRect.maxY - menuBarHeight,
            width: screenRect.width,
            height: menuBarHeight
        )
        panel.setFrame(overlayFrame, display: true)
    }
    
    public func applyTheme(_ theme: MenuBarTheme) {
        guard let panel = window else { return }
        if theme.isEnabled && theme.preset != .none {
            updateFrame()
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }
}
