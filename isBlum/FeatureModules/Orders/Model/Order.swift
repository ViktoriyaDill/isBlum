//
//  Order.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 21/03/2026.
//

import Foundation

struct Order: Identifiable, Codable, Hashable {
    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id: UUID
    var status: String
    let sellerId: UUID
    let total: Double
    let subtotal: Double?
    let deliveryFee: Double?
    let deliveryAddress: String?
//    let promoDiscount: Double?
    let mainImageUrl: String?
    var sellerProfile: SellerProfile?
    let createdAt: Date
    let deliveryTime: Date?
    let deliveryTimeEnd: Date?
    var items: [OrderItem]
    var review: OrderReview?

    enum CodingKeys: String, CodingKey {
        case id
        case sellerId = "seller_id"
        case status
        case total
        case subtotal
        case deliveryFee = "delivery_fee"
        case deliveryAddress = "delivery_address"
        case mainImageUrl = "main_image_url"
        case sellerProfile = "seller_profiles"
        case createdAt = "created_at"
        case deliveryTimeEnd = "delivery_time_end"
        case deliveryTime = "delivery_time"
        case items = "order_items"
        case review = "reviews"
    }

    var statusDisplay: (text: String, textColor: String, color: String, icon: String) {
        switch status.lowercased() {
        case "pending":
            return ("На підтвердженні", "#89731D", "#FDFBF0", "hourglass")
        case "confirmed":
            return ("Підтверджено", "#1D5C89", "#F0F7FD", "inPreparation")
        case "preparing":
            return ("Збираємо букет", "#485662", "#F0F7FD", "inPreparation")
        case "delivering":
            return ("Кур'єр в дорозі", "#485662", "#F0F7FD", "inPreparation")
        case "delivered":
            return ("Замовлення виконано", "#0F6D0F", "#F1FDF0", "accepted")
        case "cancelled":
            return ("Скасовано", "#8B0000", "#FDF0F0", "hourglass")
        default:
            return (status, "#808080", "#FFFFFF", "hourglass")
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: createdAt)
    }

    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy, HH:mm"
        return formatter.string(from: createdAt)
    }

    var formattedTotal: String {
        "\(Int(total)) грн"
    }

    var shortId: String {
        "blum-" + id.uuidString.prefix(6).lowercased()
    }

    // First item image for preview
    var previewImageUrl: String? {
        items.first?.productImageUrl
    }

    var shopName: String {
        sellerProfile?.shopName ?? "Flower Shop"
    }

    var formattedDeliveryWindow: String? {
        guard let start = deliveryTime else { return nil }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "uk_UA")

        let calendar = Calendar.current
        let timeRange = deliveryTimeEnd != nil
            ? "\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: deliveryTimeEnd!))"
            : timeFormatter.string(from: start)

        if calendar.isDateInToday(start) {
            return "Сьогодні \(timeRange)"
        } else if calendar.isDateInTomorrow(start) {
            return "Завтра \(timeRange)"
        } else {
            dateFormatter.dateFormat = "d MMM"
            return "\(dateFormatter.string(from: start)) \(timeRange)"
        }
    }

    // Product titles joined
    var itemsTitles: String {
        items.map { $0.productTitle }.joined(separator: ", ")
    }

}

struct OrderItem: Identifiable, Codable {
    let id: UUID
    let productId: UUID
    let productTitle: String
    let productImageUrl: String?
    let priceAtPurchase: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case productTitle = "product_title"
        case productImageUrl = "product_image_url"
        case priceAtPurchase = "price_at_purchase"
    }
}

struct OrderReview: Codable {
    let id: UUID
    let rating: Int
    let comment: String?
    let tags: [String]?
    let images: [String]? 
}

struct SellerProfile: Codable {
    let shopName: String
    let logoUrl: String?
    let isVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case logoUrl = "logo_url"
        case isVerified = "is_verified"
    }
}
