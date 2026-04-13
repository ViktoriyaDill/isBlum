import Foundation
import UIKit
import Supabase

struct FailedMessage: Identifiable {
    let id = UUID()
    let text: String?
    let image: UIImage?
}

@MainActor
class ChatRoomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var order: Order?
    @Published var isLoading = false
    @Published var messageText = ""
    @Published var isSending = false
    @Published var isShowingCachedData = false
    @Published var failedMessages: [FailedMessage] = []

    private let client = SupabaseService.shared.client
    private var realtimeTask: Task<Void, Never>?

    let chatId: UUID
    private let orderId: UUID?
    private let visibleFrom: Date?  // nil = show all; non-nil = show only messages after this date

    init(chatId: UUID, orderId: UUID?, cachedOrder: Order? = nil, visibleFrom: Date? = nil) {
        self.chatId = chatId
        self.orderId = orderId
        self.order = cachedOrder
        self.visibleFrom = visibleFrom
    }

    // MARK: - Fetch Order (lazy, only if not pre-loaded)

    func fetchOrderIfNeeded() async {
        guard order == nil, let orderId else { return }
        do {
            var fetched: Order = try await client
                .from("orders")
                .select("""
                    id, status, seller_id, total, subtotal,
                    delivery_fee, delivery_address, created_at, delivery_time,
                    order_items (id, product_id, product_title, product_image_url, price_at_purchase),
                    reviews!reviews_order_id_fkey (id, rating, comment, tags, images)
                """)
                .eq("id", value: orderId)
                .single()
                .execute()
                .value

            // Fetch seller profile separately (no direct FK)
            struct SellerRow: Decodable {
                let shopName: String
                let logoUrl: String?
                let isVerified: Bool?
                enum CodingKeys: String, CodingKey {
                    case shopName = "shop_name"
                    case logoUrl = "logo_url"
                    case isVerified = "is_verified"
                }
            }
            if let seller = try? await client
                .from("seller_profiles")
                .select("shop_name, logo_url, is_verified")
                .eq("id", value: fetched.sellerId)
                .single()
                .execute()
                .value as SellerRow {
                fetched.sellerProfile = SellerProfile(
                    shopName: seller.shopName,
                    logoUrl: seller.logoUrl,
                    isVerified: seller.isVerified
                )
            }

            order = fetched
        } catch {
            print("ChatRoomViewModel fetchOrderIfNeeded error:", error)
        }
    }

    // MARK: - Fetch

    func fetchMessages() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let iso = ISO8601DateFormatter()
            var query = client
                .from("messages")
                .select("id, chat_id, sender_id, text, image_url, is_read, created_at")
                .eq("chat_id", value: chatId)

            if let visibleFrom {
                query = query.gte("created_at", value: iso.string(from: visibleFrom))
            }

            let msgs: [Message] = try await query
                .order("created_at", ascending: true)
                .execute()
                .value
            self.messages = msgs
            CacheService.save(msgs, key: "messages_\(chatId)")
            isShowingCachedData = false
        } catch {
            print("ChatRoomViewModel fetchMessages error:", error)
            if let cached = CacheService.load([Message].self, key: "messages_\(chatId)"), !cached.isEmpty {
                self.messages = cached
                self.isShowingCachedData = true
            }
        }
    }

    // MARK: - Send

    func sendMessage() async {
        let trimmed = messageText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let userId = client.auth.currentUser?.id else { return }

        messageText = ""
        isSending = true
        defer { isSending = false }

        do {
            struct NewMessage: Encodable {
                let chatId: UUID
                let senderId: UUID
                let text: String
                enum CodingKeys: String, CodingKey {
                    case chatId = "chat_id"
                    case senderId = "sender_id"
                    case text
                }
            }
            try await client
                .from("messages")
                .insert(NewMessage(chatId: chatId, senderId: userId, text: trimmed))
                .execute()
            await fetchMessages()
        } catch {
            print("ChatRoomViewModel sendMessage error:", error)
            failedMessages.append(FailedMessage(text: trimmed, image: nil))
        }
    }

    func retry(_ failed: FailedMessage) async {
        failedMessages.removeAll { $0.id == failed.id }
        if let text = failed.text {
            messageText = text
            await sendMessage()
        } else if let image = failed.image {
            await sendImage(image)
        }
    }

    // MARK: - Send image

    func sendImage(_ image: UIImage) async {
        guard let userId = client.auth.currentUser?.id else { return }
        isSending = true
        defer { isSending = false }
        do {
            let publicUrl = try await ImageUploadService.upload(
                image, bucket: "chat-images", folder: chatId.uuidString
            )
            struct NewMessage: Encodable {
                let chatId: UUID
                let senderId: UUID
                let imageUrl: String
                enum CodingKeys: String, CodingKey {
                    case chatId = "chat_id"
                    case senderId = "sender_id"
                    case imageUrl = "image_url"
                }
            }
            try await client
                .from("messages")
                .insert(NewMessage(chatId: chatId, senderId: userId, imageUrl: publicUrl))
                .execute()
            await fetchMessages()
        } catch {
            print("ChatRoomViewModel sendImage error:", error)
            failedMessages.append(FailedMessage(text: nil, image: image))
        }
    }

    // MARK: - Mark as read

    func markMessagesAsRead() async {
        guard let userId = client.auth.currentUser?.id else { return }
        do {
            let response = try await client
                .from("messages")
                .update(["is_read": true])
                .eq("chat_id", value: chatId)
                .neq("sender_id", value: userId)
                .eq("is_read", value: false)
                .execute()
            print("markMessagesAsRead: status \(response.status)")
        } catch {
            print("markMessagesAsRead error:", error)
        }
    }

    // MARK: - Realtime

    func subscribeToMessages() {
        realtimeTask = Task {
            let channel = client.realtimeV2.channel("messages:\(chatId)")

            let inserts = channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "messages",
                filter: "chat_id=eq.\(chatId)"
            )

            await channel.subscribe()

            for await _ in inserts {
                await fetchMessages()
                await markMessagesAsRead()
            }
        }
    }

    func unsubscribe() {
        realtimeTask?.cancel()
        realtimeTask = nil
    }
}
