import Foundation
import Supabase

@MainActor
class ChatsViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    @Published var error: String?

    private let client = SupabaseService.shared.client
    private var realtimeTask: Task<Void, Never>?

    // MARK: - Fetch

    func fetchChats() async {
        guard let userId = client.auth.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. Fetch raw chats for this client
            struct ChatRow: Decodable {
                let id: UUID
                let clientId: UUID
                let sellerId: UUID
                let orderId: UUID?
                let lastMessage: String?
                let lastMessageAt: Date?
                let createdAt: Date
                enum CodingKeys: String, CodingKey {
                    case id
                    case clientId = "client_id"
                    case sellerId = "seller_id"
                    case orderId = "order_id"
                    case lastMessage = "last_message"
                    case lastMessageAt = "last_message_at"
                    case createdAt = "created_at"
                }
            }

            let rows: [ChatRow] = try await client
                .from("chats")
                .select("id, client_id, seller_id, order_id, last_message, last_message_at, created_at")
                .eq("client_id", value: userId)
                .order("last_message_at", ascending: false, nullsFirst: false)
                .execute()
                .value

            guard !rows.isEmpty else {
                self.chats = []
                return
            }

            // 2. Enrich with seller profiles
            let sellerIds = Array(Set(rows.map { $0.sellerId }))
            struct SellerRow: Decodable {
                let id: UUID
                let shopName: String
                let isVerified: Bool?
                enum CodingKeys: String, CodingKey {
                    case id
                    case shopName = "shop_name"
                    case isVerified = "is_verified"
                }
            }
            let sellers: [SellerRow] = try await client
                .from("seller_profiles")
                .select("id, shop_name, is_verified")
                .in("id", values: sellerIds)
                .execute()
                .value

            let sellerMap: [UUID: SellerRow] = Dictionary(uniqueKeysWithValues: sellers.map { ($0.id, $0) })

            // 3. Fetch unread counts in one query
            let chatIds = rows.map { $0.id }
            struct UnreadRow: Decodable {
                let chatId: UUID
                enum CodingKeys: String, CodingKey { case chatId = "chat_id" }
            }
            let unreadRows: [UnreadRow] = try await client
                .from("messages")
                .select("chat_id")
                .in("chat_id", values: chatIds)
                .eq("is_read", value: false)
                .neq("sender_id", value: userId)
                .execute()
                .value

            var unreadMap: [UUID: Int] = [:]
            for row in unreadRows {
                unreadMap[row.chatId, default: 0] += 1
            }

            // 4. Assemble
            self.chats = rows.map { row in
                var chat = Chat(
                    id: row.id,
                    clientId: row.clientId,
                    sellerId: row.sellerId,
                    orderId: row.orderId,
                    lastMessage: row.lastMessage,
                    lastMessageAt: row.lastMessageAt,
                    createdAt: row.createdAt
                )
                if let seller = sellerMap[row.sellerId] {
                    chat.sellerName = seller.shopName
                    chat.isSellerVerified = seller.isVerified ?? false
                }
                chat.unreadCount = unreadMap[row.id] ?? 0
                return chat
            }

        } catch {
            print("ChatsViewModel fetchChats error:", error)
            self.error = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteChat(_ chat: Chat) async {
        do {
            try await client
                .from("chats")
                .delete()
                .eq("id", value: chat.id)
                .execute()
            chats.removeAll { $0.id == chat.id }
        } catch {
            print("ChatsViewModel deleteChat error:", error)
            self.error = error.localizedDescription
        }
    }

    // MARK: - Realtime

    func subscribeToUpdates() {
        guard let userId = client.auth.currentUser?.id else { return }

        realtimeTask = Task {
            let channel = client.realtimeV2.channel("chats_list:\(userId)")

            let changes = channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "chats",
                filter: "client_id=eq.\(userId)"
            )

            await channel.subscribe()

            for await _ in changes {
                await fetchChats()
            }
        }
    }

    func unsubscribe() {
        realtimeTask?.cancel()
        realtimeTask = nil
    }
}
