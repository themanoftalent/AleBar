import SwiftUI

public struct TriggersSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Smart Triggers")
                        .font(.headline)
                    Text("Triggers automatically show hidden menu bar items when specific system events occur, such as when your battery is low or Wi-Fi disconnects.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Configured Triggers") {
                ForEach($appState.triggers) { $rule in
                    HStack(spacing: 12) {
                        Image(systemName: rule.type.iconSymbol)
                            .font(.system(size: 16))
                            .frame(width: 24)
                            .foregroundStyle(rule.isEnabled ? Color.accentColor : Color.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rule.name)
                                .font(.system(size: 13, weight: .medium))
                            Text(rule.type.rawValue)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if rule.isEnabled && rule.revealSeconds > 0 {
                            Text("\(Int(rule.revealSeconds))s reveal")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                        }
                        
                        Toggle("", isOn: $rule.isEnabled)
                            .labelsHidden()
                            .onChange(of: rule.isEnabled) { _, _ in
                                TriggersEngine.shared.updateRules(appState.triggers)
                            }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Test Triggers") {
                HStack(spacing: 12) {
                    Button("Simulate Low Battery Trigger") {
                        if let r = appState.triggers.first(where: { $0.type == .lowBattery }) {
                            TriggersEngine.shared.fireTrigger(r)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Simulate Wi-Fi Drop Trigger") {
                        if let r = appState.triggers.first(where: { $0.type == .wifiDisconnected }) {
                            TriggersEngine.shared.fireTrigger(r)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }
}
