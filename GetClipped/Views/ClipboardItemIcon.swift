//
//  ClipboardItemIconView.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI

struct ClipboardItemIconView: View {
    let item: ClipboardItemIcon
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(item.color)
                .frame(width: 24, height: 24)
                .cornerRadius(8)
            
            Image(systemName: item.icon)
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
        }
    }
}
