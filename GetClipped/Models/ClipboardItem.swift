//
//  ClipboardItem.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//


import Foundation

struct ClipboardItem: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: ClipboardItemType
    
    enum ClipboardItemType {
        case text
        case image
        case rtf
    }
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
}
