import SwiftUI

public struct GeneralSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Menu Bar Icon Style")
                        .font(.headline)
                    
                    Text("Choose how AleBar appears in your system menu bar.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                        ForEach(StatusIconStyle.allCases) { style in
                            Button(action: {
                                appState.setStatusIcon(style)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: style.previewSymbol)
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 24)
                                    Text(style.rawValue)
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appState.statusIconStyle == style ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(appState.statusIconStyle == style ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Interaction & Reveal Behaviors")
                        .font(.headline)
                    
                    Toggle("Hover to Reveal", isOn: $appState.hoverRevealEnabled)
                        .onChange(of: appState.hoverRevealEnabled) { _, _ in
                            appState.saveSettings()
                        }
                    
                    if appState.hoverRevealEnabled {
                        HStack {
                            Text("Hover Delay:")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .leading)
                            Slider(value: $appState.hoverRevealDelay, in: 0.1...1.0, step: 0.05)
                            Text(String(format: "%.2fs", appState.hoverRevealDelay))
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 45)
                        }
                        .onChange(of: appState.hoverRevealDelay) { _, _ in
                            appState.saveSettings()
                        }
                    }
                    
                    Divider()
                    
                    Toggle("Auto-Hide AleBar Shelf", isOn: $appState.autoHideEnabled)
                        .onChange(of: appState.autoHideEnabled) { _, _ in
                            appState.saveSettings()
                        }
                    
                    if appState.autoHideEnabled {
                        HStack {
                            Text("Auto-Hide Delay:")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .leading)
                            Slider(value: $appState.autoHideDelay, in: 2.0...15.0, step: 1.0)
                            Text(String(format: "%.0fs", appState.autoHideDelay))
                                .font(.system(size: 12, design: .monospaced))
                                .frame(width: 45)
                        }
                        .onChange(of: appState.autoHideDelay) { _, _ in
                            appState.saveSettings()
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Reveal Tip")
                        .font(.headline)
                    Text("You can also press **⌘ + ⌥ + B** at any time to toggle the AleBar Shelf, or **⌘ + ⌥ + Space** to search your menu bar items.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }
}
