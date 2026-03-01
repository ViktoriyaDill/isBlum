import SwiftUI
import Supabase

struct RootCoordinatorView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var filterVM: FilterViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            switch coordinator.appState {
            case .splash:
                SplashScreenView()
                    .onAppear { startSplashTimer() }
                    .task { await listenToAuthState() }
                
            case .onboarding:
                OnboardingView()
                
            case .locationEntry:
                AddressEntryView()
                
            case .mapSelection:
                MapSelectionView()
                
            case .addressDetails(let address):
                AddressDetailsView(selectedAddress: address)
                
            case .filterOccasion:
                FiltersView()
                    .environmentObject(filterVM)
                
            case .filterBouquetType:
                FilterBouquetTypeView()
                    .environmentObject(filterVM)
                
            case .filterFlowers:
                FilterFlowersView()
                    .environmentObject(filterVM)
                
            case .filterPrice:
                FilterPriceView()
                    .environmentObject(filterVM)
                
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
    }
    
    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if coordinator.appState == .splash {
                coordinator.finishSplash()
            }
        }
    }
    
    func listenToAuthState() async {
        _ = await SupabaseService.shared.client.auth.onAuthStateChange { event, session in
            DispatchQueue.main.async {
                if let session = session, !session.isExpired {
                    authViewModel.isAuthenticated = true
                    if coordinator.appState != .main {
                        coordinator.appState = .main
                    }
                } else {
                    authViewModel.isAuthenticated = false
                }
            }
        }
    }
}
