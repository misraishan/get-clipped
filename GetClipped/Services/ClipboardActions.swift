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
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    private var clipboardMonitor: ClipboardMonitor? {
        return ClipboardMonitor.shared
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

        clipboardMonitor?.stopMonitoring()
        
        if item.hasExternalData {
            if let data = await LocalFileManager.instance.loadData(withId: item.id, category: item.category) {
                pasteboard.setData(data, forType: NSPasteboard.PasteboardType(item.pasteboardType))
                clipboardMonitor?.startMonitoring()
            }
            return
        } else {
            if (item.previewData != nil) {
                pasteboard.setData(item.previewData!, forType: NSPasteboard.PasteboardType(item.pasteboardType))
            } else {
                pasteboard.setString(item.content, forType: .string)
                clipboardMonitor?.startMonitoring()
            }
        }
    }
}
