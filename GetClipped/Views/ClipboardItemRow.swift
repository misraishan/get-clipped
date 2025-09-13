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
        HStack(spacing: 14) {
            ClipboardItemIconView(item: item.icon)
                .frame(width: 18, height: 18)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 6) {
                // preview
                Text(item.preview)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.body)
                    .foregroundColor(.primary)

                // metadata
                Text(item.dateTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor.opacity(0.4) : Color.clear)
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
