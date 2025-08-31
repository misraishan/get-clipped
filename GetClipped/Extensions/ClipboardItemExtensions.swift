//
//  ClipboardItemExtensions.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//
import Foundation
import UniformTypeIdentifiers
import PDFKit

extension ClipboardItem {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: timestamp)
    }
    
    private func getPdfPreview() -> String {
        guard let data, let pdfDoc = PDFDocument(data: data) else { return "PDF Document" }
        return pdfDoc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ?? "PDF Document"
    }


    var preview: String {
        switch category {
        case .image:
            return "Image"
        case .link:
            return "Link to " + content.getLinkPreview
        case .text, .pdf, .file, .html:
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
            return ClipboardItemIcon(icon: "doc", color: .gray)
        case .html:
            return ClipboardItemIcon(icon: "globe", color: .orange)
        case .unknown:
            return ClipboardItemIcon(icon: "questionmark.circle", color: .secondary)
        }
    }

    var itemType: String {
        return UTType(pasteboardType)?.localizedDescription ?? "Unknown"
    }
}
