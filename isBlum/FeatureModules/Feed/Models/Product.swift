import Foundation

// MARK: - ProductImage

struct ProductImage: Codable, Identifiable, Hashable {
    let id: UUID
    let productId: UUID
    let url: String
    let position: Int

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case url
        case position
    }
}

// MARK: - Product

struct Product: Codable, Identifiable, Hashable {
    let id: UUID
    let sellerId: UUID
    let title: String
    let description: String?
    let price: Double
    let currency: String
    let isAvailable: Bool
    let rating: Double?
    let totalReviews: Int?
    let images: [ProductImage]

    // Enriched from seller_profiles (not in DB response, populated manually)
    var sellerName: String
    var sellerLogoUrl: String?
    var isSellerVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case sellerId = "seller_id"
        case title
        case description
        case price
        case currency
        case isAvailable = "is_available"
        case rating
        case totalReviews = "total_reviews"
        case images = "product_images"
        case sellerName = "seller_name"
        case sellerLogoUrl = "seller_logo_url"
        case isSellerVerified = "is_seller_verified"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sellerId = try container.decode(UUID.self, forKey: .sellerId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "UAH"
        isAvailable = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) ?? true
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        totalReviews = try container.decodeIfPresent(Int.self, forKey: .totalReviews)
        images = try container.decodeIfPresent([ProductImage].self, forKey: .images) ?? []
        sellerName = try container.decodeIfPresent(String.self, forKey: .sellerName) ?? ""
        sellerLogoUrl = try container.decodeIfPresent(String.self, forKey: .sellerLogoUrl)
        isSellerVerified = try container.decodeIfPresent(Bool.self, forKey: .isSellerVerified) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sellerId, forKey: .sellerId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(totalReviews, forKey: .totalReviews)
        try container.encode(images, forKey: .images)
        try container.encode(sellerName, forKey: .sellerName)
        try container.encodeIfPresent(sellerLogoUrl, forKey: .sellerLogoUrl)
        try container.encode(isSellerVerified, forKey: .isSellerVerified)
    }

    // MARK: - Computed

    var formattedPrice: String {
        let intPrice = Int(price)
        return "\(intPrice) грн"
    }

    var sortedImages: [ProductImage] {
        images.sorted { $0.position < $1.position }
    }
}
