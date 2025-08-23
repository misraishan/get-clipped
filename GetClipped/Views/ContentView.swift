//
//  ContentView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var clipboardMonitor: ClipboardMonitor
    @State private var selectedItem: ClipboardItem?
    @State private var searchText = ""
    
    let windowWidth = NSScreen.main?.visibleFrame.width ?? 800

    var body: some View {
        NavigationSplitView {
            List(filteredItems) { item in
                ClipboardItemRow(item: item)
                    .onTapGesture {
                        selectedItem = item
                    }
            }
            .searchable(text: $searchText)
            .navigationTitle("Clipboard History")
            .navigationSplitViewStyle(.balanced)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selectedItem {
                ClipboardDetail(item: selectedItem)
            } else {
                Text("Select an item to view details")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ClipboardItem(content: "New Clipboard Item", timestamp: Date(), type: .text)
            clipboardMonitor.clipboardItems.insert(newItem, at: 0)
        }
    }
    
    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardMonitor.clipboardItems
        } else {
            return clipboardMonitor.clipboardItems.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipboardMonitor())
}
