import SwiftUI

public struct TriggersSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Info Banner
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Smart Event Triggers")
                            .font(.system(size: 15, weight: .bold))
                        Text("Triggers temporarily reveal hidden menu bar items when critical system events happen, like low battery or Wi-Fi disconnection.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .background(Color.primary.opacity(0.02))
                .cornerRadius(10)
                
                // Toast notification
                if let toast = appState.triggersToastMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.circle.fill")
                            .foregroundStyle(.orange)
                        Text(toast)
                            .font(.system(size: 12, weight: .semibold))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Configured Triggers
                VStack(alignment: .leading, spacing: 10) {
                    Text("Configured Trigger Rules")
                        .font(.system(size: 14, weight: .bold))
                    
                    VStack(spacing: 8) {
                        ForEach($appState.triggers) { $rule in
                            TriggerRuleCard(
                                rule: $rule,
                                onUpdate: {
                                    TriggersEngine.shared.updateRules(appState.triggers)
                                },
                                onTest: {
                                    TriggersEngine.shared.fireTrigger(rule)
                                    showToast("⚡️ Trigger Fired: '\(rule.name)' — Expanding Menu Bar for \(Int(rule.revealSeconds))s")
                                }
                            )
                        }
                    }
                }
                
                Divider()
                
                // Quick Test Sandbox
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trigger Test Sandbox")
                        .font(.system(size: 14, weight: .bold))
                    Text("Simulate system hardware state changes to verify trigger workflows.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            if let r = appState.triggers.first(where: { $0.type == .lowBattery }) {
                                TriggersEngine.shared.fireTrigger(r)
                                showToast("Simulated Low Battery Alert: Revealing hidden items!")
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "battery.25")
                                Text("Simulate Low Battery (15%)")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            if let r = appState.triggers.first(where: { $0.type == .wifiDisconnected }) {
                                TriggersEngine.shared.fireTrigger(r)
                                showToast("Simulated Wi-Fi Loss: Revealing network status!")
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "wifi.slash")
                                Text("Simulate Wi-Fi Drop")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            if let r = appState.triggers.first(where: { $0.type == .batteryCharging }) {
                                TriggersEngine.shared.fireTrigger(r)
                                showToast("Simulated MagSafe Connected: Revealing battery status!")
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "bolt.batteryblock.fill")
                                Text("Simulate Power Connected")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(20)
        }
    }
    
    private func showToast(_ msg: String) {
        appState.triggersToastMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                appState.triggersToastMessage = nil
            }
        }
    }
}

// MARK: - Trigger Rule Card
private struct TriggerRuleCard: View {
    @Binding var rule: TriggerRule
    let onUpdate: () -> Void
    let onTest: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(rule.isEnabled ? Color.orange.opacity(0.15) : Color.primary.opacity(0.04))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: rule.type.iconSymbol)
                        .font(.system(size: 15))
                        .foregroundStyle(rule.isEnabled ? Color.orange : Color.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(rule.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(rule.type.rawValue)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Test") {
                    onTest()
                }
                .font(.system(size: 11, weight: .medium))
                .buttonStyle(.bordered)
                .disabled(!rule.isEnabled)
                
                Toggle("", isOn: $rule.isEnabled)
                    .labelsHidden()
                    .onChange(of: rule.isEnabled) { _, _ in
                        onUpdate()
                    }
            }
            
            if rule.isEnabled {
                HStack {
                    Text("Auto-collapse after:")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 120, alignment: .leading)
                    
                    Slider(value: $rule.revealSeconds, in: 3...30, step: 1)
                        .onChange(of: rule.revealSeconds) { _, _ in
                            onUpdate()
                        }
                    
                    Text("\(Int(rule.revealSeconds))s")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .frame(width: 32, alignment: .trailing)
                }
                .padding(.leading, 46)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(rule.isEnabled ? Color.orange.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
