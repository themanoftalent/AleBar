import SwiftUI
import AppKit

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
    
    private var shownCount: Int {
        appState.items.filter { $0.section == .shown }.count
    }
    
    private var hiddenCount: Int {
        appState.items.filter { $0.section == .hidden }.count
    }
    
    private var alwaysHiddenCount: Int {
        appState.items.filter { $0.section == .alwaysHidden }.count
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
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                        TextField("Search apps and items...", text: $appState.menuItemsFilterText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                        if !appState.menuItemsFilterText.isEmpty {
                            Button(action: { appState.menuItemsFilterText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Rescan button
                    Button(action: triggerRescan) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(appState.menuItemsIsScanning ? 360 : 0))
                                .animation(appState.menuItemsIsScanning ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: appState.menuItemsIsScanning)
                            Text("Scan Apps")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .disabled(appState.menuItemsIsScanning)
                    
                    // Add Custom App button
                    Button(action: openAddAppDialog) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add App...")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Filter Segmented Controls with Badges
                HStack(spacing: 6) {
                    FilterPill(
                        title: "All",
                        count: appState.items.count,
                        isSelected: currentFilter == .all,
                        color: .primary
                    ) {
                        appState.menuItemsFilterSection = FilterSection.all.rawValue
                    }
                    
                    FilterPill(
                        title: "Shown in Menu Bar",
                        count: shownCount,
                        isSelected: currentFilter == .shown,
                        color: .green
                    ) {
                        appState.menuItemsFilterSection = FilterSection.shown.rawValue
                    }
                    
                    FilterPill(
                        title: "Hidden in Shelf",
                        count: hiddenCount,
                        isSelected: currentFilter == .hidden,
                        color: .orange
                    ) {
                        appState.menuItemsFilterSection = FilterSection.hidden.rawValue
                    }
                    
                    FilterPill(
                        title: "Always Stashed",
                        count: alwaysHiddenCount,
                        isSelected: currentFilter == .alwaysHidden,
                        color: .purple
                    ) {
                        appState.menuItemsFilterSection = FilterSection.alwaysHidden.rawValue
                    }
                    
                    Spacer()
                }
            }
            .padding(14)
            .background(Color.primary.opacity(0.02))
            
            Divider()
            
            // Toast Notification
            if let toast = appState.menuItemsToastMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(toast)
                        .font(.system(size: 12, weight: .medium))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Items List
            if filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "menubar.dock.rectangle")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary.opacity(0.6))
                    Text("No matching items found")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text("Try changing your search query or click 'Scan Apps' above.")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                    
                    Button("Scan Running Items") {
                        triggerRescan()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredItems) { item in
                        MenuItemRowView(
                            item: item,
                            onMoveSection: { newSection in
                                appState.setItemSection(itemId: item.id, section: newSection)
                            },
                            onActivate: {
                                MenuBarDetector.shared.activateItem(item)
                            },
                            onRevealInFinder: {
                                revealInFinder(item: item)
                            }
                        )
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
            
            Divider()
            
            // Summary Footer
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("\(shownCount) Shown")
                        .font(.system(size: 11, weight: .medium))
                }
                
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 7, height: 7)
                    Text("\(hiddenCount) Hidden")
                        .font(.system(size: 11, weight: .medium))
                }
                
                HStack(spacing: 4) {
                    Circle().fill(Color.purple).frame(width: 7, height: 7)
                    Text("\(alwaysHiddenCount) Always Stashed")
                        .font(.system(size: 11, weight: .medium))
                }
                
                Spacer()
                
                Button("Reset Sections to Default") {
                    resetToDefaults()
                }
                .font(.system(size: 11))
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.02))
        }
    }
    
    private func triggerRescan() {
        appState.menuItemsIsScanning = true
        appState.refreshItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            appState.menuItemsIsScanning = false
            showToast("Scanned \(appState.items.count) menu bar applications")
        }
    }
    
    private func showToast(_ msg: String) {
        appState.menuItemsToastMessage = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                appState.menuItemsToastMessage = nil
            }
        }
    }
    
    private func resetToDefaults() {
        appState.items = MenuBarDetector.shared.scanRunningItems()
        appState.saveSettings()
        showToast("Reset menu item sections to default")
    }
    
    private func openAddAppDialog() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.prompt = "Add to AleBar"
        
        if panel.runModal() == .OK, let url = panel.url {
            if let bundle = Bundle(url: url),
               let bundleId = bundle.bundleIdentifier {
                let name = bundle.infoDictionary?["CFBundleDisplayName"] as? String
                    ?? bundle.infoDictionary?["CFBundleName"] as? String
                    ?? url.deletingPathExtension().lastPathComponent
                
                if !appState.items.contains(where: { $0.id == bundleId }) {
                    let newItem = StatusItemModel(
                        id: bundleId,
                        name: name,
                        bundleIdentifier: bundleId,
                        systemSymbol: "app.fill",
                        isSystemItem: false,
                        section: .hidden,
                        orderIndex: appState.items.count,
                        isRunning: true
                    )
                    appState.items.append(newItem)
                    appState.saveSettings()
                    showToast("Added \(name) to Hidden section")
                } else {
                    showToast("\(name) is already in the list")
                }
            }
        }
    }
    
    private func revealInFinder(item: StatusItemModel) {
        if let bundleId = item.bundleIdentifier,
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
}

