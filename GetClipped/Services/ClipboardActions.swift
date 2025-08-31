//
//  ClipboardActions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import AppKit
import Foundation
import SwiftData

class ClipboardActions: ObservableObject {
    var clipboardMonitor: ClipboardMonitor
    private let modelContext: ModelContext

    init(clipboardMonitor: ClipboardMonitor, modelContext: ModelContext) {
        self.clipboardMonitor = clipboardMonitor
        self.modelContext = modelContext
    }

    func addItem(content: String = "New Editable Clipboard Item") {
        let newItem = ClipboardItem(
            content: content,
            timestamp: Date(),
            pasteboardType: .string
        )
        modelContext.insert(newItem)
    }

    func deleteItem(_ item: ClipboardItem) {
        modelContext.delete(item)
    }

    func clearHistory() {
        try? modelContext.delete(model: ClipboardItem.self)
    }

    func getImage(from item: ClipboardItem) -> NSImage? {
        guard item.category == .image,
              let data = item.data else { return nil }
        return NSImage(data: data)
    }

    func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        clipboardMonitor.stopMonitoring()

        if let data = item.data {
            pasteboard.setData(data, forType: NSPasteboard.PasteboardType(item.pasteboardType))
        } else {
            pasteboard.setString(item.content, forType: .string)
        }

        clipboardMonitor.startMonitoring()
    }
}
