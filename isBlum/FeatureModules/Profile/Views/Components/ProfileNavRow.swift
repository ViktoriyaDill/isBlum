//
//  ProfileNavRow.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct ProfileNavRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.black)
                .font(.system(size: 16))
                .frame(width: 24)
            
            Text(title)
                .font(.onest(.regular, size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.onest(.regular, size: 14))
                    .foregroundColor(.gray)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture {
            // навігація
        }
    }
}
