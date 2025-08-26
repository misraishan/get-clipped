//
//  ClipboardItemRow.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ClipboardItemIconView(item: item.icon)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.body)

                Text(item.timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.5) : Color.clear)
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    ClipboardItemRow(item: ClipboardItem(
        content: "Sample clipboard content for preview purposes.", timestamp: Date(), type: .text
    ), isSelected: false)
    ClipboardItemRow(item: ClipboardItem(
        content: "Sample clipboard content for preview purposes.", timestamp: Date(), type: .link
    ), isSelected: true)
    ClipboardItemRow(item: ClipboardItem(
        content: "Sample clipboard content for preview purposes.", timestamp: Date(), type: .image
    ), isSelected: false)
}
