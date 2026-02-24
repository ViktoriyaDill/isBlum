//
//  SettingsSection.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct SettingsGroupView: View {
    
    let isLoggedIn: Bool
    
    var body: some View {
        ProfileCard(content: {
            VStack(alignment: .leading, spacing: 16) {
                Text("Налаштування")
                    .font(.onest(.bold, size: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                
                VStack(spacing: 16) {
                    ProfileMenuRow(icon: .globe, title: "Мова", subtitle: "Українська")
                    Divider().padding(.leading, 50)
                    ProfileMenuRow(icon: .banknote, title: "Валюта", subtitle: "UAH")
                    Divider().padding(.leading, 50)
                    if isLoggedIn {
                        ProfileMenuRow(icon: .bell, title: "Налаштування сповіщень")
                        Divider().padding(.leading, 50)
                    }
                    ProfileMenuRow(icon: .help, title: "Підтримка")
                    Divider().padding(.leading, 50)
                    ProfileMenuRow(icon: .shop, title: "Розмістити свій магазин")
                    Divider().padding(.leading, 50)
                    ProfileMenuRow(icon: .info, title: "Про додаток")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        })
    }
}

struct ProfileMenuRow: View {
    let icon: UIImage
    let title: String
    var subtitle: String? = nil
    var showArrow: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: icon)
                .frame(width: 24)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.onest(.regular, size: 14))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.onest(.regular, size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .frame(height: 40)
    }
}
