import SwiftUI

enum AppRoute: Hashable {
    
    case productDetails(id: Int)
    case sellerProfile(id: Int)
    case orderDetails(id: String)
    case chatRoom(userId: String)
    case settings
    case editProfile
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
        case filters
        case main
    }
    
    @Published var appState: AppState = .splash
    @Published var selectedTab: TabItem = .feed
    
    @Published var feedPath = NavigationPath()
    @Published var ordersPath = NavigationPath()
    @Published var chatsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    // MARK: - Navigation Logic
    
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
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .locationEntry
        }
    }
    
    
    func finishLocationSelection(address: String) {
        UserDefaults.standard.set(address, forKey: "userAddress")
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .filters
        }
    }
    
    func finishFilters() {
        UserDefaults.standard.set(true, forKey: "hasSelectedFilters")
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .main
        }
    }
    
    func showMapSelection() {
        withAnimation(.easeInOut(duration: 0.4)) {
            self.appState = .mapSelection
        }
    }
    
    func goBack() {
        withAnimation(.easeInOut(duration: 0.4)) {
            switch appState {
            case .locationEntry:
                self.appState = .onboarding
            case .mapSelection:
                self.appState = .locationEntry
            case .filters:
                self.appState = .locationEntry
            case .main:
                self.appState = .filters
            default:
                break
            }
        }
    }
    
    // MARK: - Routing
    func push(_ route: AppRoute) {
        switch selectedTab {
        case .feed: feedPath.append(route)
        case .orders: ordersPath.append(route)
        case .chats: chatsPath.append(route)
        case .profile: profilePath.append(route)
        }
    }
    
    func pop() {
        switch selectedTab {
        case .feed: if !feedPath.isEmpty { feedPath.removeLast() }
        case .orders: if !ordersPath.isEmpty { ordersPath.removeLast() }
        case .chats: if !chatsPath.isEmpty { chatsPath.removeLast() }
        case .profile: if !profilePath.isEmpty { profilePath.removeLast() }
        }
    }
}
