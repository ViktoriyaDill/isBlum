//
//  MainTabView.swift
//  isBlum
//
//  Created by Пользователь on 09/02/2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            
            // Feed Tab
            NavigationStack(path: $coordinator.feedPath) {
                Text("Feed View") // Replace with your FeedView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationFactory(for: route)
                    }
            }
            .tabItem { Label("Feed", systemImage: "flower.fill") }
            .tag(TabItem.feed)
            
            // Orders Tab
            NavigationStack(path: $coordinator.ordersPath) {
                Text("Orders View") // Replace with your OrdersView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationFactory(for: route)
                    }
            }
            .tabItem { Label("Orders", systemImage: "bag") }
            .tag(TabItem.orders)
            
            // Chats Tab
            NavigationStack(path: $coordinator.chatsPath) {
                Text("Chats View") // Replace with your ChatsView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationFactory(for: route)
                    }
            }
            .tabItem { Label("Chats", systemImage: "bubble.left") }
            .tag(TabItem.chats)
            
            // Profile Tab
            NavigationStack(path: $coordinator.profilePath) {
                Text("Profile View") // Replace with your ProfileView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destinationFactory(for: route)
                    }
            }
            .tabItem { Label("Profile", systemImage: "person") }
            .tag(TabItem.profile)
        }
    }
    
    // View Factory to centralize destination logic
    @ViewBuilder
    func destinationFactory(for route: AppRoute) -> some View {
        switch route {
        case .productDetails(let id):
            Text("Product Details for \(id)")
        case .sellerProfile(let id):
            Text("Seller Profile \(id)")
        case .orderDetails(let id):
            Text("Order \(id)")
        case .chatRoom(let partnerId):
            Text("Chatting with \(partnerId)")
        case .settings:
            Text("Settings View")
        case .editProfile:
            Text("Edit Profile View")
        }
    }
}
