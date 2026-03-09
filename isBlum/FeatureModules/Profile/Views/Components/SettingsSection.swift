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
                    ProfileMenuRow(icon: .globe, title: "Мова", subtitle: "Українська") {
                        //add logic to navigate
                    }
                    Divider()
                    
                    ProfileMenuRow(icon: .banknote, title: "Валюта", subtitle: "UAH") {
                        //add logic to navigate
                    }
                    Divider()
                    
                    if isLoggedIn {
                        ProfileMenuRow(icon: .bell, title: "Налаштування сповіщень") {
                            //add logic to navigate
                        }
                        Divider()
                    }
                    ProfileMenuRow(icon: .help, title: "Підтримка") {
                        //add logic to navigate
                    }
                    Divider()
                    
                    ProfileMenuRow(icon: .shop, title: "Розмістити свій магазин"){
                        //add logic to navigate
                    }
                    Divider()
                    
                    ProfileMenuRow(icon: .info, title: "Про додаток") {
                        //add logic to navigate
                    }
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
    
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(uiImage: icon)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.onest(.medium, size: 16))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.onest(.regular, size: 14))
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
        .contentShape(Rectangle())
        .frame(height: 40)
        .onTapGesture {
            action()
        }
    }
    
}
