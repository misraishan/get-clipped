//
//  MenuBarContentView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/24/25.
//

import SwiftUI
import SwiftData

struct MenuBarContentView: Scene {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query(sort: [SortDescriptor(\ClipboardItem.timestamp, order: .reverse)])
        private var mostRecentClipboardItems: [ClipboardItem]
    
    var body: some Scene {
        MenuBarExtra("GetClipped", systemImage: "paperclip") {
            Menu {
                ForEach(Array(mostRecentClipboardItems.prefix(5).enumerated()), id: \.offset) { index, item in
                    Button(action: {
                        copyToClipboard(item.content)
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
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        
        // Check if window already exists
        let hasVisibleWindow = NSApp.windows.contains { window in
            return window.isVisible &&
            window.title == "GetClipped" &&
            window.contentViewController is NSHostingController<ContentView>
        }
        
        if hasVisibleWindow {
            // Bring existing window to front
            for window in NSApp.windows {
                if window.title == "GetClipped" && window.isVisible {
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
}
