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
                    .task { await checkExistingSession() }
                
            case .onboarding:
                OnboardingView()
            case .locationEntry:
                AddressEntryView()
            case .mapSelection:
                MapSelectionView()
            case .addressDetails(let address):
                AddressDetailsView(selectedAddress: address)
            case .filterOccasion:
                FiltersView().environmentObject(filterVM)
            case .filterBouquetType:
                FilterBouquetTypeView().environmentObject(filterVM)
            case .filterFlowers:
                FilterFlowersView().environmentObject(filterVM)
            case .filterPrice:
                FilterPriceView().environmentObject(filterVM)
            case .main:
                MainTabView()
            }
        }
        .onAppear {
            authViewModel.coordinator = coordinator
        }
        .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
        .onChange(of: authViewModel.justSignedIn) { didSignIn in
            guard didSignIn else { return }
            authViewModel.justSignedIn = false
            
            if coordinator.appState != .main {
                coordinator.appState = .main
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                coordinator.profilePath = NavigationPath()
                coordinator.selectedTab = .profile
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuth in
            if !isAuth {
                coordinator.profilePath = NavigationPath()
            }
        }
    }
    
    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if coordinator.appState == .splash {
                coordinator.finishSplash()
            }
        }
    }
    
    private func checkExistingSession() async {
        do {
            let session = try await SupabaseService.shared.client.auth.session
            if !session.isExpired {
                authViewModel.isAuthenticated = true
                await authViewModel.fetchProfile()
            }
        } catch {
            print("No existing session: \(error.localizedDescription)")
        }
    }
}
