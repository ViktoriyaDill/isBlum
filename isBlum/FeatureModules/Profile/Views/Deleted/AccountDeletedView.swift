//
//  AccountDeletedView.swift
//  isBlum
//
//  Created by Пользователь on 10/03/2026.
//

import Foundation
import SwiftUI

struct AccountDeletedView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // MARK: - Background Image from Assets
            Image(.deleteBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Content Container
                VStack(spacing: 16) {
                    // Illustration
                    Image(.deleteIllustration) // Use the same sun/birds icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    // Main Title
                    Text("account_deleted_title")
                        .font(.onest(.bold, size: 28))
                        .foregroundColor(.black)

                    Text("account_deleted_subtitle")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // MARK: - Bottom Action Button
                Button(action: {
                    // Navigate back to the main flower/bouquets screen
                    coordinator.resetToMain()
                    // or e.g., coordinator.appState = .main
                }) {
                    Text("account_deleted_home_button")
                        .font(.onest(.medium, size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(hex: "#9AF19A")) // Green color from design
                        .cornerRadius(30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60) // Added padding above safe area
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
#Preview {
    AccountDeletedView()
        .environmentObject(AppCoordinator())
}
