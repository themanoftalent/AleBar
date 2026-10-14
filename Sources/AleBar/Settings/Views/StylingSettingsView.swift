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
            VStack(alignment: .leading, spacing: 20) {
                // Header & Master Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Menu Bar Styling Engine")
                            .font(.title3.bold())
                        Text("Add custom tints, Liquid Glass styling, borders, gradients, and rounded floating island effects to macOS.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("Enable Styling", isOn: theme.isEnabled)
                        .toggleStyle(.switch)
                }
                .padding(.bottom, 4)
                
                // Live Interactive Preview Box
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Preview")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        // Fake desktop wallpaper background
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.7), Color.indigo.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        // Fake Menu Bar Preview
                        let previewShape = RoundedRectangle(cornerRadius: appState.theme.cornerRadius * 0.7, style: .continuous)
                        
                        HStack {
                            // Left fake Apple logo & app menu
                            HStack(spacing: 8) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 11))
                                Text("File")
                                    .font(.system(size: 10, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 10, weight: .medium))
                                Text("View")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            
                            Spacer()
                            
                            // Right fake status items
                            HStack(spacing: 8) {
                                Image(systemName: "wifi")
                                    .font(.system(size: 10))
                                Image(systemName: "battery.100")
                                    .font(.system(size: 10))
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 10))
                                Text("9:41 AM")
                                    .font(.system(size: 10, weight: .medium))
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 24)
                        .background(
                            previewShape
                                .fill(
                                    appState.theme.isEnabled ?
                                    (Color(hex: appState.theme.tintColorHex) ?? Color.black.opacity(0.3)).opacity(appState.theme.opacity) :
                                    Color.white.opacity(0.15)
                                )
                        )
                        .overlay(
                            previewShape
                                .stroke(
                                    appState.theme.borderWidth > 0 && appState.theme.isEnabled ?
                                    (Color(hex: appState.theme.borderColorHex) ?? Color.white.opacity(0.3)) :
                                    Color.clear,
                                    lineWidth: appState.theme.borderWidth
                                )
                        )
                        .padding(.horizontal, appState.theme.horizontalMargin)
                        .offset(y: -14)
                    }
                }
                
                Divider()
                
                // Style Presets
                VStack(alignment: .leading, spacing: 10) {
                    Text("Design Presets")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                        ForEach(ThemePreset.allCases) { preset in
                            Button(action: {
                                appState.applyThemePreset(preset)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appState.theme.preset == preset ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(appState.theme.preset == preset ? Color.accentColor : Color.clear, lineWidth: 1.5)
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
                        Text("Customization Controls")
                            .font(.headline)
                        
                        // Corner Radius Slider
                        HStack {
                            Text("Corner Radius (Pill Effect):")
                                .frame(width: 190, alignment: .leading)
                            Slider(value: theme.cornerRadius, in: 0...20, step: 1)
                            Text("\(Int(appState.theme.cornerRadius)) pt")
                                .frame(width: 45)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Horizontal Margin Slider
                        HStack {
                            Text("Floating Horizontal Inset:")
                                .frame(width: 190, alignment: .leading)
                            Slider(value: theme.horizontalMargin, in: 0...24, step: 2)
                            Text("\(Int(appState.theme.horizontalMargin)) pt")
                                .frame(width: 45)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Border Width
                        HStack {
                            Text("Border Outline Width:")
                                .frame(width: 190, alignment: .leading)
                            Slider(value: theme.borderWidth, in: 0...3, step: 0.5)
                            Text(String(format: "%.1f pt", appState.theme.borderWidth))
                                .frame(width: 45)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Opacity
                        HStack {
                            Text("Tint Opacity:")
                                .frame(width: 190, alignment: .leading)
                            Slider(value: theme.opacity, in: 0.05...1.0, step: 0.05)
                            Text("\(Int(appState.theme.opacity * 100))%")
                                .frame(width: 45)
                                .font(.system(size: 12, design: .monospaced))
                        }
                        
                        // Drop Shadow Toggle
                        Toggle("Menu Bar Drop Shadow", isOn: theme.hasShadow)
                    }
                }
            }
            .padding(18)
        }
    }
}
