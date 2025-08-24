//
//  ClipboardItem.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//


import Foundation
import SwiftUICore
import SwiftData

@Model
class ClipboardItem: Identifiable, Hashable {
    var id: String
    var content: String
    var timestamp: Date
    var type: ClipboardItemType
    
    init(content: String, timestamp: Date, type: ClipboardItemType) {
        self.id = UUID().uuidString

        self.content = content
        self.timestamp = timestamp
        self.type = type
    }
    
    enum ClipboardItemType: String, Codable {
        case text = "Text"
        case image = "Image"
        case link = "Link"
    }
}

struct ClipboardItemIcon {
    let icon: String
    let color: Color
}

extension ClipboardItem {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }
    
    var preview: String {
        String(content.prefix(50)) + (content.count > 50 ? "..." : "")
    }
    
    var icon: ClipboardItemIcon {
        switch type {
        case .text:
            return .init(icon: "doc.text", color: .gray)
        case .image:
            return .init(icon: "photo", color: .green)
        case .link:
            return .init(icon: "link", color: .blue)
        }
    }
    
    var itemType: String {
        return type.rawValue
    }
}
