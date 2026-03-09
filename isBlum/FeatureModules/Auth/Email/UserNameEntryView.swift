//
//  UserNameEntryView.swift
//  isBlum
//
//  Created by Пользователь on 04/03/2026.
//

import Foundation
import SwiftUI

struct UserNameEntryView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var name: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Кастомний Navigation Bar (як на попередніх екранах)
            CustomNavigationBar(title: "Реєстрація/Вхід", showBackButton: false) {
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
                        Text("Як вас звати?")
                            .font(.onest(.bold, size: 32))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                        
                        Text("Допоможе кур'єру знайти вас\nпід час доставки")
                            .font(.onest(.regular, size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding(.top, 40)
                    
                    // Поле введення імені
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.system(size: 20))
                        
                        TextField("Ім'я", text: $name)
                            .font(.onest(.regular, size: 17))
                            .focused($isFocused)
                            .submitLabel(.done)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Кнопка "Продовжити"
                    Button(action: handleNameSubmission) {
                        Text("Продовжити")
                            .font(.onest(.medium, size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(name.trimmingCharacters(in: .whitespaces).count >= 2 ? Color(hex: "B5F1A0") : Color(hex: "B5F1A0").opacity(0.5))
                            )
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).count < 2)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            isFocused = true
        }
    }
    
    private func handleNameSubmission() {
        Task {
            await auth.updateProfile(name: name, phone: nil)
            coordinator.profilePath.append(AppRoute.successAuth)
        }
    }
}

#Preview {
    UserNameEntryView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
