import Foundation
import SwiftUI

/// Section in which a menu bar item resides
public enum ItemSection: String, Codable, CaseIterable, Identifiable, Sendable {
    case shown = "Shown"
    case hidden = "Hidden"
    case alwaysHidden = "Always Hidden"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .shown: return "eye.fill"
        case .hidden: return "eye.slash.fill"
        case .alwaysHidden: return "archivebox.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .shown: return "Always visible in the main menu bar"
        case .hidden: return "Revealed when AleBar is expanded"
        case .alwaysHidden: return "Kept stashed away, accessible via search"
        }
    }
}

/// Represents a detected or configured menu bar item
public struct StatusItemModel: Identifiable, Codable, Hashable, Sendable {
    public var id: String // Bundle ID or custom identifier
    public var name: String
    public var bundleIdentifier: String?
    public var processIdentifier: Int32?
    public var systemSymbol: String
    public var isSystemItem: Bool
    public var section: ItemSection
    public var isGroup: Bool
    public var groupItemIds: [String]
    public var orderIndex: Int
    public var isRunning: Bool
    
    public init(
        id: String,
        name: String,
        bundleIdentifier: String? = nil,
        processIdentifier: Int32? = nil,
        systemSymbol: String = "app.dashed",
        isSystemItem: Bool = false,
        section: ItemSection = .shown,
        isGroup: Bool = false,
        groupItemIds: [String] = [],
        orderIndex: Int = 0,
        isRunning: Bool = true
    ) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.processIdentifier = processIdentifier
        self.systemSymbol = systemSymbol
        self.isSystemItem = isSystemItem
        self.section = section
        self.isGroup = isGroup
        self.groupItemIds = groupItemIds
        self.orderIndex = orderIndex
        self.isRunning = isRunning
    }
}

/// A group of items collapsed into a single menu bar icon
public struct ItemGroup: Identifiable, Codable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var iconSymbol: String
    public var itemIds: [String]
    
    public init(id: String = UUID().uuidString, title: String, iconSymbol: String = "folder.fill", itemIds: [String] = []) {
        self.id = id
        self.title = title
        self.iconSymbol = iconSymbol
        self.itemIds = itemIds
    }
}
