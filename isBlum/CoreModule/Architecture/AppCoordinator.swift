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
    case auth
    case phoneAuth
    case otpVerification(phone: String)
    case successAuth
    case emailAuth
    case emailOtpVerification(email: String)
    case userName
    case accountSettings
    case editProfileField(ProfileFieldType)
    case accountDeletedSuccess
    case otpVerification(phone: String, mode: VerificationMode)
    case emailOtpVerification(email: String, mode: VerificationMode)
}

enum TabItem {
    case feed, orders, chats, profile
}

class AppCoordinator: ObservableObject {
    
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
    
    @Published var appState: AppState = .splash
    @Published var selectedTab: TabItem = .feed
    
    @Published var feedPath = NavigationPath()
    @Published var ordersPath = NavigationPath()
    @Published var chatsPath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    private var stateHistory: [AppState] = []
    
    // MARK: - Navigation Logic
    
    func showAuth() {
        profilePath.append(AppRoute.auth)
    }
    
    // Phone authenfication

    func showPhoneAuth() {
        profilePath.append(AppRoute.phoneAuth)
    }

    func showOTPVerification(phone: String) {
        profilePath.append(AppRoute.otpVerification(phone: phone))
    }
    
    // Email authenfication
    
    func showEmailAuth() {
        profilePath.append(AppRoute.emailAuth)
    }

    func showEmailOTPVerification(email: String) {
        profilePath.append(AppRoute.emailOtpVerification(email: email))
    }

    // MARK: - Navigation Reset Logic
    
    func popProfile() {
        guard !profilePath.isEmpty else { return }
        profilePath.removeLast()
    }

    /// Clears all screens in the Profile navigation stack
    func popToProfileRoot() {
        profilePath = NavigationPath()
    }

    /// Use this to show the success screen and clear previous delete steps
    func showAccountDeletedSuccess() {
        // Clear path so user can't go back to the "Delete Reason" screen
        profilePath = NavigationPath()
        profilePath.append(AppRoute.accountDeletedSuccess)
        // Depending on your setup, you might need to append a new route
        // or change appState. Let's append the route if you add it to AppRoute:
        // profilePath.append(AppRoute.accountDeletedSuccess)
    }

    /// Reset everything and go to Main (Feed)
    func resetToMain() {
        profilePath = NavigationPath()
        feedPath = NavigationPath()
        ordersPath = NavigationPath()
        chatsPath = NavigationPath()
        selectedTab = .feed
        appState = .main
    }
    
    func navigate(to state: AppState) {
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
    
    func showNextFilter(from current: AppState) {
        switch current {
        case .addressDetails:   navigate(to: .filterOccasion)
        case .filterOccasion:   navigate(to: .filterBouquetType)
        case .filterBouquetType: navigate(to: .filterFlowers)
        case .filterFlowers:    navigate(to: .filterPrice)
        case .filterPrice:      finishFilters()
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
    
    func completeAddressSetup(details: AddressDetails) {
        LocationService.shared.saveFullAddress(details: details)
        stateHistory.removeAll()
        navigate(to: .filterOccasion)
    }
    
    func showAccountSettings() {
        profilePath.append(AppRoute.accountSettings)
    }
    
    func showEditProfileField(_ fieldType: ProfileFieldType) {
        profilePath.append(AppRoute.editProfileField(fieldType))
    }
    
    func showOTPVerification(phone: String, mode: VerificationMode) {
        profilePath.append(AppRoute.otpVerification(phone: phone, mode: mode))
    }

    func showEmailOTPVerification(email: String, mode: VerificationMode) {
        profilePath.append(AppRoute.emailOtpVerification(email: email, mode: mode))
    }
    
    func goBack() {
        guard let previous = stateHistory.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            self.appState = previous
        }
    }
}
