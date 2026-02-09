//
//  RootCoordinatorView.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import SwiftUI

struct RootCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        ZStack {
            switch coordinator.appState {
            case .splash:
                SplashScreenView()
                    .onAppear {
                        startSplashTimer()
                    }
            case .onboarding:
                // Pass the finish action to your OnboardingView
                Text("Onboarding View")
                    .onTapGesture { coordinator.finishOnboarding() }
            case .main:
                MainTabView()
            }
        }
        .environmentObject(coordinator) // Make coordinator accessible everywhere
    }
    
    private func startSplashTimer() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                coordinator.finishSplash()
            }
        }
}
