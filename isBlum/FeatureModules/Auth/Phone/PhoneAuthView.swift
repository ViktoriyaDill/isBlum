//
//  PhoneAuthView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation
import SwiftUI


struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}

let countries = [
    Country(name: "Україна", code: "+380", flag: "🇺🇦"),
    Country(name: "Польща", code: "+48", flag: "🇵🇱"),
    Country(name: "Болгарія", code: "+359", flag: "🇧🇬"),
    Country(name: "Німеччина", code: "+49", flag: "🇩🇪")
]

struct PhoneAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var phoneNumber: String = ""
    @State private var selectedCountry = countries[0]
    @State private var showCountryPicker = false
    
    private var fullPhone: String {
        "\(selectedCountry.code)\(phoneNumber.filter { $0.isNumber })"
    }
    
    private var isValidPhone: Bool {
        phoneNumber.filter { $0.isNumber }.count >= 9
    }

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
                
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("Введіть номер\nтелефону")
                            .font(.onest(.bold, size: 32))
                            .multilineTextAlignment(.center)
                        
                        Text("Відправимо SMS з кодом для входу")
                            .font(.onest(.regular, size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Input Field
                    HStack(spacing: 12) {
                        Button(action: { showCountryPicker = true }) {
                            HStack(spacing: 4) {
                                Text(selectedCountry.flag)
                                Text(selectedCountry.code)
                                    .font(.onest(.regular, size: 16))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.black)
                        }
                        .padding(.leading, 16)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 24)
                        
                        TextField("Номер телефону", text: $phoneNumber)
                            .font(.onest(.regular, size: 16))
                            .keyboardType(.phonePad)
                    }
                    .frame(height: 60)
                    .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3)))
                    .padding(.horizontal, 16)
                    
                    if let error = auth.authError {
                        Text(error)
                            .font(.onest(.regular, size: 13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await auth.sendOTP(phone: fullPhone)
                            print("fullPhone \(fullPhone)")
                            if auth.authError == nil {
                                coordinator.showOTPVerification(phone: fullPhone, mode: .auth)
                            }
                        }
                    }) {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Продовжити")
                                    .font(.onest(.medium, size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isValidPhone ? Color(hex: "B5F1A0") : Color(hex: "F2F2F2"))
                        .cornerRadius(28)
                    }
                    .disabled(!isValidPhone || auth.isLoading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color(hex: "E2F5C6").ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            auth.authError = nil
        }
    }
}

#Preview {
    PhoneAuthView()
        .environmentObject(AppCoordinator())
        .environmentObject(AuthViewModel())
}
