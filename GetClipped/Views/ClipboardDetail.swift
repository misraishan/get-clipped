//
//  ClipboardDetail.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import FoundationModels
import SwiftUI
import VisionKit

@available(macOS 26.0, *)
struct ClipboardDetail: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardActions: ClipboardActions

    @State private var showingImageDetail = false
    @State var summarizedText: String?
    @State var loadingSummary = false
    @State var contentTags: [String] = []
    @State var loadingTags = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and type
            HStack(spacing: 12) {
                ClipboardItemIconView(item: item.icon)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.category.rawValue.capitalized)
                        .font(.headline)
                    Text("Copied at \(item.dateTimeString)")
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
                Divider()
                HStack {
                    Spacer()

                    if item.category == .text {
                        Button(action: {
                            Task {
                                loadingSummary = true
                                summarizedText = try? await ClipboardAiActions.shared.summarizeText(item.content)
                                loadingSummary = false

                                print("Debug print for item: ", item)
                            }
                        }) {
                            Label("Generate AI Summary", systemImage: "doc.plaintext")
                        }
                        .buttonStyle(.bordered)

                        Button(action: {
                            Task {
                                loadingTags = true
                                contentTags = try await ClipboardAiActions.shared.createTags(item.content)
                                loadingTags = false
                            }
                        }) {
                            Label("Generate Tags", systemImage: "tag")
                        }
                        .buttonStyle(.bordered)
                    }

                    if item.previewData != nil {
                        if item.category == .file {
                            Button(action: {
                                Task {
                                    await item.revealInFinder()
                                }
                            }) {
                                Label("Show in Finder", systemImage: "folder")
                            }
                            .buttonStyle(.bordered)
                        }

                        Button(action: {
                            item.openInDefaultApp()
                        }) {
                            Label("Open", systemImage: "arrow.up.right.square")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if summarizedText != nil {
                    Divider()

                    Text("Clanker Summary")
                        .font(Font.headline.bold())

                    Text(summarizedText ?? "")
                        .font(.body)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                }

                if loadingSummary {
                    ProgressView("Generating Summary...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 8)
                }

                if !contentTags.isEmpty {
                    Divider()

                    Text("Clanker Tags")
                        .font(Font.headline.bold())

                    HStack {
                        ForEach(contentTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(6)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }

                if loadingTags {
                    ProgressView("Generating Tags...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 8)
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
                if let url = URL(string: item.content) {
                    Link(destination: url) {
                        Text(item.content)
                            .font(.body)
                            .foregroundColor(.blue)
                            .underline()
                    }
                } else {
                    Text("Invalid link")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

            case .file:
                Link(destination: URL(fileURLWithPath: item.content)) {
                    Text(item.contentPreviewString ?? item.content)
                        .font(.body)
                        .foregroundColor(.blue)
                        .underline()
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
