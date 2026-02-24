//
//  LoggedInProfileView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct LoggedInProfileView: View {
    let hasUnverifiedContact: Bool
    
    var body: some View {
        ProfileCard {
            VStack(spacing: 24) {
                // User Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Ім'я")
                            .font(.onest(.bold, size: 14))
                        Spacer()
                        Button(action: { /* Edit action */ }) {
                            Image(.edit)
                                .foregroundColor(.black)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ContactRow(text: "+3809******75", isUnverified: hasUnverifiedContact)
                        ContactRow(text: "mariaisblum@gmail.com", isUnverified: hasUnverifiedContact)
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    ProfileMenuRow(icon: .orders, title: "Історія замовлень", showArrow: true)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
        }
    }
}

struct ContactRow: View {
    let text: String
    let isUnverified: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            if isUnverified {
                Image(.safety)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
            }
            Text(text)
                .font(.onest(.regular, size: 14))
                .foregroundColor(.gray)
        }
    }
}
