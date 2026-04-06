//
//  VerifyCodeView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import SwiftUI

enum VerificationMode {
    case auth
    case updateProfile
}

struct VerifyCodeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    let phoneNumber: String
    let mode: VerificationMode
    
    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var timeRemaining = 30
    @State private var verificationState: VerificationState = .idle
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Validation Colors
    private let errorBorder = Color(hex: "D71616")
    private let errorBackground = Color(hex: "FEF6F6")
    private let successColor = Color(hex: "3AB73A")
    private let activeBorder = Color(hex: "B5F1A0")
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "auth_nav_title", showBackButton: true) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)
                
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("verify_code_title")
                            .font(.onest(.bold, size: 32))

                        VStack(spacing: 4) {
                            Text("verify_code_sms_sent")
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 8) {
                                Text(phoneNumber)
                                    .font(.onest(.medium, size: 16))
                                
                                Button(action: { coordinator.popProfile() }) {
                                    Image(.edit)
                                        .foregroundColor(.black)
                                        .frame(width: 24, height: 24)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                    .multilineTextAlignment(.center)
                    
                    // MARK: - OTP Input Fields
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            TextField("", text: $otpCode[index])
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(fillColor(for: index))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(borderColor(for: index), lineWidth: 2)
                                )
                                .font(.onest(.medium, size: 24))
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: index)
                                .disabled(verificationState == .loading || verificationState == .success)
                                .onChange(of: otpCode[index]) { newValue in
                                    handleOTPInput(index: index, value: newValue)
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    statusView
                    
                    Spacer()
                    
                    resendView
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
    
    // MARK: - Helper Methods for Dynamic Styling
    private func borderColor(for index: Int) -> Color {
        switch verificationState {
        case .error:   return errorBorder
        case .success: return successColor
        case .loading: return successColor.opacity(0.5)
        default:       return focusedField == index ? activeBorder : Color.gray.opacity(0.2)
        }
    }
    
    private func fillColor(for index: Int) -> Color {
        switch verificationState {
        case .error:   return errorBackground
        case .success: return successColor.opacity(0.05)
        default:       return Color.white
        }
    }
    
    // MARK: - Status Subview
    @ViewBuilder
    private var statusView: some View {
        switch verificationState {
        case .loading:
            HStack(spacing: 8) {
                ProgressView().scaleEffect(0.9)
                Text("verify_code_checking")
                    .font(.onest(.regular, size: 15))
                    .foregroundColor(.gray)
            }
            
        case .error:
            HStack(spacing: 6) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                Text("verify_code_wrong")
                    .font(.onest(.regular, size: 15))
            }
            .foregroundColor(errorBorder)

        case .success:
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                Text("verify_code_correct")
                    .font(.onest(.regular, size: 15))
            }
            .foregroundColor(successColor)
            
        case .idle:
            EmptyView()
        }
    }
    
    // MARK: - Resend Logic Subview
    @ViewBuilder
    private var resendView: some View {
        if verificationState == .error {
            Button(action: resendCode) {
                Text("verify_code_resend")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(activeBorder)
                    .cornerRadius(28)
            }
        } else {
            HStack {
                Text(timeRemaining > 0 ? "verify_code_resend_in" : "verify_code_can")
                    .foregroundColor(.gray)

                if timeRemaining > 0 {
                    Text(String(format: "0:%02d", timeRemaining))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                } else {
                    Button(String(localized: "verify_code_resend_now")) {
                        resendCode()
                    }
                    .foregroundColor(.black)
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
    
    // MARK: - Input Handling Logic
    private func handleOTPInput(index: Int, value: String) {
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
            Task { await verifyCode(fullCode) }
        }
    }
    
    private func verifyCode(_ code: String) async {
            verificationState = .loading
            await auth.verifyOTP(phone: phoneNumber, token: code)
            
            if auth.authError == nil {
                verificationState = .success
                try? await Task.sleep(nanoseconds: 800_000_000)
                
                switch mode {
                case .auth:
                    coordinator.profilePath.append(AppRoute.successAuth)
                case .updateProfile:
                    await auth.updateProfile(name: nil, phone: phoneNumber)
                    coordinator.popProfile()
                    coordinator.popProfile()
                }
            } else {
                withAnimation(.spring()) {
                    verificationState = .error
                }
            }
        }
    
    private func resendCode() {
        timeRemaining = 30
        verificationState = .idle
        otpCode = Array(repeating: "", count: 6)
        focusedField = 0
        Task {
            await auth.sendOTP(phone: phoneNumber)
        }
    }
}

//#Preview{
//    VerifyCodeView(phoneNumber: "viktoriyadill@gmail.com", mode: <#VerificationMode#>).environmentObject(AppCoordinator())
//        .environmentObject(AuthViewModel())
//}
