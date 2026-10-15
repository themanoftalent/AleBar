import Foundation
import AppKit
import SwiftUI

public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 740, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "AleBar Settings"
        window.titlebarAppearsTransparent = false
        window.toolbarStyle = .unified
        
        let hostingView = NSHostingView(rootView: SettingsView())
        window.contentView = hostingView
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show() {
        guard let w = window else { return }
        w.center()
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
