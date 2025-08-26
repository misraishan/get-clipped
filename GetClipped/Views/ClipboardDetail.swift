//
//  ClipboardDetail.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI

struct ClipboardDetail: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardActions: ClipboardActions

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and type
            HStack(spacing: 12) {
                ClipboardItemIconView(item: item.icon)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.itemType + " Item")
                        .font(.headline)
                    Text("Copied at \(item.timeString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // Content section
            VStack(alignment: .leading, spacing: 8) {
                Text("Content")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ScrollView {
                    Text(item.content)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separatorColor), lineWidth: 1)
                        )
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    Button(action: {
                        clipboardActions.copyToClipboard(item.content)
                    }), label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        clipboardActions.deleteItem(item)
                    }), label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    ClipboardDetail(item: ClipboardItem(
        content: "Sample clipboard content for preview purposes.", timestamp: Date(), type: .text
    ))
}
