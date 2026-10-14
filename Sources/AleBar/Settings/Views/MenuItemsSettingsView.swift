import SwiftUI

public struct MenuItemsSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    enum FilterSection: String, CaseIterable, Identifiable {
        case all = "All"
        case shown = "Shown"
        case hidden = "Hidden"
        case alwaysHidden = "Always Hidden"
        
        var id: String { rawValue }
    }
    
    public init() {}
    
    private var currentFilter: FilterSection {
        FilterSection(rawValue: appState.menuItemsFilterSection) ?? .all
    }
    
    private var filteredItems: [StatusItemModel] {
        appState.items.filter { item in
            let q = appState.menuItemsFilterText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = q.isEmpty ||
                item.name.localizedCaseInsensitiveContains(q) ||
                (item.bundleIdentifier?.localizedCaseInsensitiveContains(q) == true)
            
            let matchesFilter: Bool
            switch currentFilter {
            case .all: matchesFilter = true
            case .shown: matchesFilter = (item.section == .shown)
            case .hidden: matchesFilter = (item.section == .hidden)
            case .alwaysHidden: matchesFilter = (item.section == .alwaysHidden)
            }
            
            return matchesSearch && matchesFilter
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header with Search and Filter
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Filter items...", text: $appState.menuItemsFilterText)
                        .textFieldStyle(.plain)
                    if !appState.menuItemsFilterText.isEmpty {
                        Button(action: { appState.menuItemsFilterText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Picker("Filter", selection: Binding(
                    get: { appState.menuItemsFilterSection },
                    set: { appState.menuItemsFilterSection = $0 }
                )) {
                    ForEach(FilterSection.allCases) { sec in
                        Text(sec.rawValue).tag(sec.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                
                Button(action: {
                    appState.refreshItems()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .help("Rescan running menu bar apps")
            }
            .padding(14)
            
            Divider()
            
            // Items List
            if filteredItems.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No menu bar items found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredItems) { item in
                        HStack(spacing: 12) {
                            // Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.primary.opacity(0.06))
                                    .frame(width: 30, height: 30)
                                Image(systemName: item.systemSymbol)
                                    .font(.system(size: 15))
                                    .foregroundStyle(item.isRunning ? Color.primary : Color.secondary)
                            }
                            
                            // Title & Bundle
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(item.name)
                                        .font(.system(size: 13, weight: .semibold))
                                    
                                    if item.isSystemItem {
                                        Text("System")
                                            .font(.system(size: 9, weight: .medium))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundStyle(Color.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                if let bundleId = item.bundleIdentifier {
                                    Text(bundleId)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Section Selector Picker
                            Picker("", selection: Binding(
                                get: { item.section },
                                set: { newSec in
                                    appState.setItemSection(itemId: item.id, section: newSec)
                                }
                            )) {
                                ForEach(ItemSection.allCases) { sec in
                                    Label(sec.rawValue, systemImage: sec.iconName)
                                        .tag(sec)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 140)
                            
                            // Activate test button
                            Button(action: {
                                MenuBarDetector.shared.activateItem(item)
                            }) {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 14))
                            }
                            .buttonStyle(.plain)
                            .help("Activate item")
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
            
            Divider()
            
            // Summary Footer
            HStack {
                Text("\(appState.items.filter { $0.section == .shown }.count) Shown")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("•")
                    .foregroundStyle(.tertiary)
                Text("\(appState.items.filter { $0.section == .hidden }.count) Hidden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("•")
                    .foregroundStyle(.tertiary)
                Text("\(appState.items.filter { $0.section == .alwaysHidden }.count) Always Hidden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Changes take effect immediately")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.02))
        }
    }
}
