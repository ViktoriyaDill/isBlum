import SwiftUI

struct RootCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var filterVM = FilterViewModel()  
    
    var body: some View {
        ZStack {
            switch coordinator.appState {
            case .splash:
                SplashScreenView()
                    .onAppear { startSplashTimer() }
                
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
                EmptyView()
//                FilterBouquetTypeView()
//                    .environmentObject(filterVM)
                
            case .filterFlowers:
                EmptyView()
//                FilterFlowersView()
//                    .environmentObject(filterVM)
                
            case .filterPrice:
                EmptyView()
//                FilterPriceView()
//                    .environmentObject(filterVM)
                
            case .main:
                MainTabView()
            }
        }
        .environmentObject(coordinator)
        .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
    }
    
    private func startSplashTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            coordinator.finishSplash()
        }
    }
}
