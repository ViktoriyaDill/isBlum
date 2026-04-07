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
            // 1. Fetch all user orders (id + seller_id needed for merging)
            struct OrderRef: Decodable {
                let id: UUID
                let sellerId: UUID
                let status: String
                let createdAt: Date
                enum CodingKeys: String, CodingKey {
                    case id, status
                    case sellerId = "seller_id"
                    case createdAt = "created_at"
                }
            }
            let orders: [OrderRef] = try await client
                .from("orders")
                .select("id, seller_id, status, created_at")
                .eq("client_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            // 2. Fetch existing chats
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
            let chatRows: [ChatRow] = try await client
                .from("chats")
                .select("id, client_id, seller_id, order_id, last_message, last_message_at, created_at")
                .eq("client_id", value: userId)
                .execute()
                .value

            let chatsByOrderId: [UUID: ChatRow] = Dictionary(
                uniqueKeysWithValues: chatRows.compactMap { row in
                    guard let oid = row.orderId else { return nil }
                    return (oid, row)
                }
            )

            // 3. Fetch seller profiles for all unique sellers
            let allSellerIds = Array(Set(orders.map { $0.sellerId }))
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
            var sellerMap: [UUID: SellerRow] = [:]
            if !allSellerIds.isEmpty {
                let sellers: [SellerRow] = try await client
                    .from("seller_profiles")
                    .select("id, shop_name, is_verified")
                    .in("id", values: allSellerIds)
                    .execute()
                    .value
                sellerMap = Dictionary(uniqueKeysWithValues: sellers.map { ($0.id, $0) })
            }

            // 4. Fetch unread counts for existing chats
            let existingChatIds = chatRows.map { $0.id }
            struct UnreadRow: Decodable {
                let chatId: UUID
                enum CodingKeys: String, CodingKey { case chatId = "chat_id" }
            }
            var unreadMap: [UUID: Int] = [:]
            if !existingChatIds.isEmpty {
                let unreadRows: [UnreadRow] = try await client
                    .from("messages")
                    .select("chat_id")
                    .in("chat_id", values: existingChatIds)
                    .eq("is_read", value: false)
                    .neq("sender_id", value: userId)
                    .execute()
                    .value
                for row in unreadRows {
                    unreadMap[row.chatId, default: 0] += 1
                }
            }

            // 5. Merge: each order → real chat or virtual chat
            var result: [Chat] = []
            for order in orders {
                let seller = sellerMap[order.sellerId]

                if let chatRow = chatsByOrderId[order.id] {
                    // Real chat exists — use it
                    var chat = Chat(
                        id: chatRow.id,
                        clientId: chatRow.clientId,
                        sellerId: chatRow.sellerId,
                        orderId: chatRow.orderId,
                        lastMessage: chatRow.lastMessage,
                        lastMessageAt: chatRow.lastMessageAt,
                        createdAt: chatRow.createdAt
                    )
                    chat.sellerName = seller?.shopName ?? "Магазин"
                    chat.isSellerVerified = seller?.isVerified ?? false
                    chat.unreadCount = unreadMap[chatRow.id] ?? 0
                    result.append(chat)
                } else {
                    // No chat yet — virtual placeholder
                    var chat = Chat(
                        id: UUID(),
                        clientId: userId,
                        sellerId: order.sellerId,
                        orderId: order.id,
                        lastMessage: nil,
                        lastMessageAt: nil,
                        createdAt: order.createdAt
                    )
                    chat.sellerName = seller?.shopName ?? "Магазин"
                    chat.isSellerVerified = seller?.isVerified ?? false
                    chat.isVirtual = true
                    result.append(chat)
                }
            }

            // Sort: real chats with messages first (by last_message_at desc),
            // then the rest by order creation date desc
            self.chats = result.sorted {
                let lhs = $0.lastMessageAt ?? $0.createdAt
                let rhs = $1.lastMessageAt ?? $1.createdAt
                return lhs > rhs
            }

        } catch {
            print("ChatsViewModel fetchChats error:", error)
            self.error = error.localizedDescription
        }
    }

    // MARK: - Open chat (find or create, then navigate)

    func openChat(_ chat: Chat, coordinator: AppCoordinator) async {
        guard let userId = client.auth.currentUser?.id,
              let orderId = chat.orderId else { return }

        if !chat.isVirtual {
            coordinator.chatsPath.append(AppRoute.chatRoom(chat: chat))
            return
        }

        // Virtual: find or create the real chat record
        do {
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

            let existing: [ChatRow] = try await client
                .from("chats")
                .select("id, client_id, seller_id, order_id, last_message, last_message_at, created_at")
                .eq("client_id", value: userId)
                .eq("seller_id", value: chat.sellerId)
                .eq("order_id", value: orderId)
                .execute()
                .value

            let row: ChatRow
            if let found = existing.first {
                row = found
            } else {
                struct NewChat: Encodable {
                    let clientId: UUID
                    let sellerId: UUID
                    let orderId: UUID
                    enum CodingKeys: String, CodingKey {
                        case clientId = "client_id"
                        case sellerId = "seller_id"
                        case orderId = "order_id"
                    }
                }
                let created: [ChatRow] = try await client
                    .from("chats")
                    .insert(NewChat(clientId: userId, sellerId: chat.sellerId, orderId: orderId))
                    .select("id, client_id, seller_id, order_id, last_message, last_message_at, created_at")
                    .execute()
                    .value
                guard let newRow = created.first else { return }
                row = newRow
            }

            var realChat = Chat(
                id: row.id,
                clientId: row.clientId,
                sellerId: row.sellerId,
                orderId: row.orderId,
                lastMessage: row.lastMessage,
                lastMessageAt: row.lastMessageAt,
                createdAt: row.createdAt
            )
            realChat.sellerName = chat.sellerName
            realChat.isSellerVerified = chat.isSellerVerified
            realChat.cachedOrder = chat.cachedOrder

            coordinator.chatsPath.append(AppRoute.chatRoom(chat: realChat))
        } catch {
            print("ChatsViewModel openChat error:", error)
        }
    }

    // MARK: - Delete

    func deleteChat(_ chat: Chat) async {
        guard !chat.isVirtual else {
            chats.removeAll { $0.id == chat.id }
            return
        }
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
