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
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Реєстрація/Вхід", showBackButton: true) {
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
                        .frame(width: 120, height: 120)
                        .padding(.top, 40)
                    
                    Text("Букети вже чекають")
                        .font(.onest(.bold, size: 28))
                        .multilineTextAlignment(.center)
                    
                    Text("Увійдіть, щоб оформити замовлення\nта відстежувати доставку за допомогою:")
                        .font(.onest(.regular, size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Auth Buttons
                    VStack(spacing: 12) {
                        authButton(title: "Номеру телефона", icon: "phone", color: Color(hex: "B5F1A0")) {
                            coordinator.profilePath.append(AppRoute.phoneAuth)
                        }
                        
                        authButton(title: "Електронної пошти", icon: "envelope", color: Color(hex: "F2F2F2")) {
                            // TODO: Add email auth logic
                        }
                        
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            Text("або через:").font(.onest(.regular, size: 14)).foregroundColor(.gray)
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // Google Login Implementation
                        authButton(title: "Google", icon: "google_logo", isSystemIcon: false, color: Color(hex: "F2F2F2")) {
                            Task {
                                await auth.signInWithGoogle()
                            }
                        }
                        
                        authButton(title: "Apple", icon: "apple.logo", color: Color(hex: "F2F2F2")) {
                            // TODO: Add apple auth logic
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Text("Продовжуючи реєстрацію, ви даєте згоду\nна обробку персональних даних")
                        .font(.onest(.regular, size: 12))
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
        title: String,
        icon: String,
        isSystemIcon: Bool = true,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isSystemIcon {
                    Image(systemName: icon)
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Text(title)
                    .font(.onest(.medium, size: 16))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(color)
            .cornerRadius(28)
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
