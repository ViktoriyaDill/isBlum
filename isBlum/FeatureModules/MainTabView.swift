import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedTab) {
                NavigationStack(path: $coordinator.feedPath) {
                    Text("Feed View")
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.feed)
                
                NavigationStack(path: $coordinator.ordersPath) {
                    Text("Orders View")
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.orders)
                
                NavigationStack(path: $coordinator.chatsPath) {
                    Text("Chats View")
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.chats)
                
                NavigationStack(path: $coordinator.profilePath) {
                    ProfileView()
                        .environmentObject(authViewModel) 
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.profile)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .ignoresSafeArea(.keyboard)

            if isRootScreen {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isRootScreen)
    }
    
    private var isRootScreen: Bool {
        coordinator.feedPath.isEmpty &&
        coordinator.ordersPath.isEmpty &&
        coordinator.chatsPath.isEmpty &&
        coordinator.profilePath.isEmpty
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(for: .feed, title: "Стрічка", icon: .bouqetsLine)
            tabButton(for: .orders, title: "Замовлення", icon: .orders)
            tabButton(for: .chats, title: "Чати", icon: .chat)
            tabButton(for: .profile, title: "Профіль", icon: .profile)
        }
        .frame(height: 70)
        .padding(.bottom, 0)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    @ViewBuilder
    private func tabButton(for item: TabItem, title: String, icon: ImageResource) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                coordinator.selectedTab = item
            }
        } label: {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if coordinator.selectedTab == item {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(hex: "9AF19A"))
                            .frame(width: 80, height: 4)
                            .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .top)))
                        
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "9AF19A").opacity(0.4),
                                Color(hex: "9AF19A").opacity(0.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: 80, height: 20)
                        .transition(.opacity)
                    } else {
                        Color.clear
                            .frame(width: 80, height: 20)
                    }
                }
                .frame(height: 24)
                .padding(.bottom, 4)
                
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.bottom, 4)
                
                Text(title)
                    .font(.onest(.medium, size: 12))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(coordinator.selectedTab == item ? .black : Color.gray.opacity(0.6))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    func destinationFactory(for route: AppRoute) -> some View {
        switch route {
        case .productDetails(let id):
            Text("Product \(id)")
        case .sellerProfile(let id):
            Text("Seller \(id)")
        case .orderDetails(let id):
            Text("Order \(id)")
        case .chatRoom(let partnerId):
            Text("Chat with \(partnerId)")
        case .settings:
            Text("Settings")
        case .editProfile:
            Text("Edit Profile")
        case .addressDetails(let address):
            AddressDetailsView(selectedAddress: address)
        case .auth:
            AuthView()
                .environmentObject(authViewModel)
        case .phoneAuth:
            PhoneAuthView()
                .environmentObject(authViewModel)
        case .successAuth:
            SuccessAuthView()
        case .emailAuth:
            EmailAuthView()
                .environmentObject(authViewModel)
        case .userName:
            UserNameEntryView()
                .environmentObject(authViewModel)
        case .accountSettings:
            AccountSettingsView()
                .environmentObject(authViewModel)
        case .editProfileField(let fieldType):
            EditProfileFieldView(fieldType: fieldType)
                .environmentObject(authViewModel)
        case .otpVerification(let phone, let mode):
            VerifyCodeView(phoneNumber: phone, mode: mode)
                .environmentObject(authViewModel)
        case .emailOtpVerification(let email, let mode):
            VerifyEmailView(email: email, mode: mode)
                .environmentObject(authViewModel)
        case .deleteAccount:
            EmptyView()
//            DeleteAccountView()
//                .environmentObject(authViewModel)
        }
    }
}
