import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.profile)
            }
            
            customTabBar
                .opacity(isRootScreen ? 1 : 0)
                .allowsHitTesting(isRootScreen)
            
        }
        .animation(.easeInOut(duration: 0.2), value: isRootScreen)
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
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, y: -5))
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
        case .otpVerification(let number):
            VerifyCodeView(phoneNumber: number)
                .environmentObject(authViewModel)
        case .successAuth:
            SuccessAuthView()
        }
    }
}
