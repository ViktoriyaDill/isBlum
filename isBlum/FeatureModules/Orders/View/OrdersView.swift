//
//  OrdersView.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 21/03/2026.
//

import Foundation
import SwiftUI


struct OrdersView: View {
    @StateObject private var viewModel = OrdersViewModel()
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "orders_nav_title",
                showBackButton: false
            )
            
            if viewModel.isShowingCachedData {
                offlineBanner
            }

            ZStack {
                Color.white
                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(edges: .bottom)

                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    emptyStateView
                } else {
                    ordersList
                }
            }
        }
        .background(Color(hex: "#B8EEA6").opacity(0.2))
        .task {
            await viewModel.fetchOrders()
            viewModel.subscribeToOrderUpdates()
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
    }
    
    // MARK: - Offline Banner
    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13, weight: .medium))
            Text("offline_cached_data")
                .font(.onest(.medium, size: 13))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.8))
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            
            Image(.ordersEmptyIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.bottom, 32)
            
            Text("orders_empty_title")
                .font(.onest(.bold, size: 24))
                .padding(.bottom, 12)
            
            Text("orders_empty_description")
                .font(.onest(.regular, size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {  coordinator.selectedTab = .feed  }) {
                Text("orders_empty_button")
                    .font(.onest(.medium, size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#B8EEA6"))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }
    
    // MARK: - Orders List
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.orders) { order in
                    OrderRowCard(order: order)
                }
            }
            .padding(.bottom, 60)
            .padding(20)
        }
    }
}


#Preview {
    OrdersView()
        .environmentObject(AppCoordinator())
        .environmentObject(OrdersViewModel())
}
