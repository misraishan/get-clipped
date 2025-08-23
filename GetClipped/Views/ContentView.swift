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
    @StateObject private var clipboardActions: ClipboardActions
    @State private var selectedItem: ClipboardItem?
    @State private var searchText = ""
    
    let windowWidth = NSScreen.main?.visibleFrame.width ?? 800

    init() {
        self._clipboardActions = StateObject(wrappedValue: ClipboardActions(clipboardMonitor: ClipboardMonitor()))
    }

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
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .onTapGesture(perform: addItem)
                }
            }
        } detail: {
            if let selectedItem {
                ClipboardDetail(item: selectedItem)
                    .environmentObject(clipboardActions)
                    .id(selectedItem.id)
            } else {
                Text("Select an item to view details")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func addItem() {
        withAnimation {
            clipboardActions.addItem()
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
