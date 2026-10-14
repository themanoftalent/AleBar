import SwiftUI
import AppKit

public struct HotkeysSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Header Banner
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "command")
                            .font(.system(size: 18))
                            .foregroundStyle(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Global Keyboard Shortcuts")
                            .font(.system(size: 15, weight: .bold))
                        Text("Control AleBar instantly from anywhere across macOS without clicking.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color.primary.opacity(0.02))
                .cornerRadius(10)
                
                // Hotkey Cards
                VStack(alignment: .leading, spacing: 10) {
                    Text("Configured Shortcuts")
                        .font(.system(size: 14, weight: .bold))
                    
                    VStack(spacing: 8) {
                        HotkeyRowCard(
                            title: "Toggle Menu Bar & Shelf",
                            description: "Expands or collapses hidden items in the menu bar and notch shelf",
                            keys: ["⌘", "⌥", "B"],
                            onTest: {
                                StatusItemController.shared.toggle()
                            }
                        )
                        
                        HotkeyRowCard(
                            title: "Quick Search / Command Bar",
                            description: "Opens the keyboard-driven menu bar spotlight search palette",
                            keys: ["⌘", "⌥", "Space"],
                            onTest: {
                                appState.showCommandBar()
                            }
                        )
                        
                        HotkeyRowCard(
                            title: "Open Preferences & Settings",
                            description: "Brings the AleBar preferences window to the front",
                            keys: ["⌘", "⌥", ","],
                            onTest: {
                                SettingsWindowController.shared.show()
                            }
                        )
                    }
                }
                
                Divider()
                
                // Accessibility & Permissions Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("macOS System Permissions")
                        .font(.system(size: 14, weight: .bold))
                    
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(appState.hasAccessibility ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: appState.hasAccessibility ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(appState.hasAccessibility ? .green : .orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(appState.hasAccessibility ? "Accessibility Granted" : "Standard Mode Active")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Text(appState.hasAccessibility ?
                                 "Full accessibility permissions active. Global hotkeys and app activation operate at peak performance." :
                                 "AleBar operates cleanly using native AppKit status items. For global hotkeys outside AleBar, grant Accessibility in System Settings.")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .lineSpacing(2)
                        }
                        
                        Spacer()
                        
                        if !appState.hasAccessibility {
                            Button("Open Settings") {
                                openAccessibilityPreferences()
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Check") {
                                checkAccessibility()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(14)
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(appState.hasAccessibility ? Color.green.opacity(0.2) : Color.orange.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(20)
        }
        .onAppear {
            checkAccessibility()
        }
    }
    
    private func checkAccessibility() {
        appState.hasAccessibility = AXIsProcessTrusted()
    }
    
    private func openAccessibilityPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Hotkey Row Card
private struct HotkeyRowCard: View {
    let title: String
    let description: String
    let keys: [String]
    let onTest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                Text(description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Test") {
                onTest()
            }
            .font(.system(size: 11, weight: .medium))
            .buttonStyle(.bordered)
            
            HStack(spacing: 4) {
                ForEach(keys, id: \.self) { key in
                    KeyCapView(key: key)
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - KeyCap View
private struct KeyCapView: View {
    let key: String
    
    var body: some View {
        Text(key)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 1, y: 1)
    }
}
