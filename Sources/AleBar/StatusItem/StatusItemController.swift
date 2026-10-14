import Foundation
import AppKit

@MainActor
public final class StatusItemController: NSObject {
    public static let shared = StatusItemController()
    
    private var statusItem: NSStatusItem?
    private var trackingArea: NSTrackingArea?
    private var hoverTimer: Timer?
    
    public var onLeftClick: (() -> Void)?
    public var onRightClick: (() -> Void)?
    public var onHoverReveal: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    public func setup() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem = item
        
        if let button = item.button {
            button.target = self
            button.action = #selector(handleStatusItemClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            // Setup tracking area for hover reveal
            setupHoverTracking(for: button)
            
            updateIcon()
        }
    }
    
    public var statusItemFrame: NSRect? {
        guard let button = statusItem?.button,
              let window = button.window else {
            return nil
        }
        return window.convertToScreen(button.frame)
    }
    
    public func updateIcon() {
        guard let button = self.statusItem?.button else { return }
        let style = AppState.shared.statusIconStyle
        let isExpanded = AppState.shared.isAleBarVisible
        button.image = style.iconImage(isExpanded: isExpanded)
        button.imagePosition = .imageOnly
        button.toolTip = "AleBar - Click to toggle hidden items (Right-click for options)"
    }
    
    private func setupHoverTracking(for button: NSStatusBarButton) {
        let area = NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        button.addTrackingArea(area)
        self.trackingArea = area
    }
    
    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showContextMenu(from: sender)
        } else {
            onLeftClick?()
            updateIcon()
        }
    }
    
    public func showContextMenu(from sender: NSStatusBarButton) {
        let menu = NSMenu(title: "AleBar Quick Actions")
        
        let toggleTitle = AppState.shared.isAleBarVisible ? "Hide AleBar" : "Show AleBar"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggleBar), keyEquivalent: "b")
        toggleItem.keyEquivalentModifierMask = [.command, .option]
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        let searchItem = NSMenuItem(title: "Quick Search / Command Bar...", action: #selector(menuOpenSearch), keyEquivalent: " ")
        searchItem.keyEquivalentModifierMask = [.command, .option]
        searchItem.target = self
        menu.addItem(searchItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quick Theme Preset Submenu
        let themeSubmenu = NSMenu(title: "Menu Bar Styling")
        for preset in ThemePreset.allCases {
            let item = NSMenuItem(title: preset.rawValue, action: #selector(menuSelectTheme(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = preset
            if AppState.shared.theme.preset == preset {
                item.state = .on
            }
            themeSubmenu.addItem(item)
        }
        let themeMenuItem = NSMenuItem(title: "Menu Bar Styling", action: nil, keyEquivalent: "")
        themeMenuItem.submenu = themeSubmenu
        menu.addItem(themeMenuItem)
        
        // Quick Icon Submenu
        let iconSubmenu = NSMenu(title: "Menu Bar Icon")
        for iconStyle in StatusIconStyle.allCases {
            let item = NSMenuItem(title: iconStyle.rawValue, action: #selector(menuSelectIconStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = iconStyle
            if AppState.shared.statusIconStyle == iconStyle {
                item.state = .on
            }
            iconSubmenu.addItem(item)
        }
        let iconMenuItem = NSMenuItem(title: "Menu Bar Icon Style", action: nil, keyEquivalent: "")
        iconMenuItem.submenu = iconSubmenu
        menu.addItem(iconMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let prefItem = NSMenuItem(title: "Settings & Preferences...", action: #selector(menuOpenSettings), keyEquivalent: ",")
        prefItem.target = self
        menu.addItem(prefItem)
        
        let refreshItem = NSMenuItem(title: "Scan Menu Bar Items", action: #selector(menuRefreshItems), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit AleBar", action: #selector(menuQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        sender.performClick(nil)
        statusItem?.menu = nil // Restore button click handling
    }
    
    @objc private func menuToggleBar() {
        AppState.shared.toggleAleBar()
        self.updateIcon()
    }
    
    @objc private func menuOpenSearch() {
        AppState.shared.showCommandBar()
    }
    
    @objc private func menuSelectTheme(_ sender: NSMenuItem) {
        guard let preset = sender.representedObject as? ThemePreset else { return }
        AppState.shared.applyThemePreset(preset)
    }
    
    @objc private func menuSelectIconStyle(_ sender: NSMenuItem) {
        guard let style = sender.representedObject as? StatusIconStyle else { return }
        AppState.shared.setStatusIcon(style)
        self.updateIcon()
    }
    
    @objc private func menuOpenSettings() {
        SettingsWindowController.shared.show()
    }
    
    @objc private func menuRefreshItems() {
        AppState.shared.refreshItems()
    }
    
    @objc private func menuQuit() {
        NSApp.terminate(nil)
    }
    
    @objc public func mouseEntered(with event: NSEvent) {
        guard AppState.shared.hoverRevealEnabled else { return }
        hoverTimer?.invalidate()
        let delay = AppState.shared.hoverRevealDelay
        hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onHoverReveal?()
                self?.updateIcon()
            }
        }
    }
    
    @objc public func mouseExited(with event: NSEvent) {
        hoverTimer?.invalidate()
        hoverTimer = nil
    }
}
