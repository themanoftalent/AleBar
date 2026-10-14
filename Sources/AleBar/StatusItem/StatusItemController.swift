import Foundation
import AppKit

@MainActor
public final class StatusItemController: NSObject {
    public static let shared = StatusItemController()
    
    private var toggleStatusItem: NSStatusItem?
    private var separatorStatusItem: NSStatusItem?
    private var hoverTimer: Timer?
    
    public var onLeftClick: (() -> Void)?
    public var onHoverReveal: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    public func setup() {
        // 1. Create the primary toggle item (placed to the right)
        let toggle = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.toggleStatusItem = toggle
        
        if let button = toggle.button {
            button.target = self
            button.action = #selector(handleToggleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            setupHoverTracking(for: button)
        }
        
        // 2. Create the separator delimiter item (inserted to the left of toggle)
        let separator = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.separatorStatusItem = separator
        
        if let sepButton = separator.button {
            sepButton.target = self
            sepButton.action = #selector(handleSeparatorClick(_:))
            sepButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            sepButton.image = createSeparatorImage()
            sepButton.toolTip = "AleBar Delimiter: ⌘-drag icons to the left of this separator to hide them when collapsed."
            setupHoverTracking(for: sepButton)
        }
        
        updateIcon()
        
        // Default to collapsed state on start so menu bar is clean
        collapse()
    }
    
    public var statusItemFrame: NSRect? {
        guard let button = toggleStatusItem?.button,
              let window = button.window else {
            return nil
        }
        return window.convertToScreen(button.frame)
    }
    
    // MARK: - Collapse & Expand Logic
    public func collapse() {
        guard let sep = separatorStatusItem,
              let toggle = toggleStatusItem else { return }
        
        let collapseLen = getCollapseLength()
        sep.length = collapseLen
        sep.button?.image = nil
        sep.button?.title = ""
        
        let style = AppState.shared.statusIconStyle
        toggle.button?.image = style.iconImage(isExpanded: false)
        toggle.button?.toolTip = "AleBar: Click to show hidden menu bar items (⌘⌥B)"
        
        AppState.shared.isAleBarVisible = false
        if AppState.shared.hidingMode == .both || AppState.shared.hidingMode == .floatingShelf {
            AleBarWindowController.shared.hide()
        }
    }
    
    public func expand() {
        guard let sep = separatorStatusItem,
              let toggle = toggleStatusItem else { return }
        
        sep.length = NSStatusItem.variableLength
        sep.button?.image = createSeparatorImage()
        sep.button?.toolTip = "AleBar Delimiter: ⌘-drag icons to the left of this separator to hide them."
        
        let style = AppState.shared.statusIconStyle
        toggle.button?.image = style.iconImage(isExpanded: true)
        toggle.button?.toolTip = "AleBar: Click to hide menu bar items (⌘⌥B)"
        
        AppState.shared.isAleBarVisible = true
        
        if AppState.shared.hidingMode == .both || AppState.shared.hidingMode == .floatingShelf {
            AleBarWindowController.shared.show()
        }
        
        if AppState.shared.autoHideEnabled && AppState.shared.autoHideDelay > 0 {
            TriggersEngine.shared.scheduleAutoHide(after: AppState.shared.autoHideDelay) { [weak self] in
                self?.collapse()
            }
        }
    }
    
    public func toggle() {
        if AppState.shared.isAleBarVisible {
            collapse()
        } else {
            expand()
        }
    }
    
    private func getCollapseLength() -> CGFloat {
        let screens = NSScreen.screens
        let maxWidth = screens.map { $0.frame.width }.max() ?? 1440
        return max(maxWidth + 400, 2200)
    }
    
    public func updateIcon() {
        guard let button = self.toggleStatusItem?.button else { return }
        let style = AppState.shared.statusIconStyle
        let isExpanded = AppState.shared.isAleBarVisible
        button.image = style.iconImage(isExpanded: isExpanded)
        button.imagePosition = .imageOnly
        button.toolTip = isExpanded ?
            "AleBar: Click to hide menu bar items (Right-click for options)" :
            "AleBar: Click to show hidden menu bar items (Right-click for options)"
    }
    
