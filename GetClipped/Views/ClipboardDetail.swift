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

//                if item.data != nil, let imageData = clipboardActions.getImage(from: item)?.tiffRepresentation, let nsImage = NSImage(data: imageData) {
//                    Image(nsImage: nsImage)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(maxHeight: 200)
//                        .cornerRadius(8)
//                        .padding(.bottom, 8)
//                }

                contentPreview(for: item)

                ScrollView {
                    Text(item.content)
                        .font(.body)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 8) {
                    Button(action: async {
                        await clipboardActions.copyToClipboard(item)
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
        if item.data != nil {
            switch item.category {
            case .image:
                Image(nsImage: NSImage(data: item.data!) ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
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

            case .pdf:
                VStack(alignment: .leading, spacing: 8) {
                    // Show PDF thumbnail if available
                    if let thumbnail = item.pdfThumbnail {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .onTapGesture {
                                item.openInDefaultApp()
                            }
                    }

                    // Show PDF title/content preview
                    Text(item.contentPreviewString ?? "PDF Document")
                        .font(.body)
                        .foregroundColor(.primary)
                }

            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ClipboardDetail(item: ClipboardItem(
        content: "Sample clipboard content for preview purposes.", timestamp: Date(), pasteboardType: .string
    ))
}
