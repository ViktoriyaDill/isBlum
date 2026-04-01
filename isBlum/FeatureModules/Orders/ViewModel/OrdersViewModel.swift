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
        print("DEBUG fetchOrders: currentUser = \(client.auth.currentUser?.id.uuidString ?? "NIL - not logged in")")
        guard let userId = client.auth.currentUser?.id else {
            print("DEBUG fetchOrders: guard failed, no user")
            return
        }
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
                    subtotal,
                    delivery_fee,
                    delivery_address,
                    created_at,
                    delivery_time,
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
            
            print("DEBUG fetchOrders: fetched \(fetchedOrders.count) orders")

            // Fetch seller profiles separately (no direct FK to seller_profiles)
            let sellerIds = Array(Set(fetchedOrders.map { $0.sellerId }))
            if !sellerIds.isEmpty {
                struct SellerProfileFetch: Decodable {
                    let id: UUID
                    let shopName: String
                    let logoUrl: String?
                    let isVerified: Bool?
                    enum CodingKeys: String, CodingKey {
                        case id
                        case shopName = "shop_name"
                        case logoUrl = "logo_url"
                        case isVerified = "is_verified"
                    }
                }
                let profiles: [SellerProfileFetch] = try await client
                    .from("seller_profiles")
                    .select("id, shop_name, logo_url, is_verified")
                    .in("id", values: sellerIds)
                    .execute()
                    .value

                var enriched = fetchedOrders
                for i in enriched.indices {
                    if let profile = profiles.first(where: { $0.id == enriched[i].sellerId }) {
                        enriched[i].sellerProfile = SellerProfile(
                            shopName: profile.shopName,
                            logoUrl: profile.logoUrl,
                            isVerified: profile.isVerified
                        )
                    }
                }
                self.orders = enriched
            } else {
                self.orders = fetchedOrders
            }

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

            let changes = channel.postgresChange(
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
