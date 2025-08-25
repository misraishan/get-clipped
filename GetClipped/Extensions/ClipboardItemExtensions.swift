//
//  ClipboardItemExtensions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//
import Foundation

extension ClipboardItem {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }
    
    var preview: String {
        switch type {
            case .image:
                return "[Image]"
            case .link:
                return "Link to " + content.getLinkPreview
            default:
                return String(content.prefix(50)) + (content.count > 50 ? "..." : "")
        }
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
