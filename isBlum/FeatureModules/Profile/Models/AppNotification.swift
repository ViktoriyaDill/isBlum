//
//  AppNotification.swift
//  isBlum
//
//  Created by Пользователь on 15/03/2026.
//

import Foundation

struct AppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let type: String
    var isRead: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case type
        case isRead = "is_read"
        case createdAt = "created_at"
    }
    
    // Formatted date for display
    var date: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: createdAt) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: createdAt) else { return createdAt }
            return formatRelativeDate(date)
        }
        return formatRelativeDate(date)
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        
        if diff < 60 {
            return String(localized: "date_now")
        }
        if diff < 3600 {
            let minutes = Int(diff / 60)
            return String(format: String(localized: "date_minutes_ago"), minutes)
        }
        if diff < 86400 {
            let hours = Int(diff / 3600)
            return String(format: String(localized: "date_hours_ago"), hours)
        }
        if diff < 604800 {
            let days = Int(diff / 86400)
            return String(format: String(localized: "date_days_ago"), days)
        }
        
        let display = DateFormatter()
        display.locale = Locale.current
        display.dateFormat = "d MMMM, yyyy"
        return display.string(from: date)
    }
}
