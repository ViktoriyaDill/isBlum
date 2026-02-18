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
                Text("Filters Selection View")
                    .onTapGesture { coordinator.finishFilters() }
                
            case .main:
                MainTabView()
            case .mapSelection:
                MapSelectionView()
            case .addressDetails(address: let address):
                AddressDetailsView(selectedAddress: address)
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
