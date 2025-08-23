//
//  ClipboardDetail.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI

struct ClipboardDetail: View
{
    let item: ClipboardItem
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Content:")
                .font(.headline)
            ScrollView {
                Text(item.content)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            Text("Copied at: \(item.timeString)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem {
                Button(action: {
                    copyToClipboard(item.content)
                }) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                }
            }
        
            ToolbarItem {
                Button(action: {
                    // Delete action placeholder
                }) {
                    Label("Delete Item", systemImage: "trash")
                }
            }

        }
    }
}

#Preview {
    ClipboardDetail(item: ClipboardItem(content: "Sample clipboard content for preview purposes.", timestamp: Date(), type: .text))
}
