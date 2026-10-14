import SwiftUI
import AppKit

public struct CommandBarView: View {
    @ObservedObject var appState = AppState.shared
    
    private var filteredItems: [StatusItemModel] {
        let q = appState.commandBarQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return appState.items
        }
        return appState.items.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            ($0.bundleIdentifier?.localizedCaseInsensitiveContains(q) == true) ||
            $0.section.rawValue.localizedCaseInsensitiveContains(q)
        }
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search Input Row
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                
                TextField("Search menu bar items, apps, or triggers...", text: $appState.commandBarQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15, weight: .regular))
                    .onSubmit {
                        activateSelected()
                    }
                    .onChange(of: appState.commandBarQuery) { _, _ in
                        appState.commandBarSelectedIndex = 0
                    }
                
                if !appState.commandBarQuery.isEmpty {
                    Button(action: { appState.commandBarQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Text("Esc to close")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
            
            // Search Results List
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "slash.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    Text("No matching menu bar items")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                CommandBarItemRow(
                                    item: item,
                                    isSelected: index == appState.commandBarSelectedIndex,
                                    onSelect: {
                                        appState.commandBarSelectedIndex = index
                                        activateItem(item)
                                    }
                                )
                                .id(index)
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                    .frame(maxHeight: 280)
                }
            }
            
            Divider()
            
            // Bottom Action Bar
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("↵")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    Text("Open / Activate")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Text("↑↓")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    Text("Navigate")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(filteredItems.count) items available")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.03))
        }
        .frame(width: 540)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
        )
    }
    
    private func activateSelected() {
        guard !filteredItems.isEmpty, appState.commandBarSelectedIndex < filteredItems.count else { return }
        activateItem(filteredItems[appState.commandBarSelectedIndex])
    }
    
    private func activateItem(_ item: StatusItemModel) {
        MenuBarDetector.shared.activateItem(item)
        appState.hideCommandBar()
    }
}

// MARK: - Row View
private struct CommandBarItemRow: View {
    let item: StatusItemModel
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.08))
                        .frame(width: 26, height: 26)
                    Image(systemName: item.systemSymbol)
                        .font(.system(size: 13))
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                }
                
                // Name & Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                    
                    if let bundleId = item.bundleIdentifier {
                        Text(bundleId)
                            .font(.system(size: 10))
                            .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                    }
                }
                
                Spacer()
                
                // Section Tag Badge
                HStack(spacing: 4) {
                    Image(systemName: item.section.iconName)
                        .font(.system(size: 9))
                    Text(item.section.rawValue)
                        .font(.system(size: 10, weight: .medium))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(isSelected ? Color.white.opacity(0.2) : Color.primary.opacity(0.06))
                .clipShape(Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
