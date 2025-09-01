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
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.category.rawValue.capitalized + " Item")
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

                contentPreview(for: item)

                ScrollView {
                    Text(item.content)
                        .font(.body)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 1024)

                if item.previewData != nil {
                    Divider()
                    HStack {
                        Spacer()

                        Button(action: {
                            item.openInDefaultApp()
                        }) {
                            Label("Open", systemImage: "arrow.up.right.square")
                        }
                        .buttonStyle(.bordered)
                    }
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
                        Task {
                            await clipboardActions.copyToClipboard(item)
                        }
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        clipboardActions.deleteItem(item)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
    }

    @ViewBuilder
    private func contentPreview(for item: ClipboardItem) -> some View {
        if item.previewData != nil {
            switch item.category {
            case .image, .pdf:
                Image(nsImage: NSImage(data: item.previewData!) ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 1024, maxHeight: 1024)
                    .cornerRadius(8)
                    .padding(.bottom, 8)
                    .onTapGesture {
                        item.openInDefaultApp()
                    }

            case .link:
                Link(destination: URL(string: item.content) ?? URL(string: "https://www.apple.com")!) {
                    Text(item.content)
                        .font(.body)
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            item.openInDefaultApp()
                        }
                }

            case .file:
                Link(destination: URL(fileURLWithPath: item.content)) {
                    Text(item.contentPreviewString ?? item.content)
                        .font(.body)
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            item.openInDefaultApp()
                        }
                }

            case .text:
//                show text file embedded rather than pulling all the text out
                if let data = item.previewData, let text = String(data: data, encoding: .utf8) {
                    ScrollView {
                        Text(text)
                            .font(.body)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 512)
                } else {
                    Text(item.contentPreviewString ?? item.content)
                        .font(.body)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }

            default:
                EmptyView()
            }
        }
    }
}
