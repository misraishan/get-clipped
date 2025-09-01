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
    /// Acts as metadata if no previewdata or file is stored
    var content: String
    var timestamp: Date
    var pasteboardType: String
    var category: ClipboardItemCategory

    // the following are specific to storing files and not relying
    // completely on swiftdata
    @Attribute(.externalStorage)
    var previewData: Data?
    
    var fileSize: Int64?
    var filePath: String?
    var fileName: String?

    init(content: String = "", timestamp: Date, pasteboardType: NSPasteboard.PasteboardType, data: Data? = nil, category: ClipboardItemCategory = .unknown) async {
        id = UUID().uuidString

        self.content = content
        self.timestamp = timestamp
        self.pasteboardType = pasteboardType.rawValue
        self.category = category

        // Only have data restriction if category is image, else store all data types to disk
        if let data = data, (category == .image && data.count > 1024 * 1024 || category != .image) {
            self.filePath = await LocalFileManager.instance.saveData(data, withId: id, category: category)?.path
            self.fileSize = Int64(data.count)
                        
            if category == .image || category == .pdf {
                self.previewData = LocalFileManager.instance.generatePreview(from: data, category: category)
            }
        } else {
            self.previewData = data
            self.fileSize = Int64(data?.count ?? 0)
        }
    }

    /// converts the pasteboard string type back to a PasteboardType
    var type: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(pasteboardType)
    }

    /// human readable description of the pasteboard type
    var typeDescription: String {
        return category.rawValue
    }
    
    /// Allows for lazy loading of data by fetching preview, and then loading full data from disk if needed
    func loadData() async -> Data? {
        if filePath != nil && previewData == nil {
            return await LocalFileManager.instance.loadData(withId: id, category: category)
        }
        return previewData
    }
    
    var hasExternalData: Bool {
        return filePath != nil
    }

    enum ClipboardItemCategory: String, CaseIterable, Codable, Sendable {
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
