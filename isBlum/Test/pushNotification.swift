//
//  pushNotification.swift
//  isBlum
//
//  Created by Пользователь on 16/03/2026.
//

import Foundation
import SwiftUI


func sendTestLocalNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Нове замовлення"
    content.body = "Ваш букет готується"
    content.badge = 1
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 3,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request)
}

