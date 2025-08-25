//
//  ClipboardActions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation
import AppKit
import SwiftData

class ClipboardActions: ObservableObject {
    var clipboardMonitor: ClipboardMonitor
    private let modelContext: ModelContext
    
    init(clipboardMonitor: ClipboardMonitor, modelContext: ModelContext) {
        self.clipboardMonitor = clipboardMonitor
        self.modelContext = modelContext
    }
    
    func addItem(content: String = "New Clipboard Item", type: ClipboardItem.ClipboardItemType = .text) {
        let newItem = ClipboardItem(
            content: content,
            timestamp: Date(),
            type: type
        )
        modelContext.insert(newItem)
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func deleteItem(_ item: ClipboardItem) {
        modelContext.delete(item)
    }
    
    func clearHistory() {
        try? modelContext.delete(model: ClipboardItem.self)
    }
}
