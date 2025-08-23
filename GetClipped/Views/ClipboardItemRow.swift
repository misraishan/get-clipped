//
//  ClipboardItemRow.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//


import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.preview)
                .lineLimit(2)
            
            Text(item.timeString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
