//
//  NotificationSettings.swift
//  isBlum
//
//  Created by Пользователь on 16/03/2026.
//

import Foundation

// MARK: - Model
struct NotificationSettings: Codable {
    let userId: UUID
    var orderStatusEnabled: Bool
    var deliveryReminderEnabled: Bool
    var promotionsEnabled: Bool
    var deliveryMethod: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case orderStatusEnabled = "order_status_enabled"
        case deliveryReminderEnabled = "delivery_reminder_enabled"
        case promotionsEnabled = "promotions_enabled"
        case deliveryMethod = "delivery_method"
    }
}
