import Foundation
import SwiftUI

public enum StatusIconStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case aleMug = "Ale Mug (Signature 🍺)"
    case dots = "Minimal Dots (···)"
    case martini = "Cocktail Glass (🍸)"
    case chevron = "Chevron (< / >)"
    case star = "Minimal Star (✦)"
    case pill = "Compact Capsule"
    case cube = "Minimal Diamond (◈)"
    
    public var id: String { rawValue }
    
    public var previewSymbol: String {
        switch self {
        case .aleMug: return "mug.fill"
        case .dots: return "ellipsis"
        case .martini: return "wineglass"
        case .chevron: return "chevron.left"
        case .star: return "sparkle"
        case .pill: return "capsule.portrait"
        case .cube: return "diamond"
        }
    }
    
    public func iconImage(isExpanded: Bool) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        image.lockFocus()
        
        let bounds = NSRect(origin: .zero, size: size)
        NSColor.clear.setFill()
        bounds.fill()
        
        let color = NSColor.labelColor
        color.setFill()
        color.setStroke()
        
        switch self {
        case .aleMug:
            // Ale mug body
            let mugRect = NSRect(x: 4, y: 4, width: 10, height: 13)
            let mugPath = NSBezierPath(roundedRect: mugRect, xRadius: 2.5, yRadius: 2.5)
            mugPath.lineWidth = 1.4
            mugPath.stroke()
            
            // Handle on the right
            let handle = NSBezierPath()
            handle.move(to: NSPoint(x: 14, y: 14))
            handle.curve(to: NSPoint(x: 14, y: 7), controlPoint1: NSPoint(x: 18.5, y: 14), controlPoint2: NSPoint(x: 18.5, y: 7))
            handle.lineWidth = 1.4
            handle.stroke()
            
            // Foam / Ale Fill
            if isExpanded {
                let fillRect = NSRect(x: 5, y: 5, width: 8, height: 9)
                let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 1.5, yRadius: 1.5)
                fillPath.fill()
            }
            
            // Foam on top
            let foam1 = NSBezierPath(ovalIn: NSRect(x: 4, y: 14, width: 4.5, height: 4))
            let foam2 = NSBezierPath(ovalIn: NSRect(x: 7.5, y: 14.5, width: 4.5, height: 4.5))
            let foam3 = NSBezierPath(ovalIn: NSRect(x: 11, y: 14, width: 3.5, height: 3.5))
            foam1.fill()
            foam2.fill()
            foam3.fill()
            
        case .dots:
            let dotRadius: CGFloat = 2.0
            let spacing: CGFloat = 5.0
            let startX: CGFloat = (size.width - (dotRadius * 6 + spacing * 2)) / 2 + dotRadius
            let centerY: CGFloat = size.height / 2
            
            for i in 0..<3 {
                let x = startX + CGFloat(i) * (dotRadius * 2 + spacing)
                let dotRect = NSRect(x: x - dotRadius, y: centerY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                let path = NSBezierPath(ovalIn: dotRect)
                path.fill()
            }
            if isExpanded {
                let borderRect = NSRect(x: 2, y: 3, width: 18, height: 16)
                let borderPath = NSBezierPath(roundedRect: borderRect, xRadius: 4, yRadius: 4)
                borderPath.lineWidth = 1.0
                borderPath.stroke()
            }
            
        case .martini:
            let path = NSBezierPath()
            path.lineWidth = 1.5
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.move(to: NSPoint(x: 5, y: 16))
            path.line(to: NSPoint(x: 17, y: 16))
            path.line(to: NSPoint(x: 11, y: 9))
            path.close()
            path.move(to: NSPoint(x: 11, y: 9))
            path.line(to: NSPoint(x: 11, y: 5))
            path.move(to: NSPoint(x: 7, y: 5))
            path.line(to: NSPoint(x: 15, y: 5))
            path.stroke()
            
            if isExpanded {
                let liquidPath = NSBezierPath()
                liquidPath.move(to: NSPoint(x: 7, y: 13))
                liquidPath.line(to: NSPoint(x: 15, y: 13))
                liquidPath.line(to: NSPoint(x: 11, y: 9))
                liquidPath.close()
                liquidPath.fill()
            }
            
        case .chevron:
            let path = NSBezierPath()
            path.lineWidth = 2.0
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            if isExpanded {
                path.move(to: NSPoint(x: 9, y: 16))
                path.line(to: NSPoint(x: 14, y: 11))
                path.line(to: NSPoint(x: 9, y: 6))
            } else {
                path.move(to: NSPoint(x: 13, y: 16))
                path.line(to: NSPoint(x: 8, y: 11))
                path.line(to: NSPoint(x: 13, y: 6))
            }
            path.stroke()
            
        case .star:
            let path = NSBezierPath()
            let center = NSPoint(x: 11, y: 11)
            let radius: CGFloat = 6.0
            let innerRadius: CGFloat = 2.5
            let points = 4
            for i in 0..<(points * 2) {
                let r = (i % 2 == 0) ? radius : innerRadius
                let angle = (CGFloat(i) * CGFloat.pi / CGFloat(points)) - (CGFloat.pi / 2)
                let pt = NSPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
                if i == 0 { path.move(to: pt) } else { path.line(to: pt) }
            }
            path.close()
            if isExpanded {
                path.fill()
            } else {
                path.lineWidth = 1.5
                path.stroke()
            }
            
        case .pill:
            let rect = NSRect(x: 4, y: 7, width: 14, height: 8)
            let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
            if isExpanded {
                path.fill()
            } else {
                path.lineWidth = 1.5
                path.stroke()
            }
            
        case .cube:
            let rect = NSRect(x: 6, y: 6, width: 10, height: 10)
            let path = NSBezierPath(roundedRect: rect, xRadius: 2, yRadius: 2)
            if isExpanded {
                path.fill()
            } else {
                path.lineWidth = 1.5
                path.stroke()
            }
        }
        
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
