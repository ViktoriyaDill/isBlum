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
                    // Butterflies image from your assets
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
                        authButton(title: "Номеру телефона", icon: "phone", color: Color(hex: "B5F1A0"))
                        authButton(title: "Електронної пошти", icon: "envelope", color: Color(hex: "F2F2F2"))
                        
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            Text("або через:").font(.onest(.regular, size: 14)).foregroundColor(.gray)
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        authButton(title: "Google", icon: "google_logo", isSystemIcon: false, color: Color(hex: "F2F2F2"))
                        authButton(title: "Apple", icon: "apple.logo", color: Color(hex: "F2F2F2"))
                    }
                    .padding(.horizontal, 16)
                    
                    // Privacy Policy Text
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
    private func authButton(title: String, icon: String, isSystemIcon: Bool = true, color: Color) -> some View {
        Button(action: { /* Auth Logic */ }) {
            HStack(spacing: 12) {
                if isSystemIcon {
                    Image(systemName: icon)
                } else {
                    Image(icon).resizable().frame(width: 20, height: 20)
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
    AuthView().environmentObject(AppCoordinator())
}
