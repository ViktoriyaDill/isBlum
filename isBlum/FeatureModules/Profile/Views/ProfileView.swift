//
//  ProfileView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var auth: AuthViewModel
    
    @StateObject private var notificationVM = NotificationViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with cloud background
            CustomNavigationBar(title: "Профіль", showBackButton: false)
                .overlay(alignment: .trailing) {
                    NotificationButton(count: notificationVM.unreadCount) {
                        coordinator.showNotifications()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            sendTestLocalNotification()
                        }
                    }
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                }
                .background(Color(hex: "E2F5C6"))
            
            ZStack(alignment: .top) {
                // Main background
                Color(hex: "F2F2F2").ignoresSafeArea()
                
                // Content with rounded corners
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        if auth.isAuthenticated {
                            LoggedInProfileView()
                        } else {
                            LoggedOutProfileView {
                                coordinator.showAuth()
                            }
                        }
                        
                        SettingsGroupView(isLoggedIn: auth.isAuthenticated)
                            .environmentObject(coordinator) 
                        
                    }
                    .padding(.bottom, 120)
                }
            }
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight])).ignoresSafeArea()
            .padding(.top, 16)
        }
        .navigationBarHidden(true)
        . task {
            if auth.isAuthenticated {
                Task {
                    await notificationVM.fetchNotifications()
                    notificationVM.subscribeToRealtime()
                }
            } else {
                notificationVM.unsubscribeFromRealtime()
            }
        }
        .onDisappear {
            notificationVM.unsubscribeFromRealtime()
        }
        
    }
}

#Preview {
    ProfileView().environmentObject(AppCoordinator())
}
