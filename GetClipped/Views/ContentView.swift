//
//  ContentView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var clipboardActions: ClipboardActions?
    @State private var selectedItem: ClipboardItem?
    @State private var searchText = ""

    @Query(sort: [SortDescriptor(\ClipboardItem.timestamp, order: .reverse)])
    private var clipboardItems: [ClipboardItem]

    let windowWidth = NSScreen.main?.visibleFrame.width ?? 800

    var body: some View {
        NavigationSplitView {
            List(filteredItems, selection: $selectedItem) { item in
                ClipboardItemRow(item: item, isSelected: selectedItem?.id == item.id)
                    .id(item.id)
                    .contentShape(Rectangle())
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .animation(.easeInOut(duration: 0.15), value: selectedItem?.id)
                    .onTapGesture {
                        selectedItem = item
                    }
            }
            .listStyle(.sidebar)
            .searchable(text: $searchText)
            .navigationTitle("Clipboard History")
            .navigationSplitViewStyle(.balanced)
            .toolbar {
                ToolbarItem {
                    Button(action: { Task { addItem } }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: {
                        withAnimation {
                            clipboardActions?.clearHistory()
                            selectedItem = nil
                        }
                    }) {
                        Label("Clear History", systemImage: "trash")
                    }
                    .disabled(clipboardItems.isEmpty)
                }
            }
        } detail: {
            if let selectedItem {
                ClipboardDetail(item: selectedItem)
                    .environmentObject(clipboardActions ?? ClipboardActions(modelContext: modelContext))
                    .id(selectedItem.id)
            } else {
                Text("Select an item to view details")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if clipboardActions == nil {
                clipboardActions = ClipboardActions(modelContext: modelContext)
            }
        }
    }

    private func addItem() async {
        await clipboardActions?.addItem()
    }

    var filteredItems: [ClipboardItem] {
        guard clipboardActions != nil else { return [] }

        if searchText.isEmpty {
            return clipboardItems
        } else {
            return clipboardItems.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ClipboardItem.self)
}
