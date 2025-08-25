//
//  ClipboardMonitor.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import Foundation
import AppKit
import SwiftUICore
import SwiftData

class ClipboardMonitor: ObservableObject {
    private let modelContext: ModelContext
    
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
            
            var newItem: ClipboardItem?
            
            // Check for image content first
            if let imageData = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
                newItem = ClipboardItem(
                    content: "",
                    timestamp: Date(),
                    type: .image,
                    image: imageData
                )
            }
            // Check for file URLs that might be images
            else if let fileURLData = pasteboard.data(forType: .fileURL),
                    let urlString = String(data: fileURLData, encoding: .utf8),
                    let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
                    let imageData = try? Data(contentsOf: url),
                    NSImage(data: imageData) != nil {
                newItem = ClipboardItem(
                    content: url.lastPathComponent,
                    timestamp: Date(),
                    type: .image,
                    image: imageData
                )
            }
            // Check for text content
            else if let string = pasteboard.string(forType: .string), !string.isEmpty {
                var itemType = ClipboardItem.ClipboardItemType.text
                
                if (string.isValidURL) {
                    itemType = .link
                }

                newItem = ClipboardItem(
                    content: string,
                    timestamp: Date(),
                    type: itemType
                )
            }
            
            // Save the new item if we found content
            if let newItem = newItem {
                // Check for duplicates by fetching the most recent item
                do {
                    var descriptor = FetchDescriptor<ClipboardItem>(
                        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                    )
                    descriptor.fetchLimit = 1
                    let mostRecent = try modelContext.fetch(descriptor).first
                    
                    // For images, compare the image data; for text, compare content
                    let isDuplicate: Bool
                    if newItem.type == .image {
                        isDuplicate = mostRecent?.image == newItem.image
                    } else {
                        isDuplicate = mostRecent?.content == newItem.content
                    }
                    
                    if !isDuplicate {
                        modelContext.insert(newItem)
                        try modelContext.save() // Force save to trigger UI updates
                    }
                } catch {
                    print("Error checking/saving clipboard item: \(error)")
                }
            }
        }
    }
}
