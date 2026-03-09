//
//  VerifyEmailView.swift
//  isBlum
//
//  Created by User on 04/03/2026.
//

import Foundation
import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    let email: String
    let mode: VerificationMode
    
    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var timeRemaining = 30
    @State private var verificationState: VerificationState = .idle
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Validation Colors
    private let errorBorder = Color(hex: "D71616")
    private let errorBackground = Color(hex: "FEF6F6")
    private let successBorder = Color(hex: "4CAF50")
    private let successBackground = Color(hex: "4CAF50").opacity(0.05)
    private let activeBorder = Color(hex: "B5F1A0")
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Реєстрація/Вхід", showBackButton: true) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Введіть код")
                            .font(.onest(.bold, size: 32))
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Text("Надіслали його на")
                                    .font(.onest(.regular, size: 16))
                                    .foregroundColor(.gray)
                                
                                Text(email)
                                    .font(.onest(.medium, size: 16))
                                
                                Button(action: { coordinator.popProfile() }) {
                                    Image(.edit)
                                        .foregroundColor(.black)
                                        .frame(width: 24, height: 24)
                                        .font(.system(size: 14))
                                }
                            }
                            
                            Text("Перевірте «Вхідні» або «Спам»")
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    .multilineTextAlignment(.center)
                    
                    // MARK: - Input Block
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            ForEach(0..<6, id: \.self) { index in
                                TextField("", text: $otpCode[index])
                                    .frame(width: 48, height: 48)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(currentFillColor)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                currentBorderColor(for: index),
                                                lineWidth: 2
                                            )
                                    )
                                    .font(.onest(.medium, size: 24))
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: index)
                                    .onChange(of: otpCode[index]) { newValue in
                                        handleOTPInput(index: index, value: newValue)
                                    }
                            }
                        }
                        
                        statusMessageView
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer()
                    
                    bottomActionView
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { focusedField = 0 }
        .onReceive(timer) { _ in
            if timeRemaining > 0 { timeRemaining -= 1 }
        }
    }
    
    // MARK: - Subviews
    
    private var statusMessageView: some View {
        Group {
            if verificationState == .error {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Невірний код")
                }
                .foregroundColor(errorBorder)
            } else if verificationState == .success {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                    Text("Код введено правильно")
                }
                .foregroundColor(successBorder)
            }
        }
        .font(.onest(.regular, size: 14))
    }
    
    @ViewBuilder
    private var bottomActionView: some View {
        if verificationState == .error {
            Button(action: resendCode) {
                Text("Відправити код повторно")
                    .font(.onest(.medium, size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(RoundedRectangle(cornerRadius: 30).fill(activeBorder))
            }
        } else {
            HStack {
                if timeRemaining > 0 {
                    Text("Відправити код повторно через")
                        .foregroundColor(.gray)
                    Text(String(format: "0:%02d", timeRemaining))
                        .fontWeight(.semibold)
                } else {
                    Button("Відправити код ще раз") {
                        resendCode()
                    }
                    .fontWeight(.bold)
                }
            }
            .font(.onest(.regular, size: 15))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(28)
        }
    }
    
    // MARK: - Dynamic Styling Logic
    
    private var currentFillColor: Color {
        switch verificationState {
        case .error:   return errorBackground
        case .success: return successBackground
        default:       return Color.white
        }
    }
    
    private func currentBorderColor(for index: Int) -> Color {
        switch verificationState {
        case .error:   return errorBorder
        case .success: return successBorder
        default:       return focusedField == index ? activeBorder : Color.gray.opacity(0.2)
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleOTPInput(index: Int, value: String) {
        // Reset state when user starts typing after an error
        if verificationState == .error {
            verificationState = .idle
        }
        
        if value.count > 1 {
            otpCode[index] = String(value.last!)
        }
        
        if !value.isEmpty && index < 5 {
            focusedField = index + 1
        }
        
        if value.isEmpty && index > 0 {
            focusedField = index - 1
        }
        
        let fullCode = otpCode.joined()
        if fullCode.count == 6 {
            focusedField = nil
            verify(fullCode)
        }
    }
    
    private func verify(_ code: String) {
           Task {
               await auth.verifyEmailOTP(email: email, token: code)
               
               await MainActor.run {
                   withAnimation {
                       if auth.authError == nil {
                           verificationState = .success
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                               switch mode {
                               case .auth:
                                   coordinator.profilePath.append(AppRoute.successAuth)
                               case .updateProfile:
                                   coordinator.popProfile()
                                   coordinator.popProfile()
                               }
                           }
                       } else {
                           verificationState = .error
                       }
                   }
               }
           }
       }
    
    private func resendCode() {
        withAnimation {
            timeRemaining = 30
            verificationState = .idle
            otpCode = Array(repeating: "", count: 6)
            focusedField = 0
        }
        Task { await auth.sendEmailOTP(email: email) }
    }
}

//#Preview {
//    VerifyEmailView(email: "viktoriyadill@gmail.com")
//        .environmentObject(AppCoordinator())
//        .environmentObject(AuthViewModel())
//}
