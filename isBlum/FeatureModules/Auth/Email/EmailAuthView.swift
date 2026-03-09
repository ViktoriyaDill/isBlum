//
//  EmailAuthView.swift
//  isBlum
//
//  Created by Пользователь on 04/03/2026.
//

import Foundation
import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var email: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Реєстрація/Вхід", showBackButton: true) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                // Біла підкладка з закругленими кутами
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 32) {
                    // Заголовок та підзаголовок
                    VStack(spacing: 12) {
                        Text("Введіть адресу\nелектронної пошти")
                            .font(.onest(.bold, size: 32))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Text("Надішлемо код для входу в акаунт")
                            .font(.onest(.regular, size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Поле введення пошти
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                        
                        TextField("Адреса ел. пошти", text: $email)
                            .font(.onest(.regular, size: 17))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isFocused)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Кнопка "Продовжити"
                    Button(action: handleContinue) {
                        Text("Продовжити")
                            .font(.onest(.medium, size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(email.isValidEmail ? Color(hex: "B5F1A0") : Color(hex: "B5F1A0").opacity(0.5))
                            )
                    }
                    .disabled(!email.isValidEmail)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { isFocused = true }
    }
    
    private func handleContinue() {
        Task {
            await auth.sendEmailOTP(email: email)
            if auth.authError == nil {
                coordinator.showEmailOTPVerification(email: email, mode: .auth)
            }
        }
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

#Preview {
    EmailAuthView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
