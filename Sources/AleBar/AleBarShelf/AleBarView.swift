import SwiftUI
import AppKit

public struct AleBarView: View {
    @ObservedObject var appState = AppState.shared
    
    private var hiddenItems: [StatusItemModel] {
        appState.items.filter { $0.section == .hidden }
    }
    
    private var alwaysHiddenItems: [StatusItemModel] {
        appState.items.filter { $0.section == .alwaysHidden }
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 8) {
            // Main Top Bar Row
            HStack(spacing: 12) {
                // AleBar Brand Pill
                HStack(spacing: 6) {
                    Image(systemName: "mug.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tint)
                    Text("AleBar")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.08))
                .clipShape(Capsule())
                
                Divider()
                    .frame(height: 18)
                
                // Hidden Menu Items Grid / Row
                if hiddenItems.isEmpty {
                    Text("No hidden items. Configure items in Settings.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                } else {
                    HStack(spacing: 8) {
                        ForEach(hiddenItems) { item in
                            ItemButtonView(
                                item: item,
                                isHovered: appState.barHoveredItemId == item.id,
                                onHover: { hovered in
                                    appState.barHoveredItemId = hovered ? item.id : nil
                                },
                                onActivate: {
                                    MenuBarDetector.shared.activateItem(item)
                                },
                                onChangeSection: { newSec in
                                    appState.setItemSection(itemId: item.id, section: newSec)
                                }
                            )
                        }
                    }
                }
                
                // Expand Always-Hidden toggle if present
                if !alwaysHiddenItems.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            appState.barShowAlwaysHidden.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: appState.barShowAlwaysHidden ? "chevron.left" : "ellipsis")
                                .font(.system(size: 10, weight: .bold))
                            Text("\(alwaysHiddenItems.count)")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(appState.barShowAlwaysHidden ? Color.accentColor.opacity(0.2) : Color.primary.opacity(0.06))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help(appState.barShowAlwaysHidden ? "Hide Always-Hidden items" : "Show Always-Hidden items")
                }
                
                Spacer(minLength: 8)
                
                // Top Shelf Live Widgets
                if appState.topShelfEnabled {
                    TopShelfWidgetsView(appState: appState)
                    
                    Divider()
                        .frame(height: 18)
                }
                
                // Quick Search Button
                Button(action: {
                    appState.showCommandBar()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .medium))
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Quick Search / Command Bar (⌘⌥Space)")
                
                // Settings Button
                Button(action: {
                    SettingsWindowController.shared.show()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12, weight: .medium))
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("AleBar Preferences")
                
                // Close / Collapse Button
                Button(action: {
                    appState.hideAleBar()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .padding(6)
                        .background(Color.primary.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Close Bar")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            
            // Expanded Always-Hidden Section
            if appState.barShowAlwaysHidden && !alwaysHiddenItems.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Text("Always Hidden Items")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    
                    HStack(spacing: 8) {
                        ForEach(alwaysHiddenItems) { item in
                            ItemButtonView(
                                item: item,
                                isHovered: appState.barHoveredItemId == item.id,
                                onHover: { hovered in
                                    appState.barHoveredItemId = hovered ? item.id : nil
                                },
                                onActivate: {
                                    MenuBarDetector.shared.activateItem(item)
                                },
                                onChangeSection: { newSec in
                                    appState.setItemSection(itemId: item.id, section: newSec)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(minWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
        )
        .padding(8)
    }
}

// MARK: - Individual Item Button
private struct ItemButtonView: View {
    let item: StatusItemModel
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onActivate: () -> Void
    let onChangeSection: (ItemSection) -> Void
    
    var body: some View {
        Button(action: onActivate) {
            VStack(spacing: 3) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isHovered ? Color.primary.opacity(0.12) : Color.clear)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: item.systemSymbol)
                        .font(.system(size: 14))
                        .foregroundStyle(item.isRunning ? Color.primary : Color.secondary)
                }
                
                // Running indicator dot
                Circle()
                    .fill(item.isRunning ? Color.accentColor : Color.clear)
                    .frame(width: 3, height: 3)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            onHover(hovering)
        }
        .help("\(item.name) (\(item.section.rawValue)) - Click to open")
        .contextMenu {
            Text(item.name)
                .font(.headline)
            Divider()
            Button("Activate / Open") {
                onActivate()
            }
            Divider()
            Button("Move to Main Menu Bar (Shown)") {
                onChangeSection(.shown)
            }
            Button("Move to AleBar Shelf (Hidden)") {
                onChangeSection(.hidden)
            }
            Button("Move to Always Hidden") {
                onChangeSection(.alwaysHidden)
            }
        }
    }
}

// MARK: - Top Shelf Widgets View
private struct TopShelfWidgetsView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 10) {
            // Battery Widget
            HStack(spacing: 4) {
                Image(systemName: appState.isCharging ? "bolt.batteryblock.fill" : (appState.batteryLevel < 20 ? "battery.25" : "battery.100"))
                    .font(.system(size: 12))
                    .foregroundStyle(appState.batteryLevel < 20 ? Color.red : (appState.isCharging ? Color.green : Color.primary))
                Text("\(appState.batteryLevel)%")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
            .help("Battery status: \(appState.batteryLevel)% \(appState.isCharging ? "(Charging)" : "")")
            
            // CPU Gauge
            HStack(spacing: 4) {
                Text("CPU")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", appState.cpuUsage))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
            .help("CPU Usage: \(String(format: "%.1f%%", appState.cpuUsage))")
            
            // RAM Gauge
            HStack(spacing: 4) {
                Text("RAM")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", appState.memoryUsage))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.primary.opacity(0.06))
            .clipShape(Capsule())
            .help("Memory Usage: \(String(format: "%.1f%%", appState.memoryUsage))")
        }
    }
}
