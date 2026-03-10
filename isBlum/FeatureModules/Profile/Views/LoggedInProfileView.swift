//
//  LoggedInProfileView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//
import SwiftUI

struct LoggedInProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    // MARK: - Computed Properties for User Data
    // Accessing properties from your UserProfile model
    private var userName: String {
        print("name \(auth.currentUser?.name)")
        return auth.currentUser?.name ?? "Гість"
    }
    
    private var userPhone: String {
        print("phone \(auth.currentUser?.phone)")
        // If your profile doesn't have a phone, you can take it from auth session
        return auth.currentUser?.phone ?? "Номер не вказано"
    }
    
    private var userEmail: String {
        print("email \(auth.currentUser?.email)")
        // Typically email is in the auth metadata or your profile table
        return auth.currentUser?.email ?? "Email не вказано"
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // User Info Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(userName)
                        .font(.onest(.bold, size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        coordinator.showAccountSettings()
                    }) {
                        Image(.edit)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ContactRow(
                        text: userPhone,
                        isUnverified: auth.isPhoneUnverified
                    )
                    
                    ContactRow(
                        text: userEmail,
                        isUnverified: auth.isEmailUnverified
                    )
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                ProfileMenuRow(
                    icon: .orders,
                    title: "Історія замовлень",
                    showArrow: true
                ) {
                    // navigate to history
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .onAppear {
            if auth.currentUser == nil {
                Task { await auth.fetchProfile() }
            }
        }
    }
}

// MARK: - Supporting Components

struct ContactRow: View {
    let text: String
    let isUnverified: Bool
    
    var body: some View {
        HStack(spacing: 8) {
    
            if isUnverified {
                Image(.safety)
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            
            Text(text)
                .font(.onest(.regular, size: 15))
                .foregroundColor(.black.opacity(0.8))
        }
    }
}
