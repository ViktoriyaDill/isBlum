//
//  SuccessAuthView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation
import SwiftUI

struct SuccessAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    // MARK: - Animation State
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Using the background provided in your assets
            Image("success_bg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Image("leaf_illustration")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    // Simple spring entrance animation
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .opacity(isVisible ? 1.0 : 0.0)
                
                VStack(spacing: 8) {
                    Text("Код прийнято!")
                        .font(.onest(.bold, size: 32))
                        .foregroundColor(.black)
                    
                    Text("Код введено вірно")
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.black.opacity(0.6))
                }
                .offset(y: isVisible ? 0 : 20)
                .opacity(isVisible ? 1.0 : 0.0)
                
                Spacer()
            }
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .interactiveDismissDisabled(true)
        .onAppear {
            // Trigger visual animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isVisible = true
            }
            
            // MARK: - Navigation Logic
            // Wait for 4 seconds as requested, then proceed to Name Entry
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Navigate to UserNameEntryView using the coordinator
                    coordinator.profilePath.append(AppRoute.userName)
                }
            }
        }
    }
}

#Preview {
    SuccessAuthView()
        .environmentObject(AppCoordinator())
}
