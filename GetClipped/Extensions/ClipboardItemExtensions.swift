//
//  ClipboardItemExtensions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//
import Foundation
import PDFKit
import UniformTypeIdentifiers
import TipKit

extension ClipboardItem {
    func openInDefaultApp() {
        if hasExternalData {
            Task {
                let url = await LocalFileManager.instance.loadUrl(withId: id, category: category)
                NSWorkspace.shared.open(url!)
            }
        } else if let data = previewData {
            Task {
                if let url = await LocalFileManager.instance.saveData(data, withId: id, category: category) {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            print("No external data to open for item with id: \(id)")
        }
    }
    
    func revealInFinder() async {
        if category == .file && filePath != nil {
            let url = URL(fileURLWithPath: filePath!)
            NSWorkspace.shared.activateFileViewerSelecting([url])
            return
        }

        if hasExternalData {
            
                let url = await LocalFileManager.instance.loadUrl(withId: id, category: category)
                NSWorkspace.shared.activateFileViewerSelecting([url!])
            
        } else if let data = previewData {
            
                if let url = await LocalFileManager.instance.saveData(data, withId: id, category: category) {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            
        }
    }
    
    var contentPreviewString: String? {
        switch category {
        case .text, .link, .html:
            return content
        default:
            return nil
        }
    }

    var preview: String {
        switch category {
        case .pdf:
            return "PDF Document"
        case .image:
            return "Image"
        case .link:
            return "Link to " + content.getLinkPreview
        case .text, .file, .html:
            return String(content.prefix(50)) + (content.count > 50 ? "..." : "")
        default:
            return "[Unknown]"
        }
    }

    var icon: ClipboardItemIcon {
        switch category {
        case .text:
            return ClipboardItemIcon(icon: "doc.text", color: .indigo)
        case .image:
            return ClipboardItemIcon(icon: "photo", color: .green)
        case .link:
            return ClipboardItemIcon(icon: "link", color: .blue)
        case .pdf:
            return ClipboardItemIcon(icon: "doc.richtext", color: .red)
        case .file:
            return ClipboardItemIcon(icon: "folder", color: .gray)
        case .html:
            return ClipboardItemIcon(icon: "globe", color: .orange)
        default:
            return ClipboardItemIcon(icon: "questionmark.circle", color: .secondary)
        }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }
    
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
}
