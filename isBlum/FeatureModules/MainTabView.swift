import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    init() {
        // Hide the native tab bar to use the custom one
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $coordinator.selectedTab) {
                // Feed Tab
                NavigationStack(path: $coordinator.feedPath) {
                    Text("Feed View") // Replace with FeedView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.feed)
                
                // Orders Tab
                NavigationStack(path: $coordinator.ordersPath) {
                    Text("Orders View") // Replace with OrdersView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.orders)
                
                // Chats Tab
                NavigationStack(path: $coordinator.chatsPath) {
                    Text("Chats View") // Replace with ChatsView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.chats)
                
                // Profile Tab
                NavigationStack(path: $coordinator.profilePath) {
                    Text("Profile View") // Replace with ProfileView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destinationFactory(for: route)
                        }
                }
                .tag(TabItem.profile)
            }
            
            // Custom Tab Bar based on your screenshot
            customTabBar
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(for: .feed, title: "Стрічка", icon: "leaf.fill")
            tabButton(for: .orders, title: "Замовлення", icon: "doc.text")
            tabButton(for: .chats, title: "Чати", icon: "bubble.left")
            tabButton(for: .profile, title: "Профіль", icon: "person")
        }
        .frame(height: 70)
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, y: -5))
    }
    
    @ViewBuilder
    private func tabButton(for item: TabItem, title: String, icon: String) -> some View {
        Button {
            coordinator.selectedTab = item
        } label: {
            VStack(spacing: 4) {
                // Top Indicator from your screenshot
                Rectangle()
                    .fill(coordinator.selectedTab == item ? Color(hex: "9AF19A") : Color.clear)
                    .frame(width: 44, height: 3)
                    .cornerRadius(1.5)
                    .padding(.bottom, 8)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(coordinator.selectedTab == item ? .black : .gray)
        }
    }
    
    @ViewBuilder
    func destinationFactory(for route: AppRoute) -> some View {
        switch route {
        case .productDetails(let id): Text("Product \(id)")
        case .sellerProfile(let id): Text("Seller \(id)")
        case .orderDetails(let id): Text("Order \(id)")
        case .chatRoom(let partnerId): Text("Chat with \(partnerId)")
        case .settings: Text("Settings")
        case .editProfile: Text("Edit Profile")
        case .addressDetails(let address):
            AddressDetailsView(selectedAddress: address)
        }
    }
}
