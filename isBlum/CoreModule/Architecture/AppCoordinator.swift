import SwiftUI

// Route definitions for NavigationStacks
enum AppRoute: Hashable {
    case productDetails(id: Int)
    case sellerProfile(id: Int)
    case orderDetails(id: String)
    case chatRoom(userId: String)
    case settings
    case editProfile
    case addressDetails(address: String)
}

enum TabItem {
    case feed, orders, chats, profile
}

class AppCoordinator: ObservableObject {
    
    enum AppState {
        case splash
        case onboarding
        case locationEntry
        case mapSelection
        case addressDetails(address: String)
        case filters
        case main
    }
    
    @Published var appState: AppState = .splash
    @Published var selectedTab: TabItem = .feed
    
    @Published var feedPath = NavigationPath()
    @Published var ordersPath = NavigationPath()
    @Published var chatsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    private var stateHistory: [AppState] = []
    
    // MARK: - Navigation Logic
    
    private func navigate(to state: AppState) {
           stateHistory.append(appState)
           withAnimation(.easeInOut(duration: 0.5)) {
               self.appState = state
           }
       }
    
    func finishSplash() {
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            let hasSavedLocation = UserDefaults.standard.string(forKey: "userAddress") != nil
            let hasSelectedFilters = UserDefaults.standard.bool(forKey: "hasSelectedFilters")
            
            withAnimation(.easeInOut(duration: 0.6)) {
                if !hasSeenOnboarding {
                    self.appState = .onboarding
                } else if !hasSavedLocation {
                    self.appState = .locationEntry
                } else if !hasSelectedFilters {
                    self.appState = .filters
                } else {
                    self.appState = .main
                }
            }
        }
        
        func finishOnboarding() {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            navigate(to: .locationEntry)
        }
        
        func showMapSelection() {
            navigate(to: .mapSelection)
        }
        
        func showAddressDetails(address: String) {
            navigate(to: .addressDetails(address: address))
        }
        
        func completeAddressSetup(details: AddressDetails) {
            LocationService.shared.saveFullAddress(details: details)
            stateHistory.removeAll()
            withAnimation(.easeInOut(duration: 0.6)) {
                self.appState = .filters
            }
        }
        
        func finishFilters() {
            UserDefaults.standard.set(true, forKey: "hasSelectedFilters")
            stateHistory.removeAll()
            withAnimation(.easeInOut(duration: 0.6)) {
                self.appState = .main
            }
        }
        
        func goBack() {
            guard let previous = stateHistory.popLast() else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                self.appState = previous
            }
        }
    }
