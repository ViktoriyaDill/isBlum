//
//  RootView.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        Group {
            switch coordinator.appState {
            case .splash:
                SplashScreenView()
                    .onAppear {
                        // Імітація перевірки токена/завантаження
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            coordinator.finishSplash()
                        }
                    }
                
            case .onboarding:
                OnboardingView()
                // В OnboardingView кнопка "Почати" має викликати coordinator.finishOnboarding()
                
            case .main:
                EmptyView()
//                MainTabView()
            }
        }
        .environmentObject(coordinator) // Передаємо координатор у всі View вниз по ієрархії
    }
}
