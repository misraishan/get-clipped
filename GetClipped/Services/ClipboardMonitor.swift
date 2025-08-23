//
//  ClipboardMonitor.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
                
        // Check if clipboard content changed
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            // Get the clipboard content
            if let string = pasteboard.string(forType: .string), !string.isEmpty {
                let newItem = ClipboardItem(
                    content: string,
                    timestamp: Date(),
                    type: .text
                )
                
                // Add to beginning of array, avoid duplicates
                if clipboardItems.first?.content != string {
                    clipboardItems.insert(newItem, at: 0)
                    
                    // Keep only last 50 items
                    if clipboardItems.count > 50 {
                        clipboardItems.removeLast()
                    }
                }
            }
        }
    }
}
