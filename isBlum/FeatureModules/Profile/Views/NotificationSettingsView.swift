//
//  NotificationSettingsView.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = NotificationViewModel()
    
    let userId: UUID // Pass the current user's ID
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Using your CustomNavigationBar component
            CustomNavigationBar(
                title: "Налаштування сповіщень",
                showBackButton: true,
                backAction: { coordinator.popProfile() }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Toggles Section
                    VStack(spacing: 0) {
                        ToggleRow(title: "Статус замовлення", isOn: $viewModel.orderStatusEnabled)
                            .onChange(of: viewModel.orderStatusEnabled) { _ in
                                viewModel.saveSettings(userId: userId)
                            }
                        
                        Divider().padding(.horizontal, 16)
                        
                        ToggleRow(title: "Нагадування про доставку", isOn: $viewModel.deliveryReminderEnabled)
                            .onChange(of: viewModel.deliveryReminderEnabled) { _ in
                                viewModel.saveSettings(userId: userId)
                            }
                        
                        Divider().padding(.horizontal, 16)
                        
                        ToggleRow(title: "Акції та пропозиції", isOn: $viewModel.promotionsEnabled)
                            .onChange(of: viewModel.promotionsEnabled) { _ in
                                viewModel.saveSettings(userId: userId)
                            }
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.top, 40)
                    
                    // Delivery Method Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Спосіб отримання")
                            .font(.onest(.bold, size: 18))
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            SelectionRow(title: "Push-сповіщення", isSelected: viewModel.deliveryMethod == "push") {
                                viewModel.deliveryMethod = "push"
                                viewModel.saveSettings(userId: userId)
                                viewModel.requestPushPermission()
                            }
                            
                            Divider().padding(.horizontal, 16)
                            
                            SelectionRow(title: "Електронна пошта", isSelected: viewModel.deliveryMethod == "email") {
                                viewModel.deliveryMethod = "email"
                                viewModel.saveSettings(userId: userId)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(Color(hex: "F9F9F9"))
        }
        .navigationBarHidden(true)
        .task {
            // Initial data fetch on view load
            await viewModel.fetchSettings(userId: userId)
        }
    }
}

// MARK: - Рядки з перемикачами

struct ToggleRow: View {
    let title: LocalizedStringResource
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.onest(.medium, size: 16))
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "B2F094")))
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }
}

// MARK: - Рядки вибору (Radio Button style)

struct SelectionRow: View {
    let title: LocalizedStringResource
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.onest(.regular, size: 16))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color(hex: "B2F094") : .gray.opacity(0.3))
                    .font(.system(size: 22))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
    }
}
