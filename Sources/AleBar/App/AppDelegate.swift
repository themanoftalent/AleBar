import Foundation
import AppKit

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static let shared = AppDelegate()
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as menu bar agent / accessory
        NSApplication.shared.setActivationPolicy(.accessory)
        
        setupStatusItem()
        setupEventBridges()
        setupHotkeys()
        setupStylingOverlay()
        
        print("AleBar launched successfully. Status item active in menu bar.")
    }
    
    private func setupStatusItem() {
        let statusController = StatusItemController.shared
        statusController.setup()
        
        statusController.onLeftClick = {
            AppState.shared.toggleAleBar()
        }
        
        statusController.onHoverReveal = {
            AppState.shared.showAleBar()
        }
    }
    
    private func setupEventBridges() {
        AppState.shared.onToggleAleBar = { isVisible in
            if isVisible {
                AleBarWindowController.shared.show()
            } else {
                AleBarWindowController.shared.hide()
            }
            StatusItemController.shared.updateIcon()
        }
        
        AppState.shared.onToggleCommandBar = { isVisible in
            if isVisible {
                CommandBarWindowController.shared.show()
            } else {
                CommandBarWindowController.shared.hide()
            }
        }
        
        AppState.shared.onThemeChanged = { theme in
            MenuBarOverlayWindowController.shared.applyTheme(theme)
        }
        
        AppState.shared.onStatusIconChanged = { _ in
            StatusItemController.shared.updateIcon()
        }
    }
    
    private func setupHotkeys() {
        let hotkeys = HotkeyManager.shared
        hotkeys.onToggleBar = {
            AppState.shared.toggleAleBar()
        }
        hotkeys.onOpenCommandBar = {
            AppState.shared.toggleCommandBar()
        }
        hotkeys.start()
    }
    
    private func setupStylingOverlay() {
        let theme = AppState.shared.theme
        MenuBarOverlayWindowController.shared.applyTheme(theme)
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.stop()
    }
}
