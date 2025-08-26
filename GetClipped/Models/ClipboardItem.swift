//
//  ClipboardItem.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation
import SwiftData
import SwiftUICore

@Model
class ClipboardItem: Identifiable, Hashable {
    var id: String
    var content: String
    var timestamp: Date
    var type: ClipboardItemType

    @Attribute
    var data: Data?

    init(content: String = "", timestamp: Date, type: ClipboardItemType, data _: Data? = nil) {
        id = UUID().uuidString

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