    private func createSeparatorImage() -> NSImage {
        let size = NSSize(width: 12, height: 22)
        let image = NSImage(size: size)
        image.lockFocus()
        
        let path = NSBezierPath(roundedRect: NSRect(x: 5, y: 3, width: 2, height: 16), xRadius: 1, yRadius: 1)
        NSColor.labelColor.withAlphaComponent(0.45).setFill()
        path.fill()
        
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
    
    private func setupHoverTracking(for button: NSStatusBarButton) {
        let area = NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        button.addTrackingArea(area)
    }
    
    @objc private func handleToggleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showContextMenu(from: sender)
        } else {
            toggle()
        }
    }
    
    @objc private func handleSeparatorClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            showContextMenu(from: sender)
        } else {
            toggle()
        }
    }
    
    public func showContextMenu(from sender: NSStatusBarButton) {
        let menu = NSMenu(title: "AleBar Quick Actions")
        
        let isExpanded = AppState.shared.isAleBarVisible
        let toggleTitle = isExpanded ? "Hide Menu Bar Items" : "Show Menu Bar Items"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggleBar), keyEquivalent: "b")
        toggleItem.keyEquivalentModifierMask = [.command, .option]
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        let searchItem = NSMenuItem(title: "Quick Search / Command Bar...", action: #selector(menuOpenSearch), keyEquivalent: " ")
        searchItem.keyEquivalentModifierMask = [.command, .option]
        searchItem.target = self
        menu.addItem(searchItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Hiding Mode Submenu
        let modeSubmenu = NSMenu(title: "Hiding Mode")
        for mode in HidingMode.allCases {
            let item = NSMenuItem(title: mode.rawValue, action: #selector(menuSelectHidingMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode
            if AppState.shared.hidingMode == mode {
                item.state = .on
            }
            modeSubmenu.addItem(item)
        }
        let modeMenuItem = NSMenuItem(title: "Operation Mode", action: nil, keyEquivalent: "")
        modeMenuItem.submenu = modeSubmenu
        menu.addItem(modeMenuItem)
        
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
        let iconSubmenu = NSMenu(title: "Menu Bar Icon Style")
        for iconStyle in StatusIconStyle.allCases {
            let item = NSMenuItem(title: iconStyle.rawValue, action: #selector(menuSelectIconStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = iconStyle
            if AppState.shared.statusIconStyle == iconStyle {
                item.state = .on
            }
            iconSubmenu.addItem(item)
        }
        let iconMenuItem = NSMenuItem(title: "Icon Style", action: nil, keyEquivalent: "")
        iconMenuItem.submenu = iconSubmenu
        menu.addItem(iconMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let prefItem = NSMenuItem(title: "Settings & Preferences...", action: #selector(menuOpenSettings), keyEquivalent: ",")
        prefItem.target = self
        menu.addItem(prefItem)
        
        let refreshItem = NSMenuItem(title: "Scan Running Items", action: #selector(menuRefreshItems), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit AleBar", action: #selector(menuQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        toggleStatusItem?.menu = menu
        sender.performClick(nil)
        toggleStatusItem?.menu = nil
    }
    
    @objc private func menuToggleBar() {
        toggle()
    }
    
    @objc private func menuOpenSearch() {
        AppState.shared.showCommandBar()
    }
    
    @objc private func menuSelectHidingMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? HidingMode else { return }
        AppState.shared.hidingMode = mode
        AppState.shared.saveSettings()
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
        guard AppState.shared.hoverRevealEnabled, !AppState.shared.isAleBarVisible else { return }
        hoverTimer?.invalidate()
        let delay = AppState.shared.hoverRevealDelay
        hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.expand()
            }
        }
    }
    
    @objc public func mouseExited(with event: NSEvent) {
        hoverTimer?.invalidate()
        hoverTimer = nil
    }
}
