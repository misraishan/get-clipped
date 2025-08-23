//
//  ClipboardItem.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//


import Foundation
import SwiftUICore

struct ClipboardItem: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: ClipboardItemType
    
    enum ClipboardItemType: String {
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
    
    static func detectType(from content: String) -> ClipboardItemType {
        if content.hasPrefix("http://") || content.hasPrefix("https://") || content.hasPrefix("www.") {
            return .link
        }
        // Add more detection logic as needed
        return .text
    }
}
