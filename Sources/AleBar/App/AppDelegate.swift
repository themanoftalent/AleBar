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
        
        print("AleBar launched successfully. Dual status items active in menu bar.")
        
        // Show Settings on first launch so user sees the instructions and setup
        let hasLaunched = UserDefaults.standard.bool(forKey: "AleBar_HasLaunchedBefore")
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "AleBar_HasLaunchedBefore")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                SettingsWindowController.shared.show()
            }
        }
    }
    
    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindowController.shared.show()
        return true
    }
    
    private func setupStatusItem() {
        let statusController = StatusItemController.shared
        statusController.setup()
    }
    
    private func setupEventBridges() {
        AppState.shared.onToggleAleBar = { isVisible in
            if isVisible {
                StatusItemController.shared.expand()
            } else {
                StatusItemController.shared.collapse()
            }
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
        
        TriggersEngine.shared.onTriggerFired = { rule in
            StatusItemController.shared.expand()
            if rule.revealSeconds > 0 {
                TriggersEngine.shared.scheduleAutoHide(after: rule.revealSeconds) {
                    StatusItemController.shared.collapse()
                }
            }
        }
    }
    
    private func setupHotkeys() {
        let hotkeys = HotkeyManager.shared
        hotkeys.onToggleBar = {
            StatusItemController.shared.toggle()
        }
        hotkeys.onOpenCommandBar = {
            AppState.shared.toggleCommandBar()
        }
        hotkeys.onOpenSettings = {
            SettingsWindowController.shared.show()
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
