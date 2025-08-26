//
//  MenuBarContentView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//

import SwiftData
import SwiftUI

struct MenuBarContentView: Scene {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @State private var clipboardMonitor: ClipboardMonitor?
    @State private var clipboardActions: ClipboardActions?

    @Query(sort: [SortDescriptor(\ClipboardItem.timestamp, order: .reverse)])
    private var mostRecentClipboardItems: [ClipboardItem]

    var body: some Scene {
        MenuBarExtra("GetClipped", systemImage: "paperclip") {
            Menu {
                ForEach(Array(mostRecentClipboardItems.prefix(5).enumerated()), id: \.offset) { index, item in
                    Button(action: {
                        copyToClipboard(item: item)
                    }) {
                        HStack {
                            Text(item.preview)
                                .lineLimit(1)
                            Spacer()
                            Text(item.timestamp, style: .time)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [.command])
                }
            } label: {
                Text("Recent Items")
            }
            .keyboardShortcut("r", modifiers: [.command])
            .onAppear {
                if clipboardMonitor == nil {
                    let monitor = ClipboardMonitor(modelContext: modelContext)
                    clipboardMonitor = monitor
                    clipboardActions = ClipboardActions(clipboardMonitor: monitor, modelContext: modelContext)
                }
            }

            Divider()
            Button(action: {
                openMainWindow()
            }) {
                Text("Open GetClipped")
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut("o", modifiers: [.command])

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit GetClipped")
            }
            .buttonStyle(PlainButtonStyle())
            .colorScheme(.dark)
            .keyboardShortcut("q", modifiers: [.command])
        }
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)

        // Check if window already exists
        let hasVisibleWindow = NSApp.windows.contains { window in
            window.isVisible &&
                window.title == "GetClipped" &&
                window.contentViewController is NSHostingController<ContentView>
        }

        if hasVisibleWindow {
            // Bring existing window to front
            for window in NSApp.windows {
                if window.title == "GetClipped", window.isVisible {
                    window.makeKeyAndOrderFront(nil)
                    if window.isMiniaturized {
                        window.deminiaturize(nil)
                    }
                    break
                }
            }
        } else {
            // Open new window
            openWindow(id: "main")
        }
    }

    private func copyToClipboard(item: ClipboardItem) {
        clipboardActions!.copyItemToClipboard(item)
    }
}
