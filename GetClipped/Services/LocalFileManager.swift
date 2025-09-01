//
//  DocumentWriter.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/31/25.
//

import AppKit
import Foundation
import PDFKit

/// Service that helps read/write files based on ID to local file system
class LocalFileManager {
    static let instance = LocalFileManager()
    let folderName = "GetClipped"
    
    private let documentsURL: URL
    private let clipboardDirectory: URL
    
    private init() {
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        clipboardDirectory = documentsURL.appendingPathComponent(folderName)
        
        try? FileManager.default.createDirectory(at: clipboardDirectory, withIntermediateDirectories: true)
    }
    
    func saveData(_ data: Data, withId id: String, category: ClipboardItem.ClipboardItemCategory) async -> URL? {
        let fileName = "\(id).\(fileExtension(for: category))"
        let fileURL = clipboardDirectory.appendingPathComponent(fileName)
                
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving data to file: \(error)")
            return nil
        }
    }
    
    func loadData(withId id: String, category: ClipboardItem.ClipboardItemCategory) async -> Data? {
        let fileURL = clipboardDirectory.appendingPathComponent("\(id).\(fileExtension(for: category))")
        return try? Data(contentsOf: fileURL)
    }
    
    func loadUrl(withId id: String, category: ClipboardItem.ClipboardItemCategory) async -> URL? {
        let fileURL = clipboardDirectory.appendingPathComponent("\(id).\(fileExtension(for: category))")
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func generatePreview(from data: Data, category: ClipboardItem.ClipboardItemCategory) -> Data? {
        switch category {
        case .image:
            return generateImagePreview(from: data)
        case .pdf:
            return generatePdfPreview(from: data)
        default:
            return nil
        }
    }
    
    private func generatePdfPreview(from data: Data) -> Data? {
        /// Returns a higher quality PDF thumbnail for larger display
        var pdfThumbnail: NSImage? {
            guard let pdfDocument = PDFDocument(data: data),
                  let firstPage = pdfDocument.page(at: 0) else { return nil }
            let thumbnailSize = CGSize(width: 800, height: 1040)
            return firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
        }
        
        return pdfThumbnail?.tiffRepresentation
    }
    
    private func generateImagePreview(from data: Data) -> Data? {
        guard let nsImage = NSImage(data: data) else { return nil }
        
        let maxSize: CGFloat = 200
        let size = nsImage.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        nsImage.draw(in: NSRect(origin: .zero, size: newSize))
        thumbnail.unlockFocus()
        
        return thumbnail.tiffRepresentation
    }

    private func fileExtension(for category: ClipboardItem.ClipboardItemCategory) -> String {
        switch category {
        case .text: return "txt"
        case .image: return "png"
        case .pdf: return "pdf"
        case .html: return "html"
        default: return "data"
        }
    }
}
