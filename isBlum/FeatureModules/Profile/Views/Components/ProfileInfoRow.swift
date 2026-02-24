//
//  ProfileInfoRow.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI


struct ProfileInfoRow: View {
    let icon: String?
    let iconColor: Color?
    let title: String?
    let value: String
    let showEdit: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(iconColor ?? .gray)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let title = title {
                    Text(title)
                        .font(.onest(.medium, size: 14))
                        .foregroundColor(.black)
                }
                Text(value)
                    .font(.onest(.regular, size: 14))
                    .foregroundColor(title != nil ? .gray : .black)
            }
            
            Spacer()
            
            if showEdit {
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
