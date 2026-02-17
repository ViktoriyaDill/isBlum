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
                OnboardingView()
                
            case .locationEntry:
                AddressEntryView()
                
            case .filters:
                // Екран фільтрів з кнопкою "Назад" до вибору локації
                Text("Filters Selection View")
                    .onTapGesture { coordinator.finishFilters() }
                
            case .main:
                MainTabView()
            }
        }
        .environmentObject(coordinator)
        .transition(.opacity)
    }
    
    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            coordinator.finishSplash()
        }
    }
}
