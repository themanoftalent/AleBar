import SwiftUI
import ServiceManagement

public struct GeneralSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Section 1: Operation Mode Cards
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Operation Mode")
                            .font(.system(size: 15, weight: .bold))
                        Spacer()
                        Text("Choose how AleBar collapses your items")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        ModeCard(
                            mode: .both,
                            title: "Dual Mode (Recommended)",
                            subtitle: "Collapses items in the menu bar via delimiter AND shows notch shelf",
                            badge: "Best Experience",
                            badgeColor: .blue,
                            isSelected: appState.hidingMode == .both
                        ) {
                            appState.hidingMode = .both
                            appState.saveSettings()
                        }
                        
                        ModeCard(
                            mode: .inMenuBar,
                            title: "In-Menu-Bar Only",
                            subtitle: "Pure native status bar collapse using the │ delimiter separator",
                            badge: "Native Style",
                            badgeColor: .green,
                            isSelected: appState.hidingMode == .inMenuBar
                        ) {
                            appState.hidingMode = .inMenuBar
                            appState.saveSettings()
                        }
                        
                        ModeCard(
                            mode: .floatingShelf,
                            title: "Floating Shelf Only",
                            subtitle: "Displays hidden items in a sleek floating island beneath the notch",
                            badge: "Notch Island",
                            badgeColor: .orange,
                            isSelected: appState.hidingMode == .floatingShelf
                        ) {
                            appState.hidingMode = .floatingShelf
                            appState.saveSettings()
                        }
                    }
                }
                
                // Section 2: In-Menu-Bar Delimiter Visual Guide
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundStyle(Color.amberAccent)
                        Text("How Menu Bar Collapsing Works")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                    }
                    
                    // Visual diagram
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "app.dashed")
                            Image(systemName: "speaker.wave.2")
                            Image(systemName: "airdrop")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [3]))
                        )
                        
                        Text("← Hidden")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.orange)
                        
                        // Separator delimiter
                        Text("│")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 4)
                        
                        Text("Shown →")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.green)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "wifi")
                            Image(systemName: "battery.100")
                            Text("🍺")
                            Text("9:41")
                        }
                        .font(.system(size: 11))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(6)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.primary.opacity(0.02))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    
                    Text("💡 **Tip:** Hold **⌘ (Command)** and drag any status item to the **left of │** to hide it. Click the **🍺** icon or press **⌘⌥B** to toggle!")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                    
                    // Live Test Button
                    HStack {
                        Button(action: {
                            StatusItemController.shared.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: appState.isAleBarVisible ? "eye.slash.fill" : "eye.fill")
                                Text(appState.isAleBarVisible ? "Test Action: Collapse Menu Bar Now" : "Test Action: Expand Menu Bar Now")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundColor(.accentColor)
                            .cornerRadius(7)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(appState.isAleBarVisible ? "Currently: Expanded" : "Currently: Collapsed")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(appState.isAleBarVisible ? .green : .secondary)
                    }
                }
                .padding(14)
                .background(Color.primary.opacity(0.03))
                .cornerRadius(10)
                
                Divider()
                
                // Section 3: Status Icon Style Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Menu Bar Icon Style")
                        .font(.system(size: 14, weight: .bold))
                    Text("Choose how the AleBar toggle button appears in your system menu bar.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 8)], spacing: 8) {
                        ForEach(StatusIconStyle.allCases) { style in
                            Button(action: {
                                appState.setStatusIcon(style)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: style.previewSymbol)
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 22)
                                        .foregroundStyle(appState.statusIconStyle == style ? Color.accentColor : Color.primary)
                                    
                                    Text(style.rawValue)
                                        .font(.system(size: 12, weight: appState.statusIconStyle == style ? .semibold : .regular))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    if appState.statusIconStyle == style {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appState.statusIconStyle == style ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
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
                
                Divider()
                
                // Section 4: Interaction & Reveal Behaviors
                VStack(alignment: .leading, spacing: 14) {
                    Text("Interaction & Automation Behaviors")
                        .font(.system(size: 14, weight: .bold))
                    
                    // Hover reveal
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Hover to Reveal Menu Bar", isOn: $appState.hoverRevealEnabled)
                            .font(.system(size: 13, weight: .medium))
                            .onChange(of: appState.hoverRevealEnabled) { _, _ in
                                appState.saveSettings()
                            }
                        
                        if appState.hoverRevealEnabled {
                            HStack {
                                Text("Hover Sensitivity:")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 130, alignment: .leading)
                                Slider(value: $appState.hoverRevealDelay, in: 0.1...1.0, step: 0.05)
                                Text(String(format: "%.2fs", appState.hoverRevealDelay))
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.leading, 18)
                            .onChange(of: appState.hoverRevealDelay) { _, _ in
                                appState.saveSettings()
                            }
                        }
                    }
                    
                    // Auto-hide
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Auto-Hide After Inactivity", isOn: $appState.autoHideEnabled)
                            .font(.system(size: 13, weight: .medium))
                            .onChange(of: appState.autoHideEnabled) { _, _ in
                                appState.saveSettings()
                            }
                        
                        if appState.autoHideEnabled {
                            HStack {
                                Text("Auto-Hide Delay:")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 130, alignment: .leading)
                                Slider(value: $appState.autoHideDelay, in: 2.0...20.0, step: 1.0)
                                Text(String(format: "%.0fs", appState.autoHideDelay))
                                    .font(.system(size: 12, design: .monospaced))
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .padding(.leading, 18)
                            .onChange(of: appState.autoHideDelay) { _, _ in
                                appState.saveSettings()
                            }
                        }
                    }
                    
                    // Launch at Login
                    Toggle("Launch AleBar Automatically at Login", isOn: $appState.launchAtLogin)
                        .font(.system(size: 13, weight: .medium))
                        .onChange(of: appState.launchAtLogin) { _, enabled in
                            updateLaunchAtLogin(enabled)
                        }
                }
                
                Divider()
                
                // Section 5: Keyboard Shortcuts Reference
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "command")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Global Shortcuts Reminder")
                            .font(.system(size: 13, weight: .semibold))
                        Text("• **⌘ + ⌥ + B** to toggle menu bar items and the AleBar shelf.\n• **⌘ + ⌥ + Space** to search and launch any menu bar item or app.\n• **Right-Click** the 🍺 menu bar icon to access quick actions and themes.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.primary.opacity(0.02))
                .cornerRadius(8)
            }
            .padding(20)
        }
        .onAppear {
            checkLaunchAtLogin()
        }
    }
    
    private func checkLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            appState.launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }
    
    private func updateLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }
}

// MARK: - Mode Card Component
private struct ModeCard: View {
    let mode: HidingMode
    let title: String
    let subtitle: String
    let badge: String
    let badgeColor: Color
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(badgeColor.opacity(0.15))
                            .foregroundStyle(badgeColor)
                            .clipShape(Capsule())
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color.primary.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.06), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
