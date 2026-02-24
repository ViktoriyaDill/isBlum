//
//  ProfileView.swift
//  isBlum
//
//  Created by Пользователь on 19/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    // Replace with real logic from your AuthManager
    @State private var isLoggedIn: Bool = false
    @State private var hasUnverifiedContact: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with cloud background
            CustomNavigationBar(title: "Профіль", showBackButton: false)
                .overlay(alignment: .trailing) {
                    NotificationButton(count: 1)
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
                        if isLoggedIn {
                            LoggedInProfileView(hasUnverifiedContact: hasUnverifiedContact)
                        } else {
                            LoggedOutProfileView()
                        }
                        
                        SettingsGroupView(isLoggedIn: isLoggedIn)
                    }
                }
            }
            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight])).ignoresSafeArea()
            .padding(.top, 16)
        }
        .navigationBarHidden(true)
        
    }
}

#Preview {
    ProfileView().environmentObject(AppCoordinator())
}
