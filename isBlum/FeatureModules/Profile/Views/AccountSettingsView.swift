//
//  AccountSettingsView.swift
//  isBlum
//
//  Created by Пользователь on 09/03/2026.
//

import Foundation
import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var showDeleteModal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            CustomNavigationBar(title: "account_nav_title", showBackButton: true) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                // Background color to match the flow
                Color(hex: "E2F5C6").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // White container
                    VStack(spacing: 16) {
                        // MARK: - Profile Rows
                        AccountMenuRow(
                            icon: UIImage(systemName: "person") ?? UIImage(),
                            title: "account_name_label",
                            subtitle: LocalizedStringResource(stringLiteral: auth.currentUser?.name ?? "profile_guest"),
                            action: { coordinator.showEditProfileField(.name) }
                        )

                        Divider().padding(.vertical, 8)

                        AccountMenuRow(
                            icon: UIImage(systemName: "phone") ?? UIImage(),
                            title: "account_phone_label",
                            subtitle: LocalizedStringResource(stringLiteral: auth.currentUser?.phone ?? "profile_phone_not_set"),
                            isUnverified: auth.isPhoneUnverified,
                            action: { coordinator.showEditProfileField(.phone) }
                        )

                        Divider().padding(.vertical, 8)

                        AccountMenuRow(
                            icon: UIImage(systemName: "envelope") ?? UIImage(),
                            title: "account_email_label",
                            subtitle: LocalizedStringResource(stringLiteral: auth.currentUser?.email ?? "profile_email_not_set"),
                            isUnverified: auth.isEmailUnverified,
                            action: { coordinator.showEditProfileField(.email)}
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 40)
                    .background(Color.white)
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    
                    // MARK: - Bottom Actions
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Sign Out Button
                        Button(action: {
                            Task {
                                await auth.signOut()
                                coordinator.appState = .main
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("account_signout_button")
                            }
                            .font(.onest(.medium, size: 18))
                            .foregroundColor(Color(hex: "D71616"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "FEF6F6"))
                            .cornerRadius(30)
                        }
                        
                        // Delete Account
                        Button(action: {
                            showDeleteModal = true
                        }) {
                            Text("account_delete_button")
                                .font(.onest(.medium, size: 16))
                                .foregroundColor(Color(hex: "535852"))
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 24)
                    .background(Color.white)
                }
            }
        }
        .sheet(isPresented: $showDeleteModal) {
            DeleteAccountModalView()
                .environmentObject(auth)
                .environmentObject(coordinator)
        }
        .navigationBarHidden(true)
    }
}

struct AccountMenuRow: View {
    let icon: UIImage
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var showArrow: Bool = true
    var isUnverified: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 8) {
                // Іконка зліва
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top, isUnverified ? 2 : 0)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(title)
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.onest(.regular, size: 15))
                        .foregroundColor(.gray)
                    
                    // Статус верифікації
                    if isUnverified {
                        HStack(spacing: 4) {
                            Image(.safety)
                                .resizable()
                                .frame(width: 14, height: 14)

                            Text("account_not_verified")
                                .font(.onest(.regular, size: 13))
                        }
                        .foregroundColor(Color(hex: "D71616"))
                    }
                }
                
                Spacer()
                
                // Стрілка праворуч
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.3))
                        .padding(.top, isUnverified ? 4 : 0)
                }
            }
            .padding(.vertical, 12)
            //            .padding(.horizontal, 24)
            .contentShape(Rectangle())
            .frame(height: 40)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}


//#Preview {
//    AccountSettingsView()
//        .environmentObject(AppCoordinator())
//        .environmentObject(AuthViewModel())
//}
