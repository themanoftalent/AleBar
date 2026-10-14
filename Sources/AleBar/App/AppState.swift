import Foundation
import SwiftUI
import Combine

@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    // MARK: - Published Properties
    @Published public var items: [StatusItemModel] = []
    @Published public var groups: [ItemGroup] = []
    @Published public var theme: MenuBarTheme = .defaultTheme
    @Published public var statusIconStyle: StatusIconStyle = .aleMug
    @Published public var triggers: [TriggerRule] = TriggerRule.defaultRules
    
    // Presentation States
    @Published public var isAleBarVisible: Bool = false
    @Published public var isCommandBarVisible: Bool = false
    @Published public var hoverRevealEnabled: Bool = true
    @Published public var hoverRevealDelay: Double = 0.3
    @Published public var autoHideDelay: Double = 6.0
    @Published public var autoHideEnabled: Bool = true
    @Published public var topShelfEnabled: Bool = true
    @Published public var notchAvoidanceEnabled: Bool = true
    @Published public var showSearchInAleBar: Bool = true
    
    // UI Local State managed centrally
    @Published public var barShowAlwaysHidden: Bool = false
    @Published public var barHoveredItemId: String? = nil
    @Published public var commandBarQuery: String = ""
    @Published public var commandBarSelectedIndex: Int = 0
    @Published public var selectedSettingsTab: String = "General"
    @Published public var menuItemsFilterText: String = ""
    @Published public var menuItemsFilterSection: String = "All"
    
    // Live System Metrics
    @Published public var batteryLevel: Int = 100
    @Published public var isCharging: Bool = false
    @Published public var cpuUsage: Double = 12.0
    @Published public var memoryUsage: Double = 45.0
    
    // Callbacks for Window Controllers
    public var onToggleAleBar: ((Bool) -> Void)?
    public var onToggleCommandBar: ((Bool) -> Void)?
    public var onThemeChanged: ((MenuBarTheme) -> Void)?
    public var onStatusIconChanged: ((StatusIconStyle) -> Void)?
    
    private var statsTimer: Timer?
    
    private init() {
        loadSettings()
        refreshItems()
        setupStatsMonitoring()
        setupTriggers()
    }
    
    public func refreshItems() {
        let scanned = MenuBarDetector.shared.scanRunningItems()
        self.items = scanned
    }
    
    public func toggleAleBar() {
        isAleBarVisible.toggle()
        onToggleAleBar?(isAleBarVisible)
        
        if isAleBarVisible && autoHideEnabled && autoHideDelay > 0 {
            TriggersEngine.shared.scheduleAutoHide(after: autoHideDelay) { [weak self] in
                self?.hideAleBar()
            }
        } else {
            TriggersEngine.shared.cancelAutoHide()
        }
    }
    
    public func showAleBar() {
        if !isAleBarVisible {
            isAleBarVisible = true
            onToggleAleBar?(true)
            
            if autoHideEnabled && autoHideDelay > 0 {
                TriggersEngine.shared.scheduleAutoHide(after: autoHideDelay) { [weak self] in
                    self?.hideAleBar()
                }
            }
        }
    }
    
    public func hideAleBar() {
        if isAleBarVisible {
            isAleBarVisible = false
            onToggleAleBar?(false)
            TriggersEngine.shared.cancelAutoHide()
        }
    }
    
    public func toggleCommandBar() {
        isCommandBarVisible.toggle()
        onToggleCommandBar?(isCommandBarVisible)
    }
    
    public func showCommandBar() {
        isCommandBarVisible = true
        onToggleCommandBar?(true)
    }
    
    public func hideCommandBar() {
        isCommandBarVisible = false
        onToggleCommandBar?(false)
    }
    
    public func setItemSection(itemId: String, section: ItemSection) {
        if let idx = items.firstIndex(where: { $0.id == itemId }) {
            items[idx].section = section
            saveItems()
        }
    }
    
    public func setStatusIcon(_ style: StatusIconStyle) {
        self.statusIconStyle = style
        onStatusIconChanged?(style)
        saveSettings()
    }
    
    public func applyThemePreset(_ preset: ThemePreset) {
        switch preset {
        case .none:
            theme = .defaultTheme
        case .liquidGlass:
            theme = .liquidGlassTheme
        case .darkFrosted:
            theme = MenuBarTheme(
                isEnabled: true,
                preset: .darkFrosted,
                tintColorHex: "#0D1117",
                secondaryColorHex: "#161B22",
                hasGradient: true,
                opacity: 0.85,
                cornerRadius: 12.0,
                horizontalMargin: 8.0,
                verticalMargin: 3.0,
                heightInset: 2.0,
                borderWidth: 1.0,
                borderColorHex: "#30363D",
                hasShadow: true,
                shadowRadius: 10.0,
                shadowColorHex: "#000000",
                blurIntensity: 0.9,
                isVibrant: false
            )
        case .modernPill:
            theme = .modernPillTheme
        case .sunsetGlow:
            theme = .sunsetGlowTheme
        case .neonCyber:
            theme = .neonCyberTheme
        case .cleanWhite:
            theme = MenuBarTheme(
                isEnabled: true,
                preset: .cleanWhite,
                tintColorHex: "#F8FAFC",
                secondaryColorHex: "#FFFFFF",
                hasGradient: false,
                opacity: 0.6,
                cornerRadius: 14.0,
                horizontalMargin: 12.0,
                verticalMargin: 4.0,
                heightInset: 2.0,
                borderWidth: 1.0,
                borderColorHex: "#E2E8F0",
                hasShadow: true,
                shadowRadius: 6.0,
                shadowColorHex: "#94A3B8",
                blurIntensity: 0.85,
                isVibrant: true
            )
        }
        
        onThemeChanged?(theme)
        saveSettings()
    }
    
    public func updateTheme(_ newTheme: MenuBarTheme) {
        self.theme = newTheme
        onThemeChanged?(newTheme)
        saveSettings()
    }
    
    private func setupStatsMonitoring() {
        let (bat, charging) = SystemMonitor.shared.getBatteryInfo()
        self.batteryLevel = bat
        self.isCharging = charging
        
        let (cpu, ram) = SystemMonitor.shared.getSystemStats()
        self.cpuUsage = cpu
        self.memoryUsage = ram
        
        statsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let (b, c) = SystemMonitor.shared.getBatteryInfo()
                self.batteryLevel = b
                self.isCharging = c
                let (cpuLoad, ramLoad) = SystemMonitor.shared.getSystemStats()
                self.cpuUsage = cpuLoad
                self.memoryUsage = ramLoad
            }
        }
    }
    
    private func setupTriggers() {
        TriggersEngine.shared.updateRules(triggers)
        TriggersEngine.shared.onTriggerFired = { [weak self] rule in
            Task { @MainActor [weak self] in
                self?.showAleBar()
            }
        }
    }
    
    // MARK: - Persistence
    private let kThemeKey = "AleBar_Theme"
    private let kIconStyleKey = "AleBar_IconStyle"
    private let kAutoHideKey = "AleBar_AutoHideDelay"
    private let kHoverRevealKey = "AleBar_HoverReveal"
    private let kTopShelfKey = "AleBar_TopShelf"
    
    public func saveSettings() {
        if let themeData = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(themeData, forKey: kThemeKey)
        }
        UserDefaults.standard.set(statusIconStyle.rawValue, forKey: kIconStyleKey)
        UserDefaults.standard.set(autoHideDelay, forKey: kAutoHideKey)
        UserDefaults.standard.set(hoverRevealEnabled, forKey: kHoverRevealKey)
        UserDefaults.standard.set(topShelfEnabled, forKey: kTopShelfKey)
        saveItems()
    }
    
    public func saveItems() {
        MenuBarDetector.shared.saveItems(items)
    }
    
    public func loadSettings() {
        if let themeData = UserDefaults.standard.data(forKey: kThemeKey),
           let savedTheme = try? JSONDecoder().decode(MenuBarTheme.self, from: themeData) {
            self.theme = savedTheme
        }
        if let rawStyle = UserDefaults.standard.string(forKey: kIconStyleKey),
           let style = StatusIconStyle(rawValue: rawStyle) {
            self.statusIconStyle = style
        }
        if UserDefaults.standard.object(forKey: kAutoHideKey) != nil {
            self.autoHideDelay = UserDefaults.standard.double(forKey: kAutoHideKey)
        }
        if UserDefaults.standard.object(forKey: kHoverRevealKey) != nil {
            self.hoverRevealEnabled = UserDefaults.standard.bool(forKey: kHoverRevealKey)
        }
        if UserDefaults.standard.object(forKey: kTopShelfKey) != nil {
            self.topShelfEnabled = UserDefaults.standard.bool(forKey: kTopShelfKey)
        }
    }
}
