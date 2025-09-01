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

    func addItem(content: String = "New Editable Clipboard Item") async {
        let newItem = await ClipboardItem(
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

    func copyToClipboard(_ item: ClipboardItem) async {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        clipboardMonitor.stopMonitoring()
        
        if item.hasExternalData {
            await LocalFileManager.instance.loadData(withId: item.id, category: item.category).flatMap { data in
                pasteboard.setData(data, forType: NSPasteboard.PasteboardType(item.pasteboardType))
                clipboardMonitor.startMonitoring()
            }
            return
        } else {
            if (item.previewData != nil) {
                pasteboard.setData(item.previewData!, forType: NSPasteboard.PasteboardType(item.pasteboardType))
            } else {
                pasteboard.setString(item.content, forType: .string)
                clipboardMonitor.startMonitoring()
            }
        }
    }
}