// MARK: - Filter Pill
private struct FilterPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                
                Text("\(count)")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? color.opacity(0.25) : Color.primary.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? color.opacity(0.12) : Color.primary.opacity(0.04))
            .foregroundColor(isSelected ? color : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Menu Item Row View
private struct MenuItemRowView: View {
    let item: StatusItemModel
    let onMoveSection: (ItemSection) -> Void
    let onActivate: () -> Void
    let onRevealInFinder: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // High-Resolution App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .frame(width: 36, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                
                if let icon = item.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                } else {
                    Image(systemName: item.systemSymbol)
                        .font(.system(size: 16))
                        .foregroundStyle(item.isRunning ? Color.primary : Color.secondary)
                }
            }
            
            // Name, Bundle ID & Badges
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .semibold))
                    
                    if item.isSystemItem {
                        Text("System")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.12))
                            .foregroundStyle(Color.blue)
                            .clipShape(Capsule())
                    }
                    
                    if item.isRunning {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .help("Application is currently running")
                    }
                }
                
                if let bundleId = item.bundleIdentifier {
                    Text(bundleId)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Section Switcher Segment
            HStack(spacing: 2) {
                SectionButton(
                    section: .shown,
                    currentSection: item.section,
                    icon: "eye.fill",
                    label: "Shown",
                    color: .green
                ) {
                    onMoveSection(.shown)
                }
                
                SectionButton(
                    section: .hidden,
                    currentSection: item.section,
                    icon: "eye.slash.fill",
                    label: "Hidden",
                    color: .orange
                ) {
                    onMoveSection(.hidden)
                }
                
                SectionButton(
                    section: .alwaysHidden,
                    currentSection: item.section,
                    icon: "archivebox.fill",
                    label: "Stashed",
                    color: .purple
                ) {
                    onMoveSection(.alwaysHidden)
                }
            }
            .padding(2)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Action Menu
            Menu {
                Button(action: onActivate) {
                    Label("Activate Application", systemImage: "play.fill")
                }
                Button(action: onRevealInFinder) {
                    Label("Reveal in Finder", systemImage: "folder.fill")
                }
                Divider()
                Button(action: { onMoveSection(.shown) }) {
                    Label("Move to Shown (Main Menu Bar)", systemImage: "eye.fill")
                }
                Button(action: { onMoveSection(.hidden) }) {
                    Label("Move to Hidden (AleBar Shelf)", systemImage: "eye.slash.fill")
                }
                Button(action: { onMoveSection(.alwaysHidden) }) {
                    Label("Move to Always Stashed", systemImage: "archivebox.fill")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 24)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Section Button Component
private struct SectionButton: View {
    let section: ItemSection
    let currentSection: ItemSection
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    private var isSelected: Bool {
        section == currentSection
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(isSelected ? color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? color : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .help("Move to \(section.rawValue)")
    }
}
