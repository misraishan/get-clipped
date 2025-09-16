//
//  ContentView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftData
import SwiftUI

@available(macOS 26.0, *)
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
            VStack(spacing: 0) {
                // Custom search bar with better styling
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        
                        TextField("Search clipboard history...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "doc.on.clipboard" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.primary.opacity(0.3))
                        
                        Text(searchText.isEmpty ? "No clipboard history" : "No matching items")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Text("Copy something to get started")
                                .font(.body)
                                .foregroundColor(.primary.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(filteredItems) { item in
                                ClipboardItemRow(item: item, isSelected: selectedItem?.id == item.id)
                                    .onTapGesture {
                                        selectedItem = item
                                     }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: { Task { await addItem() } }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            clipboardActions?.clearHistory()
                            selectedItem = nil
                        }
                    }) {
                        Label("Clear History", systemImage: "trash")
                    }
                    .disabled(clipboardItems.isEmpty)
                    .keyboardShortcut("k", modifiers: [.command, .shift])
                }
            }
        } detail: {
            if let selectedItem {
                ClipboardDetail(item: selectedItem)
                    .environmentObject(clipboardActions ?? ClipboardActions(modelContext: modelContext))
                    .id(selectedItem.id)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                // Enhanced empty state
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Select a clipboard item")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Choose an item from the sidebar to view its details and actions")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            }
        }
        .navigationSplitViewStyle(.balanced)
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
    if #available(macOS 26.0, *) {
        ContentView()
            .modelContainer(for: ClipboardItem.self)
    } else {
        Text("Upgrade to macOS 26 to preview this view")
    }
}
