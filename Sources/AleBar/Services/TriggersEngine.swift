import Foundation
import AppKit

public final class TriggersEngine: @unchecked Sendable {
    public static let shared = TriggersEngine()
    
    public var onTriggerFired: ((_ rule: TriggerRule) -> Void)?
    
    private var rules: [TriggerRule] = []
    private var autoHideWorkItem: DispatchWorkItem?
    
    private init() {
        setupSystemMonitorCallbacks()
    }
    
    public func updateRules(_ newRules: [TriggerRule]) {
        self.rules = newRules
    }
    
    private func setupSystemMonitorCallbacks() {
        SystemMonitor.shared.onBatteryStateChange = { [weak self] isLow, isCharging, level in
            guard let self = self else { return }
            
            if isLow {
                if let rule = self.rules.first(where: { $0.isEnabled && $0.type == .lowBattery }) {
                    self.fireTrigger(rule)
                }
            } else if isCharging {
                if let rule = self.rules.first(where: { $0.isEnabled && $0.type == .batteryCharging }) {
                    self.fireTrigger(rule)
                }
            }
        }
        
        SystemMonitor.shared.onNetworkStateChange = { [weak self] isConnected in
            guard let self = self else { return }
            if !isConnected {
                if let rule = self.rules.first(where: { $0.isEnabled && $0.type == .wifiDisconnected }) {
                    self.fireTrigger(rule)
                }
            }
        }
    }
    
    public func fireTrigger(_ rule: TriggerRule) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onTriggerFired?(rule)
            
            if rule.revealSeconds > 0 {
                self.scheduleAutoHide(after: rule.revealSeconds)
            }
        }
    }
    
    public func scheduleAutoHide(after seconds: Double, action: (@MainActor @Sendable () -> Void)? = nil) {
        autoHideWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            Task { @MainActor in
                action?()
            }
        }
        self.autoHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem)
    }
    
    public func cancelAutoHide() {
        autoHideWorkItem?.cancel()
        autoHideWorkItem = nil
    }
}
