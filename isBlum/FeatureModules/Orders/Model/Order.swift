//
//  Order.swift
//  isBlum
//
//  Created by Viktoriia_Dill on 21/03/2026.
//

import Foundation

import Foundation

struct Order: Identifiable, Codable {
    let id: UUID
    var status: String
    let sellerId: UUID
    let total: Double
    let mainImageUrl: String?
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
        case mainImageUrl = "main_image_url"
        case createdAt = "created_at"
        case deliveryTimeEnd = "delivery_time_end"
        case deliveryTime = "delivery_time"
        case items = "order_items"
        case review = "reviews"
    }
    
    var statusDisplay: (text: String,textColor: String, color: String, icon: String) {
        switch status.lowercased() {
        case "pending":
            return ("На підтвердженні", "#89731D", "#FDFBF0", "hourglass")
        case "preparing":
            return ("Збираємо букет", "#485662", "#F0F7FD", "inPreparation")
        case "delivered":
            return ("Замовлення виконано", "#0F6D0F", "#F1FDF0",  "accepted")
        default:
            return (status, "808080", "FFFFFF",  "info.circle")
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: createdAt)
    }
    
    var formattedTotal: String {
        "\(Int(total)) грн"
    }
    
    // First item image for preview
    var previewImageUrl: String? {
        items.first?.productImageUrl
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
    let productTitle: String
    let productImageUrl: String?
    let priceAtPurchase: Double
    
    enum CodingKeys: String, CodingKey {
        case id
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
