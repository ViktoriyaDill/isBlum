import Foundation

struct Chat: Identifiable, Decodable, Hashable {
    let id: UUID
    let clientId: UUID
    let sellerId: UUID
    let orderId: UUID?
    let lastMessage: String?
    let lastMessageAt: Date?
    let createdAt: Date

    // Enriched after fetch
    var sellerName: String = "Магазин"
    var isSellerVerified: Bool = false
    var unreadCount: Int = 0
    /// Passed when navigating from OrderDetailsView — not decoded from DB
    var cachedOrder: Order? = nil
    /// True for orders that have no chat record in DB yet
    var isVirtual: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case sellerId = "seller_id"
        case orderId = "order_id"
        case lastMessage = "last_message"
        case lastMessageAt = "last_message_at"
        case createdAt = "created_at"
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Chat, rhs: Chat) -> Bool { lhs.id == rhs.id }

    // MARK: - Helpers

    /// Time string formatted like messaging apps: HH:mm for today, dd.MM for same year, dd.MM.yy otherwise
    var formattedTime: String {
        guard let date = lastMessageAt ?? Optional(createdAt) else { return "" }
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(date) {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f.string(from: date)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            let f = DateFormatter()
            f.dateFormat = "dd.MM"
            return f.string(from: date)
        } else {
            let f = DateFormatter()
            f.dateFormat = "dd.MM.yy"
            return f.string(from: date)
        }
    }

    /// Deterministic pastel background color based on seller name
    static let pastelPalette: [String] = [
        "FFD6D6", "D6EFFF", "D6FFE0", "FFF3D6",
        "F0D6FF", "FFE8D6", "D6FFF5", "FFD6F5",
        "E8D6FF", "D6FFD6"
    ]

    var avatarColor: String {
        let sum = sellerName.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return Chat.pastelPalette[abs(sum) % Chat.pastelPalette.count]
    }

    var avatarLetter: String {
        String(sellerName.prefix(1)).uppercased()
    }
}
