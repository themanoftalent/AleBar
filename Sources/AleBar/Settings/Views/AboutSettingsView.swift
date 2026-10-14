import SwiftUI

public struct AboutSettingsView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mug.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .padding(.top, 12)
            
            VStack(spacing: 4) {
                Text("AleBar")
                    .font(.title2.bold())
                Text("Version 1.0 (macOS Edition)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("Own your menu bar with quick reveal, floating AleBar shelf, keyboard-driven search, custom styling, and smart triggers.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            
            Divider()
                .padding(.horizontal, 24)
            
            // Feature List
            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "menubar.dock.rectangle", title: "Menu Bar Organization", desc: "Hide clutter, keep essentials, stash rarely-used items.")
                FeatureRow(icon: "mug.fill", title: "The AleBar Shelf", desc: "Floating notch-aware shelf directly beneath the menu bar.")
                FeatureRow(icon: "magnifyingglass", title: "Command Bar & Search", desc: "Instantly find and trigger any menu bar item via ⌘⌥Space.")
                FeatureRow(icon: "paintbrush.fill", title: "Styling Engine", desc: "Add tints, borders, Liquid Glass, and rounded floating island corners.")
                FeatureRow(icon: "bolt.fill", title: "Smart Triggers", desc: "Auto-reveal items on low battery, network changes, or hover.")
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            Text("Built natively with Swift & SwiftUI for macOS")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
