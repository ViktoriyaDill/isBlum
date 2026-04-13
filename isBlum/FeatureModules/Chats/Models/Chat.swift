import Foundation

struct Chat: Identifiable, Codable, Hashable {
    let id: UUID
    let clientId: UUID
    let sellerId: UUID
    let orderId: UUID?
    let lastMessage: String?
    let lastMessageAt: Date?
    let lastSenderId: UUID?
    let lastMessageIsImage: Bool
    let clientDeletedAt: Date?
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
        case lastSenderId = "last_sender_id"
        case lastMessageIsImage = "last_message_is_image"
        case clientDeletedAt = "client_deleted_at"
        case createdAt = "created_at"
        // Enriched — absent in DB response, present in local cache
        case sellerName = "seller_name"
        case isSellerVerified = "is_seller_verified"
        case unreadCount = "unread_count"
        case isVirtual = "is_virtual"
    }

    init(
        id: UUID,
        clientId: UUID,
        sellerId: UUID,
        orderId: UUID?,
        lastMessage: String?,
        lastMessageAt: Date?,
        lastSenderId: UUID?,
        lastMessageIsImage: Bool,
        clientDeletedAt: Date?,
        createdAt: Date
    ) {
        self.id                 = id
        self.clientId           = clientId
        self.sellerId           = sellerId
        self.orderId            = orderId
        self.lastMessage        = lastMessage
        self.lastMessageAt      = lastMessageAt
        self.lastSenderId       = lastSenderId
        self.lastMessageIsImage = lastMessageIsImage
        self.clientDeletedAt    = clientDeletedAt
        self.createdAt          = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,   forKey: .id)
        clientId           = try c.decode(UUID.self,   forKey: .clientId)
        sellerId           = try c.decode(UUID.self,   forKey: .sellerId)
        orderId            = try c.decodeIfPresent(UUID.self,   forKey: .orderId)
        lastMessage        = try c.decodeIfPresent(String.self, forKey: .lastMessage)
        lastMessageAt      = try c.decodeIfPresent(Date.self,   forKey: .lastMessageAt)
        lastSenderId       = try c.decodeIfPresent(UUID.self,   forKey: .lastSenderId)
        lastMessageIsImage = (try? c.decode(Bool.self, forKey: .lastMessageIsImage)) ?? false
        clientDeletedAt    = try c.decodeIfPresent(Date.self,   forKey: .clientDeletedAt)
        createdAt          = try c.decode(Date.self,   forKey: .createdAt)
        // Enriched (from local cache; absent when decoding from DB → use defaults)
        sellerName         = (try? c.decode(String.self, forKey: .sellerName))       ?? "Магазин"
        isSellerVerified   = (try? c.decode(Bool.self,   forKey: .isSellerVerified)) ?? false
        unreadCount        = (try? c.decode(Int.self,    forKey: .unreadCount))       ?? 0
        isVirtual          = (try? c.decode(Bool.self,   forKey: .isVirtual))         ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                 forKey: .id)
        try c.encode(clientId,           forKey: .clientId)
        try c.encode(sellerId,           forKey: .sellerId)
        try c.encodeIfPresent(orderId,           forKey: .orderId)
        try c.encodeIfPresent(lastMessage,       forKey: .lastMessage)
        try c.encodeIfPresent(lastMessageAt,     forKey: .lastMessageAt)
        try c.encodeIfPresent(lastSenderId,      forKey: .lastSenderId)
        try c.encode(lastMessageIsImage, forKey: .lastMessageIsImage)
        try c.encodeIfPresent(clientDeletedAt,   forKey: .clientDeletedAt)
        try c.encode(createdAt,          forKey: .createdAt)
        try c.encode(sellerName,         forKey: .sellerName)
        try c.encode(isSellerVerified,   forKey: .isSellerVerified)
        try c.encode(unreadCount,        forKey: .unreadCount)
        try c.encode(isVirtual,          forKey: .isVirtual)
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

    /// Slightly darker shade of avatarColor for the icon foreground (~60% brightness)
    var avatarIconColor: String {
        let hex = avatarColor
        guard hex.count == 6,
              let r = UInt8(hex.prefix(2), radix: 16),
              let g = UInt8(hex.dropFirst(2).prefix(2), radix: 16),
              let b = UInt8(hex.dropFirst(4).prefix(2), radix: 16) else { return hex }
        let factor: Double = 0.6
        return String(
            format: "%02X%02X%02X",
            UInt8(Double(r) * factor),
            UInt8(Double(g) * factor),
            UInt8(Double(b) * factor)
        )
    }
}
