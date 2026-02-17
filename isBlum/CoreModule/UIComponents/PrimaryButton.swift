//
//  PrimaryButton.swift
//  isBlum
//
//  Created by Пользователь on 13/02/2026.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.onest(.medium, size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.button)
                .cornerRadius(28)
        }
        .padding(.horizontal, 24)
    }
}


struct AddressInputField: View {
    @Binding var text: String
    var placeholder: String
    var onClear: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(.geolocationPin)
                .resizable()
                .font(.system(size: 14))
                .frame(width: 24, height: 24)
            
            TextField(placeholder, text: $text)
                .font(.onest(.regular, size: 16))
                .foregroundStyle(.black)
            
            if !text.isEmpty {
                Button(action: { onClear?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primaryBorder, lineWidth: 1.5))
    }
}
