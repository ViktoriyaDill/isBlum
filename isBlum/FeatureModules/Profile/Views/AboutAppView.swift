//
//  AboutAppView.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI

struct AboutAppView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator
    
    // LOG: Defining the app version for display
    let appVersion = "1.0.0"
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Navigation Bar
            CustomNavigationBar(
                title: "about_nav_title",
                showBackButton: true,
                backAction: { coordinator.popProfile() }
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - App Info Header
                    VStack(spacing: 16) {
                        // App Logo
                        Image(.appLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .cornerRadius(20)
                        
                        // Description text
                        VStack(spacing: 8) {
                            Text("about_description")
                                .font(.onest(.medium, size: 16))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            (Text("about_version_prefix") + Text(appVersion))
                                .font(.onest(.medium, size: 12))
                                .foregroundColor(Color(hex: "#535852"))
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 16)
                    
                    // MARK: - Options List
                    VStack(spacing: 0) {
                        // Rate App Row
                        ProfileMenuRow(
                            icon: UIImage(resource: .star),
                            title: "about_rate_app"
                        ) {
                            print("LOG: User tapped Rate App")
                            ReviewHandler.requestReview()
                        }
                        
                        Divider().padding(16)
                        
                        // Terms of Service Row
                        ProfileMenuRow(
                            icon: UIImage(resource: .terms),
                            title: "about_terms_of_service"
                        ) {
                            print("LOG: User tapped Terms of Service")
                            coordinator.showTermsOfService()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}
//
//#Preview {
//    AboutAppView()
//}
