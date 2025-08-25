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
