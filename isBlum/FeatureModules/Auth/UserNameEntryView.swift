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
    @State private var isLoading: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Реєстрація/Вхід", showBackButton: false) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 32) {
                    // Header Section
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
                    
                    // MARK: - Name Input Field
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .foregroundColor(.black.opacity(0.7))
                            .font(.system(size: 20))
                        
                        TextField("Ім'я", text: $name)
                            .font(.onest(.regular, size: 17))
                            .focused($isFocused)
                            .submitLabel(.done)
                            .disabled(isLoading)
                            .onSubmit {
                                if isFormValid { handleNameSubmission() }
                            }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isFocused ? Color(hex: "B5F1A0") : Color.gray.opacity(0.3), lineWidth: 1.5)
                    )
                    
                    Spacer()
                    
                    // MARK: - Submit Button
                    Button(action: handleNameSubmission) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.black)
                                    .padding(.trailing, 8)
                            }
                            Text(isLoading ? "Зберігаємо..." : "Продовжити")
                        }
                        .font(.onest(.medium, size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(isFormValid ? Color(hex: "B5F1A0") : Color(hex: "B5F1A0").opacity(0.5))
                        )
                    }
                    .disabled(!isFormValid || isLoading)
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
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    // MARK: - Logic & DB Interaction
    
    private func handleNameSubmission() {
        guard isFormValid else { return }
        
        isLoading = true
        let cleanedName = name.trimmingCharacters(in: .whitespaces)
        
        Task {
            // Updating profile in DB via AuthViewModel
            await auth.updateProfile(name: cleanedName, phone: nil)
            
            await MainActor.run {
                isLoading = false
                if auth.authError == nil {
                    // Success: Navigate to the main app area
                    withAnimation(.easeInOut) {
                        coordinator.profilePath = NavigationPath()
                        coordinator.appState = .main
                    }
                } else {
                    // Optional: Handle error (e.g., show an alert)
                    print("Error saving name: \(String(describing: auth.authError))")
                }
            }
        }
    }
}

#Preview {
    UserNameEntryView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
