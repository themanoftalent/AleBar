import SwiftUI

public struct HotkeysSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Global Keyboard Shortcuts")
                        .font(.headline)
                    Text("Control your menu bar instantly from anywhere on macOS.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Configured Hotkeys") {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Toggle AleBar Shelf")
                            .font(.system(size: 13, weight: .medium))
                        Text("Expands or collapses the floating shelf showing hidden items.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        KeyBadgeView(key: "⌘")
                        KeyBadgeView(key: "⌥")
                        KeyBadgeView(key: "B")
                    }
                }
                .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Search / Command Bar")
                            .font(.system(size: 13, weight: .medium))
                        Text("Opens the keyboard-driven menu bar item search palette.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        KeyBadgeView(key: "⌘")
                        KeyBadgeView(key: "⌥")
                        KeyBadgeView(key: "Space")
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section("macOS Accessibility & Permissions") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        Text("Standard Mode Active (No Screen Recording Required)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    
                    Text("AleBar runs cleanly without requiring invasive screen recording permissions, using native AppKit status items and accessibility APIs.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
    }
}

private struct KeyBadgeView: View {
    let key: String
    
    var body: some View {
        Text(key)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
    }
}
