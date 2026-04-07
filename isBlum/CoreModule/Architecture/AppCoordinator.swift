import SwiftUI

// MARK: - App Route
// Defines all possible screens within NavigationStacks (tabs)
enum AppRoute: Hashable {
    
    // MARK: Marketplace
    case productDetails(id: Int)
    case sellerProfile(id: Int)
    case orderDetails(order: Order)
    case chatRoom(chat: Chat)
    
    // MARK: Profile
    case accountSettings
    case editProfileField(ProfileFieldType)
    case notificationSettings
    case aboutApp
    case termsOfService
    case support
    case notifications
    
    // MARK: Address
    case addressDetails(address: String)
    
    // MARK: Authentication
    case auth
    case phoneAuth
    case emailAuth
    case userName
    case successAuth
    case otpVerification(phone: String, mode: VerificationMode)
    case emailOtpVerification(email: String, mode: VerificationMode)
    case generalError
    
    // MARK: Account Deletion
    case accountDeletedSuccess
    
    // MARK: Orders
    case orderHistory
    case successRating
}

// MARK: - Tab Item
enum TabItem {
    case feed, orders, chats, profile
}

// MARK: - App Coordinator
// Manages global app state and navigation between screens
class AppCoordinator: ObservableObject {
    
    // MARK: - App State
    // Full-screen states outside TabBar (onboarding, splash, filters)
    enum AppState: Equatable {
        case splash
        case onboarding
        case locationEntry
        case mapSelection
        case addressDetails(address: String)
        case filterOccasion
        case filterBouquetType
        case filterFlowers
        case filterPrice
        case main
    }
    
    // MARK: - Published State
    @Published var appState: AppState = .splash
    @Published var selectedTab: TabItem = .feed
    @Published var pendingRetryAction: (() -> Void)? = nil
    
    // Separate NavigationPath for each tab
    @Published var feedPath = NavigationPath()
    @Published var ordersPath = NavigationPath()
    @Published var chatsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    // History stack for navigating back between AppState screens
    private var stateHistory: [AppState] = []
    
    // MARK: - Splash
    
    func finishSplash() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        let hasSavedLocation = UserDefaults.standard.string(forKey: "userAddress") != nil
        let hasSelectedFilters = UserDefaults.standard.bool(forKey: "hasSelectedFilters")
        
        withAnimation(.easeInOut(duration: 0.6)) {
            // Authenticated user goes directly to main screen
            if SupabaseService.shared.client.auth.currentUser != nil {
                self.appState = .main
                return
            }
            
            if !hasSeenOnboarding {
                self.appState = .onboarding
            } else if !hasSavedLocation {
                self.appState = .locationEntry
            } else if !hasSelectedFilters {
                self.appState = .filterOccasion
            } else {
                self.appState = .main
            }
        }
    }
    
    // MARK: - Onboarding & Filters
    
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
        navigate(to: .filterOccasion)
    }
    
    // Chains through the onboarding filter steps
    func showNextFilter(from current: AppState) {
        switch current {
        case .addressDetails:    navigate(to: .filterOccasion)
        case .filterOccasion:    navigate(to: .filterBouquetType)
        case .filterBouquetType: navigate(to: .filterFlowers)
        case .filterFlowers:     navigate(to: .filterPrice)
        case .filterPrice:       finishFilters()
        default: break
        }
    }
    
    func skipFilters() {
        stateHistory.removeAll()
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .main
        }
    }
    
    func finishFilters() {
        UserDefaults.standard.set(true, forKey: "hasSelectedFilters")
        stateHistory.removeAll()
        withAnimation(.easeInOut(duration: 0.6)) {
            self.appState = .main
        }
    }
    
    // MARK: - Auth Navigation
    
    func showAuth() {
        profilePath.append(AppRoute.auth)
    }
    
    func showPhoneAuth() {
        profilePath.append(AppRoute.phoneAuth)
    }
    
    func showEmailAuth() {
        profilePath.append(AppRoute.emailAuth)
    }
    
    func showOTPVerification(phone: String, mode: VerificationMode = .auth) {
        profilePath.append(AppRoute.otpVerification(phone: phone, mode: mode))
    }
    
    func showEmailOTPVerification(email: String, mode: VerificationMode = .auth) {
        profilePath.append(AppRoute.emailOtpVerification(email: email, mode: mode))
    }
    
    func showError(retry: @escaping () -> Void) {
        pendingRetryAction = retry
        profilePath.append(AppRoute.generalError)
    }
    
    // MARK: - Profile Navigation
    
    func showAccountSettings() {
        profilePath.append(AppRoute.accountSettings)
    }
    
    func showEditProfileField(_ fieldType: ProfileFieldType) {
        profilePath.append(AppRoute.editProfileField(fieldType))
    }
    
    func showNotificationSettings() {
        profilePath.append(AppRoute.notificationSettings)
    }
    
    func showAboutApp() {
        profilePath.append(AppRoute.aboutApp)
    }
    
    func showTermsOfService() {
        profilePath.append(AppRoute.termsOfService)
    }
    
    func showSupport() {
        profilePath.append(AppRoute.support)
    }
    
    func showNotifications() {
        profilePath.append(AppRoute.notifications)
    }
    
    // MARK: - Navigation Helpers
    
    // Pop one screen back in profilePath
    func popProfile() {
        guard !profilePath.isEmpty else { return }
        profilePath.removeLast()
    }
    
    // Return to the profile root screen
    func popToProfileRoot() {
        profilePath = NavigationPath()
    }
    
    // Show account deleted success screen and prevent going back
    func showAccountDeletedSuccess() {
        profilePath = NavigationPath()
        profilePath.append(AppRoute.accountDeletedSuccess)
    }
    
    // Full navigation reset to main feed
    func resetToMain() {
        profilePath = NavigationPath()
        feedPath = NavigationPath()
        ordersPath = NavigationPath()
        chatsPath = NavigationPath()
        selectedTab = .feed
        appState = .main
    }
    
    // MARK: - AppState Navigation
    
    // Transition between full-screen states with history tracking
    func navigate(to state: AppState) {
        stateHistory.append(appState)
        withAnimation(.easeInOut(duration: 0.5)) {
            self.appState = state
        }
    }
    
    // Return to the previous AppState
    func goBack() {
        guard let previous = stateHistory.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            self.appState = previous
        }
    }
    
    // MARK: - Orders navigation

    func showOrderDetails(_ order: Order) {
        ordersPath.append(AppRoute.orderDetails(order: order))
    }

    func showOrderHistory() {
        profilePath.append(AppRoute.orderHistory)
    }

    func showOrderHistoryFromOrders() {
        ordersPath.append(AppRoute.orderHistory)
    }

    func showChatRoom(_ chat: Chat) {
        chatsPath.append(AppRoute.chatRoom(chat: chat))
        selectedTab = .chats
    }

    func showSupportFromOrders() {
        ordersPath.append(AppRoute.support)
    }
}
