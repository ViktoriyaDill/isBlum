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
        case main
    }
    
    @Published var appState: AppState = .splash
    @Published var selectedTab: TabItem = .feed
    
    
    @Published var feedPath = NavigationPath()
    @Published var ordersPath = NavigationPath()
    @Published var chatsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    
    // MARK: - Logic for going
    
    func finishSplash() {
        // Check if user has already completed onboarding
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = hasSeenOnboarding ? .main : .onboarding
        }
    }
    
    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .main
        }
    }
    
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
        case .feed: feedPath.removeLast()
        case .orders: ordersPath.removeLast()
        case .chats: chatsPath.removeLast()
        case .profile: profilePath.removeLast()
        }
    }
}
