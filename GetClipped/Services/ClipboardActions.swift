//
//  ClipboardActions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation
import AppKit

class ClipboardActions: ObservableObject {
    let clipboardMonitor: ClipboardMonitor
    
    init(clipboardMonitor: ClipboardMonitor) {
        self.clipboardMonitor = clipboardMonitor
    }
    
    func addItem(content: String = "New Clipboard Item", type: ClipboardItem.ClipboardItemType = .text) {
        let newItem = ClipboardItem(
            content: content,
            timestamp: Date(),
            type: type
        )
        clipboardMonitor.clipboardItems.insert(newItem, at: 0)
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func deleteItem(_ item: ClipboardItem) {
        clipboardMonitor.clipboardItems.removeAll { $0.id == item.id }
    }
    
    func clearHistory() {
        clipboardMonitor.clipboardItems.removeAll()
    }
}
