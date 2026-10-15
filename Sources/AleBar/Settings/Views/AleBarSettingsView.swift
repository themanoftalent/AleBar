import SwiftUI

public struct AleBarSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Section 1: Live Interactive Shelf Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interactive Shelf Preview")
                        .font(.system(size: 14, weight: .bold))
                    Text("This is how your AleBar Shelf currently looks when expanded beneath your menu bar.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        // Desktop wallpaper mockup
                        LinearGradient(
                            colors: [Color.indigo.opacity(0.4), Color.purple.opacity(0.35), Color.blue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Fake notch at top
                        if appState.notchAvoidanceEnabled {
                            VStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black)
                                    .frame(width: 80, height: 16)
                                Spacer()
                            }
                        }
                        
                        // Mini Live AleBar Shelf
                        HStack(spacing: 10) {
                            HStack(spacing: 5) {
                                Image(systemName: "mug.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.amberAccent)
                                Text("AleBar")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Capsule())
                            
                            Divider().frame(height: 14)
                            
                            // Sample hidden item icons
                            HStack(spacing: 6) {
                                ForEach(appState.items.filter { $0.section == .hidden }.prefix(5)) { item in
                                    if let icon = item.appIcon {
                                        Image(nsImage: icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                    } else {
                                        Image(systemName: item.systemSymbol)
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            if appState.topShelfEnabled {
                                HStack(spacing: 6) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "battery.100")
                                            .font(.system(size: 9))
                                            .foregroundStyle(.green)
                                        Text("\(appState.batteryLevel)%")
                                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.primary.opacity(0.06))
                                    .clipShape(Capsule())
                                    
                                    HStack(spacing: 3) {
                                        Text("CPU")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.secondary)
                                        Text(String(format: "%.0f%%", appState.cpuUsage))
                                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.primary.opacity(0.06))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            if appState.showSearchInAleBar {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 10))
                                    .padding(4)
                                    .background(Color.primary.opacity(0.06))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
                        )
                        .offset(y: appState.notchAvoidanceEnabled ? 8 : 0)
                        .padding(.horizontal, 20)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                
                Divider()
                
                // Section 2: Top Shelf & Notch Integration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Display & Notch Adaptation")
                        .font(.system(size: 14, weight: .bold))
                    
                    Toggle("MacBook Camera Notch Auto-Avoidance", isOn: $appState.notchAvoidanceEnabled)
                        .font(.system(size: 13, weight: .medium))
                        .onChange(of: appState.notchAvoidanceEnabled) { _, _ in
                            appState.saveSettings()
                            AleBarWindowController.shared.positionWindow()
                        }
                    
                    Text("Centers the AleBar shelf smoothly directly beneath the MacBook Pro or MacBook Air display notch to prevent visual clipping.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 18)
                }
                
                Divider()
                
                // Section 3: Live System Metric Widgets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top Shelf Live System Widgets")
                        .font(.system(size: 14, weight: .bold))
                    
                    Toggle("Show Live System Metrics in Shelf (Battery, CPU, RAM)", isOn: $appState.topShelfEnabled)
                        .font(.system(size: 13, weight: .medium))
                        .onChange(of: appState.topShelfEnabled) { _, _ in
                            appState.saveSettings()
                        }
                    
                    if appState.topShelfEnabled {
                        HStack(spacing: 12) {
                            MetricCapsule(icon: "battery.100", title: "Battery Status", value: "\(appState.batteryLevel)%", tint: .green)
                            MetricCapsule(icon: "cpu", title: "CPU Activity", value: String(format: "%.1f%%", appState.cpuUsage), tint: .blue)
                            MetricCapsule(icon: "memorychip", title: "RAM Pressure", value: String(format: "%.1f%%", appState.memoryUsage), tint: .purple)
                        }
                        .padding(.leading, 18)
                    }
                }
                
                Divider()
                
                // Section 4: Shelf Controls & Shortcuts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Shelf Controls & Actions")
                        .font(.system(size: 14, weight: .bold))
                    
                    Toggle("Show Search Icon in AleBar Shelf", isOn: $appState.showSearchInAleBar)
                        .font(.system(size: 13, weight: .medium))
                        .onChange(of: appState.showSearchInAleBar) { _, _ in
                            appState.saveSettings()
                        }
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            AleBarWindowController.shared.show()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "eye.fill")
                                Text("Display Shelf on Screen")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: {
                            AleBarWindowController.shared.hide()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "eye.slash.fill")
                                Text("Dismiss Shelf")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Metric Capsule Component
private struct MetricCapsule: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(tint)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.04))
        .cornerRadius(8)
    }
}
