//
//  ClipboardItemExtensions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//
import Foundation
import PDFKit
import UniformTypeIdentifiers

extension ClipboardItem {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }
    
    // TODO: Complete this function to open files in default apps
    func openInDefaultApp() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsUrl.appendingPathComponent("temp_\(id)").appendingPathExtension(category == .pdf ? "pdf" : "txt")
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
}
