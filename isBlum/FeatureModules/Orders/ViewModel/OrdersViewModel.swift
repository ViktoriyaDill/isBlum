//
//  OrdersViewModel.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 21/03/2026.
//

import Foundation
import Supabase

@MainActor
class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let client = SupabaseService.shared.client
    
    // MARK: - Fetch Orders with Items
    func fetchOrders() async {
        guard let userId = client.auth.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch orders with nested order_items
            let fetchedOrders: [Order] = try await client
                .from("orders")
                .select("""
                    id,
                    status,
                    seller_id,
                    total,
                    created_at,
                    delivery_time,
                    delivery_time_end,
                    seller_profiles (
                        shop_name
                    ),
                    order_items (
                        id,
                        product_id,
                        product_title,
                        product_image_url,
                        price_at_purchase
                    ),
                    reviews!reviews_order_id_fkey (
                        id,
                        rating,
                        comment,
                        tags,
                        images
                    )
                """)
                .eq("client_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.orders = fetchedOrders
            
        } catch {
            print("Fetch orders error:", error)
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Realtime subscription for order status updates
    private var realtimeTask: Task<Void, Never>?
    
    func subscribeToOrderUpdates() {
        guard let userId = client.auth.currentUser?.id else { return }
        
        realtimeTask = Task {
            let channel = client.realtimeV2.channel("orders:\(userId)")
            
            let changes = await channel.postgresChange(
                UpdateAction.self,
                schema: "public",
                table: "orders",
                filter: "client_id=eq.\(userId)"
            )
            
            await channel.subscribe()
            
            for await update in changes {
                // Update order status in local list
                if let idString = update.record["id"]?.stringValue,
                   let id = UUID(uuidString: idString),
                   let newStatus = update.record["status"]?.stringValue,
                   let index = orders.firstIndex(where: { $0.id == id }) {
                    orders[index].status = newStatus
                }
            }
        }
    }
    
    func unsubscribe() {
        realtimeTask?.cancel()
        realtimeTask = nil
    }
}
