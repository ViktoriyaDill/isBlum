import Foundation

struct Message: Identifiable, Decodable, Equatable {
    let id: UUID
    let chatId: UUID
    let senderId: UUID
    let text: String?
    let imageUrl: String?
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case senderId = "sender_id"
        case text
        case imageUrl = "image_url"
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
