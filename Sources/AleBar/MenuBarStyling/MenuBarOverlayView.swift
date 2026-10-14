import SwiftUI
import AppKit

public struct MenuBarOverlayView: View {
    @ObservedObject var appState = AppState.shared
    
    public init() {}
    
    private var theme: MenuBarTheme {
        appState.theme
    }
    
    private var tintColor: Color {
        Color(hex: theme.tintColorHex) ?? Color.black.opacity(0.3)
    }
    
    private var secondaryColor: Color {
        Color(hex: theme.secondaryColorHex) ?? Color.black.opacity(0.6)
    }
    
    private var borderColor: Color {
        Color(hex: theme.borderColorHex) ?? Color.white.opacity(0.2)
    }
    
    private var shadowColor: Color {
        Color(hex: theme.shadowColorHex) ?? Color.black.opacity(0.3)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if theme.isEnabled && theme.preset != .none {
                let width = max(0, geometry.size.width - (theme.horizontalMargin * 2))
                let height = max(0, geometry.size.height - theme.verticalMargin - theme.heightInset)
                
                ZStack {
                    // Base shape: Rounded pill or edge-to-edge
                    let shape = RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    
                    // Background material / gradient
                    Group {
                        if theme.hasGradient {
                            LinearGradient(
                                colors: [
                                    tintColor.opacity(theme.opacity),
                                    secondaryColor.opacity(theme.opacity)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            tintColor.opacity(theme.opacity)
                        }
                    }
                    .clipShape(shape)
                    .background(
                        // Material blur
                        shape
                            .fill(.ultraThinMaterial)
                            .opacity(theme.blurIntensity)
                    )
                    
                    // Optional Border outline
                    if theme.borderWidth > 0 {
                        shape
                            .stroke(borderColor, lineWidth: theme.borderWidth)
                    }
                }
                .frame(width: width, height: height)
                .shadow(
                    color: theme.hasShadow ? shadowColor.opacity(0.4) : Color.clear,
                    radius: theme.shadowRadius,
                    x: 0,
                    y: 3
                )
                .position(x: geometry.size.width / 2, y: (height / 2) + theme.verticalMargin)
            } else {
                Color.clear
            }
        }
        .allowsHitTesting(false)
    }
}

// Color Hex Extension
public extension Color {
    init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        guard cleanHex.count == 6 || cleanHex.count == 8 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        if cleanHex.count == 6 {
            let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = Double(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else {
            let r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            let g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            let b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            let a = Double(rgbValue & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, opacity: a)
        }
    }
}
