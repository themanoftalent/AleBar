import SwiftUI

public struct AleBarSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Top Shelf & Notch Integration")
                        .font(.headline)
                    
                    Text("Top Shelf displays live system indicators (Battery, CPU, Memory) directly inside your AleBar Shelf.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Toggle("Enable Top Shelf Live Widgets", isOn: $appState.topShelfEnabled)
                        .onChange(of: appState.topShelfEnabled) { _, _ in
                            appState.saveSettings()
                        }
                    
                    Toggle("MacBook Notch Avoidance", isOn: $appState.notchAvoidanceEnabled)
                        .onChange(of: appState.notchAvoidanceEnabled) { _, _ in
                            appState.saveSettings()
                        }
                    
                    Text("When enabled, the AleBar Shelf automatically avoids display notches on modern MacBook Pro and MacBook Air screens.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Bar Controls")
                        .font(.headline)
                    
                    Toggle("Show Search Icon in AleBar Shelf", isOn: $appState.showSearchInAleBar)
                        .onChange(of: appState.showSearchInAleBar) { _, _ in
                            appState.saveSettings()
                        }
                    
                    HStack {
                        Button("Test AleBar Shelf (Show)") {
                            appState.showAleBar()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Hide Shelf") {
                            appState.hideAleBar()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }
}
