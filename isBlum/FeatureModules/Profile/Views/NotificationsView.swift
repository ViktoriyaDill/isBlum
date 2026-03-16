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
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "notifications_nav_title",
                showBackButton: true,
                backAction: { coordinator.popProfile() }
            )
            
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .background(.white)
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchNotifications()
            viewModel.subscribeToRealtime()
        }
        .onDisappear {
            viewModel.unsubscribeFromRealtime()
        }
    }
    
    // MARK: - List
    private var notificationList: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                VStack(spacing: 0) {
                    notificationRow(for: notification)
                    
                    if notification.id != viewModel.notifications.last?.id {
                        Rectangle()
                            .fill(Color(hex: "#F4F4F4"))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .padding(.top, 16)
    }

    @ViewBuilder
    private func notificationRow(for notification: AppNotification) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(.appLogoCircle)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.onest(.regular, size: 15))
                    .foregroundColor(.black)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(notification.date)
                    .font(.onest(.regular, size: 13))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            notification.isRead
            ? Color.white
            : Color(hex: "B8EEA6").opacity(0.15)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(notification.isRead ? 0.04 : 0), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            Task { await viewModel.markAsRead(notification) }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await viewModel.deleteNotification(notification) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    // MARK: - Empty State
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
        .environmentObject(NotificationViewModel())
}
