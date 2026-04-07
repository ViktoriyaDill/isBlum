import Foundation
import Supabase

@MainActor
class ChatRoomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var messageText = ""
    @Published var isSending = false

    private let client = SupabaseService.shared.client
    private var realtimeTask: Task<Void, Never>?

    let chatId: UUID

    init(chatId: UUID) {
        self.chatId = chatId
    }

    // MARK: - Fetch

    func fetchMessages() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let msgs: [Message] = try await client
                .from("messages")
                .select("id, chat_id, sender_id, text, image_url, is_read, created_at")
                .eq("chat_id", value: chatId)
                .order("created_at", ascending: true)
                .execute()
                .value
            self.messages = msgs
        } catch {
            print("ChatRoomViewModel fetchMessages error:", error)
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
        } catch {
            messageText = trimmed
            print("ChatRoomViewModel sendMessage error:", error)
        }
    }

    // MARK: - Mark as read

    func markMessagesAsRead() async {
        guard let userId = client.auth.currentUser?.id else { return }
        do {
            try await client
                .from("messages")
                .update(["is_read": true])
                .eq("chat_id", value: chatId)
                .neq("sender_id", value: userId)
                .eq("is_read", value: false)
                .execute()
        } catch {
            print("ChatRoomViewModel markAsRead error:", error)
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
