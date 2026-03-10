//
//  EditProfileFieldView.swift
//  isBlum
//
//  Created by User on 09/03/2026.
//

import Foundation
import SwiftUI

struct EditProfileFieldView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    let fieldType: ProfileFieldType
    @State private var inputValue: String = ""
    
    // Country selection state
    @State private var selectedCountry: Country = countries.first(where: { $0.code == "+380" }) ?? countries[0]
    @State private var showCountryPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Обліковий запис", showBackButton: true) {
                coordinator.popProfile()
            }
            .background(Color(hex: "E2F5C6"))
            
            ZStack(alignment: .bottom) {
                Color(hex: "E2F5C6").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 24) {
                        Text(fieldType.title)
                            .font(.onest(.bold, size: 24))
                            .padding(.top, 40)
                        
                        // Input field container
                        HStack(spacing: 12) {
                            Image(systemName: fieldType.iconName)
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fieldType.title)
                                    .font(.onest(.regular, size: 12))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 8) {
                                    if fieldType == .phone {
                                        Button(action: { showCountryPicker = true }) {
                                            HStack(spacing: 4) {
                                                Text(selectedCountry.flag)
                                                Text(selectedCountry.code)
                                                    .font(.onest(.regular, size: 16))
                                                Image(systemName: "chevron.down")
                                                    .font(.system(size: 10, weight: .bold))
                                            }
                                            .foregroundColor(.black)
                                        }
                                        Divider().frame(height: 20)
                                    }
                                    
                                    TextField("", text: $inputValue)
                                        .keyboardType(fieldType.keyboardType)
                                        .font(.onest(.regular, size: 16))
                                }
                            }
                            
                            if !inputValue.isEmpty {
                                Button { inputValue = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    
                    Button(action: saveData) {
                        if auth.isLoading {
                            ProgressView().tint(.black)
                        } else {
                            Text("Зберегти")
                                .font(.onest(.medium, size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(hex: "B2F094"))
                    .cornerRadius(30)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .hideKeyboardOnTap()
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $selectedCountry)
        }
        .onAppear {
            setupInitialValue()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialValue() {
        switch fieldType {
        case .name:
            inputValue = auth.currentUser?.name ?? ""
        case .phone:
            let phone = auth.currentUser?.phone ?? ""
            // Try to match current phone with existing country codes
            if let matchedCountry = countries.first(where: { phone.hasPrefix($0.code) }) {
                selectedCountry = matchedCountry
                inputValue = String(phone.dropFirst(matchedCountry.code.count))
            } else {
                inputValue = phone
            }
        case .email:
            inputValue = auth.currentUser?.email ?? ""
        }
    }
    
    // MARK: - Helper Methods

    private func saveData() {
        Task {
            let currentName = auth.currentUser?.name
            let currentPhone = auth.currentUser?.phone
            
            switch fieldType {
            case .name:
                await auth.updateProfile(name: inputValue, phone: currentPhone)
                if auth.authError == nil {
                    coordinator.popProfile()
                }
                
            case .phone:
                let fullPhone = "\(selectedCountry.code)\(inputValue)"
                if fullPhone == currentPhone {
                    coordinator.popProfile()
                    return
                }
                
                await auth.sendOTP(phone: fullPhone)
                if auth.authError == nil {
                    coordinator.showOTPVerification(phone: fullPhone, mode: .updateProfile)
                }
                
            case .email:
                let currentEmail = auth.currentUser?.email
                if inputValue == currentEmail {
                    coordinator.popProfile()
                    return
                }
                
                await auth.sendEmailOTP(email: inputValue)
                if auth.authError == nil {
                    coordinator.showEmailOTPVerification(email: inputValue, mode: .updateProfile)
                }
            }
        }
    }
}
