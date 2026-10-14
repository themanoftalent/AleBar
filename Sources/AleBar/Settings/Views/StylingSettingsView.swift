import SwiftUI

public struct StylingSettingsView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private var theme: Binding<MenuBarTheme> {
        Binding(
            get: { appState.theme },
            set: { newTheme in
                appState.updateTheme(newTheme)
            }
        )
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Master Toggle & Info
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Menu Bar Appearance Engine")
                            .font(.system(size: 15, weight: .bold))
                        Text("Add custom gradients, glassmorphism, floating island pills, and borders to macOS.")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("Enable Styling", isOn: theme.isEnabled)
                        .toggleStyle(.switch)
                }
                .padding(14)
                .background(Color.primary.opacity(0.02))
                .cornerRadius(10)
                
                // Live Interactive Desktop Preview
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Live macOS Preview")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(appState.theme.isEnabled ? "Custom Theme Active" : "Default System Menu Bar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(appState.theme.isEnabled ? .green : .secondary)
                    }
                    
                    ZStack {
                        // Desktop wallpaper background
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.20, blue: 0.45),
                                Color(red: 0.40, green: 0.15, blue: 0.45),
                                Color(red: 0.85, green: 0.45, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Fake Menu Bar Preview
                        let previewShape = RoundedRectangle(cornerRadius: appState.theme.cornerRadius * 0.7, style: .continuous)
                        
                        HStack {
                            // Left fake Apple logo & app menus
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 11))
                                Text("AleBar")
                                    .font(.system(size: 10, weight: .bold))
                                Text("File")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 10, weight: .medium))
                                Text("View")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundStyle(.white)
                            
                            Spacer()
                            
                            // Right fake status items
                            HStack(spacing: 7) {
                                Image(systemName: "wifi")
                                Image(systemName: "battery.100")
                                Text("🍺")
                                Text("9:41 AM")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 26)
                        .background(
                            previewShape
                                .fill(
                                    appState.theme.isEnabled ?
                                    (Color(hex: appState.theme.tintColorHex) ?? Color.black.opacity(0.3)).opacity(appState.theme.opacity) :
                                    Color.white.opacity(0.18)
                                )
                        )
                        .overlay(
                            previewShape
                                .stroke(
                                    appState.theme.borderWidth > 0 && appState.theme.isEnabled ?
                                    (Color(hex: appState.theme.borderColorHex) ?? Color.white.opacity(0.4)) :
                                    Color.clear,
                                    lineWidth: appState.theme.borderWidth
                                )
                        )
                        .shadow(
                            color: appState.theme.hasShadow && appState.theme.isEnabled ? Color.black.opacity(0.4) : Color.clear,
                            radius: appState.theme.shadowRadius * 0.7,
                            y: 3
                        )
                        .padding(.horizontal, max(4, appState.theme.horizontalMargin))
                        .offset(y: -18)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                
                Divider()
                
                // Design Presets
                VStack(alignment: .leading, spacing: 10) {
                    Text("Design Presets")
                        .font(.system(size: 14, weight: .bold))
                    Text("Select a professionally crafted aesthetic preset.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 8)], spacing: 8) {
                        ForEach(ThemePreset.allCases) { preset in
                            Button(action: {
                                appState.applyThemePreset(preset)
                            }) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(presetColor(for: preset))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(preset.rawValue)
                                        .font(.system(size: 12, weight: appState.theme.preset == preset ? .semibold : .regular))
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    if appState.theme.preset == preset && appState.theme.isEnabled {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appState.theme.preset == preset && appState.theme.isEnabled ? Color.accentColor.opacity(0.12) : Color.primary.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(appState.theme.preset == preset && appState.theme.isEnabled ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                
                // Fine-Tuning Controls
                if appState.theme.isEnabled {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Geometry & Appearance Sliders")
                            .font(.system(size: 14, weight: .bold))
                        
                        // Corner Radius Slider
                        HStack {
                            Text("Corner Radius (Pill Island):")
                                .font(.system(size: 12))
                                .frame(width: 180, alignment: .leading)
                            Slider(value: theme.cornerRadius, in: 0...22, step: 1)
                            Text("\(Int(appState.theme.cornerRadius)) pt")
                                .frame(width: 48, alignment: .trailing)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Horizontal Margin Slider
                        HStack {
                            Text("Floating Horizontal Margin:")
                                .font(.system(size: 12))
                                .frame(width: 180, alignment: .leading)
                            Slider(value: theme.horizontalMargin, in: 0...24, step: 2)
                            Text("\(Int(appState.theme.horizontalMargin)) pt")
                                .frame(width: 48, alignment: .trailing)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Border Width
                        HStack {
                            Text("Outline Border Thickness:")
                                .font(.system(size: 12))
                                .frame(width: 180, alignment: .leading)
                            Slider(value: theme.borderWidth, in: 0...3, step: 0.5)
                            Text(String(format: "%.1f pt", appState.theme.borderWidth))
                                .frame(width: 48, alignment: .trailing)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Opacity
                        HStack {
                            Text("Tint Opacity:")
                                .font(.system(size: 12))
                                .frame(width: 180, alignment: .leading)
                            Slider(value: theme.opacity, in: 0.05...1.0, step: 0.05)
                            Text("\(Int(appState.theme.opacity * 100))%")
                                .frame(width: 48, alignment: .trailing)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Drop Shadow Toggle
                        Toggle("Menu Bar Drop Shadow Depth", isOn: theme.hasShadow)
                            .font(.system(size: 13, weight: .medium))
                    }
                }
            }
            .padding(20)
        }
    }
    
    private func presetColor(for preset: ThemePreset) -> Color {
        switch preset {
        case .none: return .secondary
        case .goldenAle: return Color.amberAccent
        case .liquidGlass: return .cyan
        case .darkFrosted: return .black
        case .modernPill: return .indigo
        case .sunsetGlow: return .orange
        case .neonCyber: return .teal
        case .cleanWhite: return .white
        }
    }
}
