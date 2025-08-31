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
import UniformTypeIdentifiers

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

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkIfClipboardUpdated()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkIfClipboardUpdated() {
        let pasteboard = NSPasteboard.general

        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let availableTypes = pasteboard.types else { return }

        for type in availableTypes {
            if let item = createClipboardItem(from: pasteboard, type: type) {
                saveItemIfNew(item)
                break // first/most preferred type processed
            }
        }
    }

    private func isURLType(_ type: NSPasteboard.PasteboardType) -> Bool {
        return type == .URL || type.rawValue == "public.url-name"
    }

    private func isTextType(_ type: NSPasteboard.PasteboardType) -> Bool {
        return type == .string || type == .rtf || type == .html
    }

    private func isImageType(_ type: NSPasteboard.PasteboardType) -> Bool {
        return type == .png || type == .tiff
    }

    private func createURLClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        let urlString: String?

        if type.rawValue == "public.url-name" { // electron apps have its own clipboard type when doing `clipboard.writeBookmark` I think
            urlString = pasteboard.string(forType: type)
        } else {
            urlString = pasteboard.string(forType: .string) ?? pasteboard.string(forType: .URL)
        }

        guard let urlStr = urlString, !urlStr.isEmpty else { return nil }

        return ClipboardItem(
            content: urlStr,
            timestamp: timestamp,
            pasteboardType: .URL
        )
    }

    private func createTextClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        guard let string = pasteboard.string(forType: .string), !string.isEmpty else { return nil }

        return ClipboardItem(
            content: string,
            timestamp: timestamp,
            pasteboardType: type
        )
    }

    private func createImageClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        guard let imageData = pasteboard.data(forType: type) else { return nil }

        // Try to get image dimensions for content description
        let image = NSImage(data: imageData)
        let dimensions = image?.size ?? .zero
        let contentDescription = "Image (\(Int(dimensions.width))×\(Int(dimensions.height)))"

        return ClipboardItem(
            content: contentDescription,
            timestamp: timestamp,
            pasteboardType: type,
            data: imageData
        )
    }

    private func createPDFClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        guard let pdfData = pasteboard.data(forType: .pdf) else { return nil }

        return ClipboardItem(
            content: "PDF Document",
            timestamp: timestamp,
            pasteboardType: type,
            data: pdfData
        )
    }

    private func createGenericDataClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        guard let data = pasteboard.data(forType: type) else { return nil }

        let description = type.rawValue.split(separator: ".").last.map(String.init)?.capitalized ?? "Unknown Data"

        return ClipboardItem(
            content: description,
            timestamp: timestamp,
            pasteboardType: type,
            data: data
        )
    }

    private func createFileURLClipboardItem(
        pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType,
        timestamp: Date
    ) -> ClipboardItem? {
        guard let string = pasteboard.string(forType: .fileURL),
              let url = URL(string: string) else { return nil }

        let fileName = url.lastPathComponent
        let contentDescription = "File: \(fileName)"

        return ClipboardItem(
            content: contentDescription,
            timestamp: timestamp,
            pasteboardType: type
        )
    }

    private func createClipboardItem(
        from pasteboard: NSPasteboard,
        type: NSPasteboard.PasteboardType
    ) -> ClipboardItem? {
        let timestamp = Date()

        if isURLType(type) {
            return createURLClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
        }

        if isTextType(type) {
            if (pasteboard.string(forType: .string)?.isValidURL ?? false) {
                return createURLClipboardItem(pasteboard: pasteboard, type: NSPasteboard.PasteboardType.URL, timestamp: timestamp)
            }
            return createTextClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
        }

        if isImageType(type) {
            return createImageClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
        }

        if type == .pdf {
            return createPDFClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
        }

        if type == .fileURL {
            return createFileURLClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
        }

        return createGenericDataClipboardItem(pasteboard: pasteboard, type: type, timestamp: timestamp)
    }

    private func saveItemIfNew(_ newItem: ClipboardItem) {
        do {
            // Capture the values we need for the predicate
            let contentToCheck = newItem.content
            let typeToCheck = newItem.pasteboardType

            // Check for duplicates by content and type
            var descriptor = FetchDescriptor<ClipboardItem>(
                predicate: #Predicate<ClipboardItem> { item in
                    item.content == contentToCheck && item.pasteboardType == typeToCheck
                },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = 1

            let existingItems = try modelContext.fetch(descriptor)

            // Only save if we don't have this exact content already
            if existingItems.isEmpty {
                modelContext.insert(newItem)
                try modelContext.save()
            }
        } catch {
            print("Error checking/saving clipboard item: \(error)")
        }
    }
}
