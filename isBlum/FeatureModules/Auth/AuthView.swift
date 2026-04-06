//
//  AuthView.swift
//  isBlum
//
//  Created by Пользователь on 24/02/2026.
//

import Foundation
import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var selectedMethod: AuthMethod? = nil
    
    enum AuthMethod {
        case phone, email, google, apple
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "auth_nav_title", showBackButton: true) {
                coordinator.profilePath.removeLast()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 24) {
                    Image(.butterfliesIllustration)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 72)
                    
                    Text("auth_title")
                        .font(.onest(.bold, size: 32))
                        .multilineTextAlignment(.center)

                    Text("auth_subtitle")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Auth Buttons
                    VStack(spacing: 12) {
                        authButton(title: "auth_phone_option", icon: "phone", method: .phone) {
                            coordinator.profilePath.append(AppRoute.phoneAuth)
                        }

                        authButton(title: "auth_email_option", icon: "envelope", method: .email) {
                            coordinator.showEmailAuth()
                        }

                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            Text("auth_or_via").font(.onest(.regular, size: 16)).foregroundColor(.gray)
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        authButton(title: "Google", icon: "google_logo", isSystemIcon: false, method: .google) {
                            Task { await auth.signInWithGoogle() }
                        }
                        
                        authButton(title: "Apple", icon: "apple.logo", method: .apple) {
                            Task { await auth.signInWithApple() }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Text("auth_privacy_note")
                        .font(.onest(.medium, size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func authButton(
        title: LocalizedStringResource,
        icon: String,
        isSystemIcon: Bool = true,
        method: AuthMethod,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMethod = method
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                selectedMethod = nil
            }
        }) {
            HStack(spacing: 12) {
                if isSystemIcon {
                    Image(systemName: icon)
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(title)
                    .font(.onest(.medium, size: 16))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(selectedMethod == method ? Color(hex: "9AF19A") : Color(hex: "F4F4F4"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.gray.opacity(0.1), lineWidth: selectedMethod == method ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AuthView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
