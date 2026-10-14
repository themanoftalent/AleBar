import Foundation
import SwiftUI

public enum ThemePreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case none = "Default (System)"
    case liquidGlass = "Liquid Glass (Modern Frosted)"
    case darkFrosted = "Deep Frosted Night"
    case modernPill = "Floating Island Pill"
    case sunsetGlow = "Sunset Gradient"
    case neonCyber = "Cyber Neon Accent"
    case cleanWhite = "Clean Minimalist"
    
    public var id: String { rawValue }
}

public struct MenuBarTheme: Codable, Equatable, Sendable {
    public var isEnabled: Bool
    public var preset: ThemePreset
    
    // Tint & Color
    public var tintColorHex: String
    public var secondaryColorHex: String
    public var hasGradient: Bool
    public var opacity: Double
    
    // Geometry & Shape
    public var cornerRadius: Double // 0 = standard edge-to-edge, > 0 = floating rounded bar
    public var horizontalMargin: Double // Inset from screen edges (floating bar effect)
    public var verticalMargin: Double // Inset from top of display
    public var heightInset: Double // Height adjustment
    
    // Border & Shadow
    public var borderWidth: Double
    public var borderColorHex: String
    public var hasShadow: Bool
    public var shadowRadius: Double
    public var shadowColorHex: String
    
    // Material Blur
    public var blurIntensity: Double
    public var isVibrant: Bool
    
    public static var defaultTheme: MenuBarTheme {
        MenuBarTheme(
            isEnabled: false,
            preset: .none,
            tintColorHex: "#000000",
            secondaryColorHex: "#1A1A2E",
            hasGradient: false,
            opacity: 0.25,
            cornerRadius: 0.0,
            horizontalMargin: 0.0,
            verticalMargin: 0.0,
            heightInset: 0.0,
            borderWidth: 0.0,
            borderColorHex: "#FFFFFF",
            hasShadow: false,
            shadowRadius: 5.0,
            shadowColorHex: "#000000",
            blurIntensity: 0.8,
            isVibrant: true
        )
    }
    
    public static var liquidGlassTheme: MenuBarTheme {
        MenuBarTheme(
            isEnabled: true,
            preset: .liquidGlass,
            tintColorHex: "#FFFFFF",
            secondaryColorHex: "#E0E5EC",
            hasGradient: true,
            opacity: 0.18,
            cornerRadius: 12.0,
            horizontalMargin: 10.0,
            verticalMargin: 4.0,
            heightInset: 2.0,
            borderWidth: 1.0,
            borderColorHex: "#FFFFFF",
            hasShadow: true,
            shadowRadius: 8.0,
            shadowColorHex: "#000000",
            blurIntensity: 0.9,
            isVibrant: true
        )
    }
    
    public static var modernPillTheme: MenuBarTheme {
        MenuBarTheme(
            isEnabled: true,
            preset: .modernPill,
            tintColorHex: "#111827",
            secondaryColorHex: "#1F2937",
            hasGradient: true,
            opacity: 0.85,
            cornerRadius: 16.0,
            horizontalMargin: 16.0,
            verticalMargin: 6.0,
            heightInset: 4.0,
            borderWidth: 1.2,
            borderColorHex: "#374151",
            hasShadow: true,
            shadowRadius: 12.0,
            shadowColorHex: "#000000",
            blurIntensity: 1.0,
            isVibrant: false
        )
    }
    
    public static var sunsetGlowTheme: MenuBarTheme {
        MenuBarTheme(
            isEnabled: true,
            preset: .sunsetGlow,
            tintColorHex: "#FF4E50",
            secondaryColorHex: "#F9D423",
            hasGradient: true,
            opacity: 0.28,
            cornerRadius: 14.0,
            horizontalMargin: 12.0,
            verticalMargin: 4.0,
            heightInset: 2.0,
            borderWidth: 1.0,
            borderColorHex: "#FFB347",
            hasShadow: true,
            shadowRadius: 10.0,
            shadowColorHex: "#FF4E50",
            blurIntensity: 0.8,
            isVibrant: true
        )
    }
    
    public static var neonCyberTheme: MenuBarTheme {
        MenuBarTheme(
            isEnabled: true,
            preset: .neonCyber,
            tintColorHex: "#0F172A",
            secondaryColorHex: "#06B6D4",
            hasGradient: true,
            opacity: 0.75,
            cornerRadius: 10.0,
            horizontalMargin: 8.0,
            verticalMargin: 3.0,
            heightInset: 2.0,
            borderWidth: 1.5,
            borderColorHex: "#06B6D4",
            hasShadow: true,
            shadowRadius: 15.0,
            shadowColorHex: "#0891B2",
            blurIntensity: 1.0,
            isVibrant: false
        )
    }
}
