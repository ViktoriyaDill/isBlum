//
//  TagView.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 23/03/2026.
//

import Foundation
import SwiftUI


struct TagView: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.onest(.medium, size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color(hex: "#F1FDF0") : Color(hex: "#F4F4F4"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(hex: "#9AF19A") : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
