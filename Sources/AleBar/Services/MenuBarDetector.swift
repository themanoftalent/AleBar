import Foundation
import AppKit

public final class MenuBarDetector: @unchecked Sendable {
    public static let shared = MenuBarDetector()
    
    private let userDefaultsKey = "AleBar_MenuItems_v1"
    
    // System status items mapping
    private let standardSystemItems: [StatusItemModel] = [
        StatusItemModel(id: "com.apple.controlcenter.battery", name: "Battery", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "battery.100", isSystemItem: true, section: .shown, orderIndex: 0),
        StatusItemModel(id: "com.apple.controlcenter.wifi", name: "Wi-Fi", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "wifi", isSystemItem: true, section: .shown, orderIndex: 1),
        StatusItemModel(id: "com.apple.controlcenter.bluetooth", name: "Bluetooth", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "dot.radiowaves.left.and.right", isSystemItem: true, section: .hidden, orderIndex: 2),
        StatusItemModel(id: "com.apple.controlcenter.sound", name: "Sound / Volume", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "speaker.wave.2.fill", isSystemItem: true, section: .shown, orderIndex: 3),
        StatusItemModel(id: "com.apple.controlcenter.airdrop", name: "AirDrop", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "airdrop", isSystemItem: true, section: .hidden, orderIndex: 4),
        StatusItemModel(id: "com.apple.controlcenter.display", name: "Display", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "display", isSystemItem: true, section: .hidden, orderIndex: 5),
        StatusItemModel(id: "com.apple.controlcenter.focus", name: "Focus / Do Not Disturb", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "moon.fill", isSystemItem: true, section: .hidden, orderIndex: 6),
        StatusItemModel(id: "com.apple.controlcenter.stageManager", name: "Stage Manager", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "rectangle.split.2x1", isSystemItem: true, section: .alwaysHidden, orderIndex: 7),
        StatusItemModel(id: "com.apple.controlcenter", name: "Control Center", bundleIdentifier: "com.apple.controlcenter", systemSymbol: "switch.2", isSystemItem: true, section: .shown, orderIndex: 8),
        StatusItemModel(id: "com.apple.Spotlight", name: "Spotlight Search", bundleIdentifier: "com.apple.Spotlight", systemSymbol: "magnifyingglass", isSystemItem: true, section: .shown, orderIndex: 9),
        StatusItemModel(id: "com.apple.Siri", name: "Siri", bundleIdentifier: "com.apple.Siri", systemSymbol: "waveform", isSystemItem: true, section: .alwaysHidden, orderIndex: 10),
        StatusItemModel(id: "com.apple.menuextra.clock", name: "Clock & Date", bundleIdentifier: "com.apple.menuextra.clock", systemSymbol: "clock", isSystemItem: true, section: .shown, orderIndex: 11)
    ]
    
    private init() {}
    
    public func loadSavedItems() -> [StatusItemModel]? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let items = try? JSONDecoder().decode([StatusItemModel].self, from: data) else {
            return nil
        }
        return items
    }
    
    public func saveItems(_ items: [StatusItemModel]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    public func scanRunningItems() -> [StatusItemModel] {
        let savedItems = loadSavedItems() ?? []
        var savedMap = [String: StatusItemModel]()
        for item in savedItems {
            savedMap[item.id] = item
        }
        
        var detectedList = [StatusItemModel]()
        
        // 1. Add standard system items
        for sys in standardSystemItems {
            if let existing = savedMap[sys.id] {
                var updated = existing
                updated.isRunning = true
                detectedList.append(updated)
            } else {
                detectedList.append(sys)
            }
        }
        
        // 2. Discover running third-party apps
        let runningApps = NSWorkspace.shared.runningApplications
        var order = detectedList.count
        
        for app in runningApps {
            guard let bundleId = app.bundleIdentifier,
                  let name = app.localizedName,
                  !bundleId.hasPrefix("com.apple.controlcenter"),
                  bundleId != "com.apple.Spotlight",
                  bundleId != "com.apple.Siri",
                  bundleId != "com.apple.finder",
                  bundleId != Bundle.main.bundleIdentifier else {
                continue
            }
            
            // Focus on accessory apps (menu bar apps) or regular active apps
            let isAccessory = (app.activationPolicy == .accessory)
            let isRegular = (app.activationPolicy == .regular)
            
            guard isAccessory || isRegular else { continue }
            
            let id = bundleId
            let iconSymbol = isAccessory ? "menubar.dock.rectangle" : "app.fill"
            
            if let existing = savedMap[id] {
                var updated = existing
                updated.processIdentifier = app.processIdentifier
                updated.isRunning = true
                detectedList.append(updated)
            } else {
                // If it's an accessory app, default to .hidden like AleBar does for newly detected helper apps
                let defaultSection: ItemSection = isAccessory ? .hidden : .shown
                let newItem = StatusItemModel(
                    id: id,
                    name: name,
                    bundleIdentifier: bundleId,
                    processIdentifier: app.processIdentifier,
                    systemSymbol: iconSymbol,
                    isSystemItem: false,
                    section: defaultSection,
                    orderIndex: order,
                    isRunning: true
                )
                detectedList.append(newItem)
                order += 1
            }
        }
        
        // Preserve any previously saved items that are not currently running
        for saved in savedItems {
            if !detectedList.contains(where: { $0.id == saved.id }) {
                var offline = saved
                offline.isRunning = false
                detectedList.append(offline)
            }
        }
        
        return detectedList
    }
    
    public func activateItem(_ item: StatusItemModel) {
        if item.isSystemItem {
            // Open corresponding System Settings pane if applicable
            switch item.id {
            case "com.apple.controlcenter.battery":
                if let url = URL(string: "x-apple.systempreferences:com.apple.Battery-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            case "com.apple.controlcenter.wifi":
                if let url = URL(string: "x-apple.systempreferences:com.apple.wifi-settings-extension") {
                    NSWorkspace.shared.open(url)
                }
            case "com.apple.controlcenter.bluetooth":
                if let url = URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings") {
                    NSWorkspace.shared.open(url)
                }
            case "com.apple.controlcenter.sound":
                if let url = URL(string: "x-apple.systempreferences:com.apple.Sound-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            case "com.apple.controlcenter.display":
                if let url = URL(string: "x-apple.systempreferences:com.apple.Displays-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            case "com.apple.controlcenter.focus":
                if let url = URL(string: "x-apple.systempreferences:com.apple.Focus-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            default:
                if let url = URL(string: "x-apple.systempreferences:") {
                    NSWorkspace.shared.open(url)
                }
            }
            return
        }
        
        // If it's a running application, activate it
        if let pid = item.processIdentifier,
           let app = NSRunningApplication(processIdentifier: pid) {
            app.activate()
            return
        }
        
        if let bundleId = item.bundleIdentifier {
            let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
            if let app = apps.first {
                app.activate()
                return
            }
            // If not running, launch it
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            }
        }
    }
}
