import Foundation
import SwiftUI

public enum TriggerType: String, Codable, CaseIterable, Identifiable, Sendable {
    case lowBattery = "Battery Low (< 20%)"
    case batteryCharging = "Power Connected / Charging"
    case wifiDisconnected = "Wi-Fi Disconnected"
    case audioActive = "Audio / Music Playing"
    case hoverReveal = "Hover over Menu Bar"
    case scheduledWorkHours = "Scheduled Hours (9 AM - 5 PM)"
    
    public var id: String { rawValue }
    
    public var iconSymbol: String {
        switch self {
        case .lowBattery: return "battery.25"
        case .batteryCharging: return "bolt.batteryblock.fill"
        case .wifiDisconnected: return "wifi.slash"
        case .audioActive: return "speaker.wave.3.fill"
        case .hoverReveal: return "cursorarrow.rays"
        case .scheduledWorkHours: return "clock.fill"
        }
    }
}

public struct TriggerRule: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var type: TriggerType
    public var isEnabled: Bool
    public var revealSeconds: Double
    public var targetItemBundleId: String? // Specific item to show, or nil for whole AleBar shelf
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        type: TriggerType,
        isEnabled: Bool = true,
        revealSeconds: Double = 6.0,
        targetItemBundleId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.isEnabled = isEnabled
        self.revealSeconds = revealSeconds
        self.targetItemBundleId = targetItemBundleId
    }
    
    public static var defaultRules: [TriggerRule] {
        [
            TriggerRule(name: "Show on Low Battery", type: .lowBattery, isEnabled: true, revealSeconds: 10.0, targetItemBundleId: "com.apple.controlcenter.battery"),
            TriggerRule(name: "Show when Power Connected", type: .batteryCharging, isEnabled: true, revealSeconds: 5.0, targetItemBundleId: "com.apple.controlcenter.battery"),
            TriggerRule(name: "Show on Network Drop", type: .wifiDisconnected, isEnabled: true, revealSeconds: 8.0, targetItemBundleId: "com.apple.controlcenter.wifi"),
            TriggerRule(name: "Instant Hover Reveal", type: .hoverReveal, isEnabled: true, revealSeconds: 4.0),
            TriggerRule(name: "Work Hours Focus", type: .scheduledWorkHours, isEnabled: false, revealSeconds: 0.0)
        ]
    }
}
