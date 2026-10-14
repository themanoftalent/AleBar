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
        case .general: return "gearshape"
        case .menuItems: return "menubar.dock.rectangle"
        case .aleBar: return "mug"
        case .styling: return "paintbrush"
        case .triggers: return "bolt"
        case .hotkeys: return "command"
        case .about: return "info.circle"
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
            List(SettingsTab.allCases, selection: Binding(
                get: { SettingsTab(rawValue: appState.selectedSettingsTab) ?? .general },
                set: { appState.selectedSettingsTab = $0.rawValue }
            )) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.iconSymbol)
                }
            }
            .navigationTitle("AleBar")
            .frame(minWidth: 180)
        } detail: {
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
            .frame(minWidth: 500, minHeight: 460)
        }
        .frame(minWidth: 700, minHeight: 480)
    }
}
