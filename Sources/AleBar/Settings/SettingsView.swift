import SwiftUI

public enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case menuItems = "Menu Items"
    case aleBar = "AleBar Shelf"
    case styling = "Styling"
    case triggers = "Triggers"
    case hotkeys = "Hotkeys"
    case about = "About"
    
    public var id: String { rawValue }
    
    public var iconSymbol: String {
        switch self {
        case .general: return "gearshape.fill"
        case .menuItems: return "menubar.dock.rectangle"
        case .aleBar: return "mug.fill"
        case .styling: return "paintbrush.fill"
        case .triggers: return "bolt.fill"
        case .hotkeys: return "command"
        case .about: return "info.circle.fill"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .general: return "Operation modes, icon style, hover reveal & auto-hide"
        case .menuItems: return "Organize items into Shown, Hidden, or Stashed sections"
        case .aleBar: return "Floating notch shelf, live metrics & appearance"
        case .styling: return "Liquid glass, floating island corners, tints & borders"
        case .triggers: return "Smart rules for battery, network, load & schedule"
        case .hotkeys: return "Global keyboard shortcuts & accessibility permissions"
        case .about: return "Version, system status, release notes & links"
        }
    }
    
    public var tintColor: Color {
        switch self {
        case .general: return .blue
        case .menuItems: return .indigo
        case .aleBar: return .orange
        case .styling: return .purple
        case .triggers: return .yellow
        case .hotkeys: return .red
        case .about: return .teal
        }
    }
}

public struct SettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private var selectedTab: SettingsTab {
        SettingsTab(rawValue: appState.selectedSettingsTab) ?? .general
    }
    
    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Sidebar Header
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.amberAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                        
                        Text("🍺")
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("AleBar")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(appState.isAleBarVisible ? Color.green : Color.secondary)
                                .frame(width: 6, height: 6)
                            Text(appState.isAleBarVisible ? "Expanded" : "Collapsed")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                
                Divider()
                
                // Navigation List
                List(SettingsTab.allCases, selection: Binding(
                    get: { SettingsTab(rawValue: appState.selectedSettingsTab) ?? .general },
                    set: { appState.selectedSettingsTab = $0.rawValue }
                )) { tab in
                    NavigationLink(value: tab) {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(tab.tintColor.opacity(0.15))
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: tab.iconSymbol)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(tab.tintColor)
                            }
                            
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: .medium))
                            
                            Spacer()
                            
                            if tab == .menuItems {
                                Text("\(appState.items.count)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.primary.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.sidebar)
                
                Divider()
                
                // Sidebar Footer Quick Actions
                HStack(spacing: 8) {
                    Button(action: {
                        StatusItemController.shared.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: appState.isAleBarVisible ? "eye.slash" : "eye")
                                .font(.system(size: 11))
                            Text(appState.isAleBarVisible ? "Collapse" : "Expand")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.06))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Toggle hidden menu bar items (⌘⌥B)")
                    
                    Button(action: {
                        appState.showCommandBar()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .padding(6)
                            .background(Color.primary.opacity(0.06))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Open Search / Command Bar (⌘⌥Space)")
                }
                .padding(10)
            }
            .frame(minWidth: 200, idealWidth: 220)
        } detail: {
            VStack(spacing: 0) {
                // Header Banner
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selectedTab.tintColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: selectedTab.iconSymbol)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(selectedTab.tintColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedTab.rawValue)
                            .font(.system(size: 17, weight: .bold))
                        Text(selectedTab.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.primary.opacity(0.02))
                
                Divider()
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case .general:
                        GeneralSettingsView()
                    case .menuItems:
                        MenuItemsSettingsView()
                    case .aleBar:
                        AleBarSettingsView()
                    case .styling:
                        StylingSettingsView()
                    case .triggers:
                        TriggersSettingsView()
                    case .hotkeys:
                        HotkeysSettingsView()
                    case .about:
                        AboutSettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 540, minHeight: 480)
        }
        .frame(minWidth: 760, minHeight: 520)
    }
}

extension Color {
    static let amberAccent = Color(red: 0.95, green: 0.65, blue: 0.12)
}
