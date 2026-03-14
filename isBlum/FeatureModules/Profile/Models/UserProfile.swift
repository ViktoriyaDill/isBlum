//
//  UserProfile.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI

struct UserNotification: Codable {
    var orderNotifications: Bool
    var deliveryReminders: Bool
    var marketingNotifications: Bool
    var notificationMethod: String
    
    enum CodingKeys: String, CodingKey {
        case orderNotifications = "order_notifications"
        case deliveryReminders = "delivery_reminders"
        case marketingNotifications = "marketing_notifications"
        case notificationMethod = "notification_method"
    }
}
