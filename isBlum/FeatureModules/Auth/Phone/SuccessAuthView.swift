//
//  SuccessAuthView.swift
//  isBlum
//
//  Created by Пользователь on 01/03/2026.
//

import Foundation
import SwiftUI

// MARK: - Success Types

enum SuccessType {
    case auth
    case rating
    
    var title: String {
        switch self {
        case .auth: return NSLocalizedString("success_auth_title", comment: "")
        case .rating: return NSLocalizedString("success_rating_title", comment: "")
        }
    }
    
    var subtitle: String {
        switch self {
        case .auth: return NSLocalizedString("success_auth_subtitle", comment: "")
        case .rating: return NSLocalizedString("success_rating_subtitle", comment: "")
        }
    }
    
    var imageName: String {
        switch self {
        case .auth: return "leaf_illustration"
        case .rating: return "success_bird"
        }
    }
}

struct SuccessAuthView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    
    var type: SuccessType = .auth
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Image("success_bg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Image(type.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .opacity(isVisible ? 1.0 : 0.0)
                
                VStack(spacing: 8) {
                    Text(type.title)
                        .font(.onest(.bold, size: 32))
                        .foregroundColor(.black)
                    
                    Text(type.subtitle)
                        .font(.onest(.regular, size: 16))
                        .foregroundColor(.black.opacity(0.6))
                }
                .offset(y: isVisible ? 0 : 20)
                .opacity(isVisible ? 1.0 : 0.0)
                
                Spacer()
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            animateEntrance()
            handleNavigation()
        }
    }
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isVisible = true
        }
    }
    
    // MARK: - Logic
    private func handleNavigation() {
        let delay = type == .auth ? 3.0 : 2.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.3)) {
                if type == .auth {
                    coordinator.profilePath.append(AppRoute.userName)
                } else {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SuccessAuthView(type: .rating)
        .environmentObject(AppCoordinator())
}
