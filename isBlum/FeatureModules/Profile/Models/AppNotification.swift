//
//  AppNotification.swift
//  isBlum
//
//  Created by Пользователь on 15/03/2026.
//

import Foundation

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let date: String
    var isRead: Bool
}
