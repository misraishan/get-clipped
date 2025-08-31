//
//  ClipboardItem.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import AppKit
import Foundation
import SwiftData
import SwiftUICore
import UniformTypeIdentifiers

@Model
class ClipboardItem: Identifiable, Hashable {
    var id: String
    var content: String
    var timestamp: Date
    var pasteboardType: String
    var utType: String?

    @Attribute(.externalStorage)
    var data: Data?

    init(content: String = "", timestamp: Date, pasteboardType: NSPasteboard.PasteboardType, data: Data? = nil) {
        id = UUID().uuidString

        self.content = content
        self.timestamp = timestamp
        self.pasteboardType = pasteboardType.rawValue

        utType = UTType(pasteboardType.rawValue)?.identifier
        self.data = data
    }

    // converts the pasteboard string type back to a PasteboardType
    var type: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(pasteboardType)
    }

    // converts the pasteboard string type back to a category
    var category: ClipboardItemCategory {
        guard let utType = utType else { return .text }

        let type = UTType(utType)

        if type?.conforms(to: .url) == true { // url technically conforms to text so put it on top
            return .link
        } else if type?.conforms(to: .text) == true {
            return .text
        } else if type?.conforms(to: .image) == true {
            return .image
        } else if type?.conforms(to: .pdf) == true {
            return .pdf
        } else if type?.conforms(to: .data) == true {
            return .file
        } else if type?.conforms(to: .html) == true {
            return .html
        }
        return .unknown
    }

    // human readable description of the pasteboard type
    var typeDescription: String {
        guard let utType = utType else { return "Unknown" }

        let type = UTType(utType)

        print(type?.localizedDescription ?? "Unknown type for \(utType)", pasteboardType)
        return type?.localizedDescription ?? pasteboardType
    }

    enum ClipboardItemCategory: String, CaseIterable {
        case text = "Text"
        case image = "Image"
        case pdf = "PDF"
        case file = "File"
        case link = "Link"
        case html = "HTML"
        case unknown = "Unknown"
    }
}

struct ClipboardItemIcon {
    let icon: String
    let color: Color
}
