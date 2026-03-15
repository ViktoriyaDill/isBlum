//
//  NotificationsView.swift
//  isBlum
//
//  Created by Пользователь on 15/03/2026.
//

import Foundation
import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    // Example data - in a real app, this would come from a ViewModel or Supabase
    @State private var notifications: [AppNotification] = [
        AppNotification(
            title: "Нове оновлення! Швидший вибір букетів, покращені рекомендації, виправлені помилки. Рекомендуємо оновити додаток",
            body: "",
            date: "Зараз",
            isRead: false
        ),
        AppNotification(
            title: "Спеціальна пропозиція! Знижка 20% на перше замовлення букетів. Не пропустіть шанс!",
            body: "",
            date: "4 хвилини тому",
            isRead: true
        ),
        AppNotification(
            title: "Запускаємо акцію! Отримайте безкоштовну доставку на всі замовлення до кінця місяця. Поспішайте!",
            body: "",
            date: "25 травня, 2026",
            isRead: true
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            CustomNavigationBar(
                title: "notifications_nav_title",
                showBackButton: true,
                backAction: { coordinator.popProfile() }
            )
            
            VStack (alignment: .center, spacing: 0) {
                if notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                        .padding(.top, 20)
                }
            }
            .background(.white)
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - List View
    private var notificationList: some View {
        List {
            ForEach(notifications) { notification in
                HStack(alignment: .center, spacing: 16) {
                    Image(.appLogoCircle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(notification.title)
                            .font(.onest(.regular, size: 15))
                            .foregroundColor(.black)
                            .lineSpacing(2)
                        
                        Text(notification.date)
                            .font(.onest(.regular, size: 13))
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                }
                .padding(12)
                .listRowSeparatorTint(Color.gray.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(notification.isRead
                            ? Color.clear
                            : Color(hex: "B8EEA6").opacity(0.2)
                        )
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            notifications.removeAll { $0.id == notification.id }
                        }
                    } label: {
                        Label("Видалити", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Color.white)
    }
    
    // MARK: - Empty State (Previous code)
    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(.notificationsEmptyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.bottom, 32)
            
            Text("notifications_empty_title")
                .font(.onest(.bold, size: 28))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            Text("notifications_empty_description")
                .font(.onest(.regular, size: 16))
                .foregroundColor(Color(hex: "#535852"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: { coordinator.resetToMain() }) {
                Text("notifications_action_button")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#B8EEA6"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Preview
#Preview {
    NotificationsView()
        .environmentObject(AppCoordinator())
}
