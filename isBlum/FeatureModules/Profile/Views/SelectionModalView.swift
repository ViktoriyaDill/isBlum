//
//  SelectionModalView.swift
//  isBlum
//
//  Created by Пользователь on 10/03/2026.
//

import Foundation
import SwiftUI

struct SelectionModalView: View {
    @Environment(\.dismiss) var dismiss
    let type: SelectionType
    
    // Прив'язка до поточних значень (зазвичай зберігаються в UserDefaults або AppState)
    @AppStorage("app_language") private var selectedLanguage: String = "uk"
    @AppStorage("app_currency") private var selectedCurrency: String = "UAH"
    
    // Опції для вибору
    private var options: [SelectionOption] {
        switch type {
        case .language:
            return [
                SelectionOption(id: "uk", title: "Українська", icon: nil),
                SelectionOption(id: "ru", title: "Русский", icon: nil),
                SelectionOption(id: "en", title: "English", icon: nil)
            ]
        case .currency:
            return [
                SelectionOption(id: "UAH", title: "UAH ₴", icon: nil),
                SelectionOption(id: "USD", title: "USD $", icon: nil),
                SelectionOption(id: "EUR", title: "EUR €", icon: nil)
            ]
        }
    }
    
    private var currentSelection: String {
        type == .language ? selectedLanguage : selectedCurrency
    }

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Header
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.15))
                }
            }
            .padding([.horizontal, .top], 20)
            
            Text(type.title)
                .font(.onest(.bold, size: 24))
            
            // MARK: - Options List
            VStack(spacing: 0) {
                ForEach(options) { option in
                    Button(action: {
                        handleSelection(option.id)
                    }) {
                        HStack {
                            Text(option.title)
                                .font(.onest(.regular, size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // Checkmark Circle
                            ZStack {
                                Circle()
                                    .stroke(currentSelection == option.id ? Color(hex: "B2F094") : Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 22, height: 22)
                                
                                if currentSelection == option.id {
                                    Circle()
                                        .fill(Color(hex: "B2F094"))
                                        .frame(width: 14, height: 14)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentSelection == option.id ? Color(hex: "B2F094").opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(currentSelection == option.id ? Color(hex: "B2F094") : Color.clear, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    if option != options.last {
                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
    }
    
    // MARK: - Logic
    private func handleSelection(_ id: String) {
        withAnimation(.easeInOut) {
            if type == .language {
                selectedLanguage = id
                // Тут можна додати логіку зміни мови в системі Bundle
            } else {
                selectedCurrency = id
            }
        }
        // Закриваємо модалку після короткої затримки для візуального ефекту
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
