//
//  ClipboardMonitor.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import AppKit
import Foundation
import SwiftData
import SwiftUICore

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

            // Get the clipboard content
            if let string = pasteboard.string(forType: .string), !string.isEmpty {
                var itemType = ClipboardItem.ClipboardItemType.text

                if string.isValidURL {
                    itemType = .link
                }

                let newItem = ClipboardItem(
                    content: string,
                    timestamp: Date(),
                    type: itemType
                )

                // Check for duplicates by fetching the most recent item
                do {
                    var descriptor = FetchDescriptor<ClipboardItem>(
                        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                    )
                    descriptor.fetchLimit = 1
                    let mostRecent = try modelContext.fetch(descriptor).first

                    if mostRecent?.content != string {
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
