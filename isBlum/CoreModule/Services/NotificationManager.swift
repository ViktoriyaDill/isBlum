//
//  NotificationManager.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI
import UserNotifications
import Supabase



// MARK: - Data Transfer Object
// English: Using a dedicated struct to ensure Encodable compliance for Supabase updates
struct NotificationUpdatePayload: Encodable {
    let order_notifications: Bool
    let delivery_reminders: Bool
    let marketing_notifications: Bool
    let notification_method: String
}

@MainActor
class NotificationManager: ObservableObject {
    
    // Using your shared client from SupabaseService
    private let supabase = SupabaseService.shared.client
    
    /// Requests system permission for push notifications
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                // English: Register for remote notifications to trigger token generation in AppDelegate
                await UIApplication.shared.registerForRemoteNotifications()
                print("LOG: Notification permission granted")
            } else {
                print("LOG: Notification permission denied")
            }
        } catch {
            print("ERROR: Notification permission request failed: \(error.localizedDescription)")
        }
    }
    
    /// Updates user notification preferences in Supabase profiles table
    func updateNotificationSettings(
        userId: UUID,
        orderStatus: Bool,
        reminders: Bool,
        marketing: Bool,
        method: String
    ) async {
        // English: Create a concrete Encodable object instead of [String: Any]
        let payload = NotificationUpdatePayload(
            order_notifications: orderStatus,
            delivery_reminders: reminders,
            marketing_notifications: marketing,
            notification_method: method
        )
        
        do {
            try await supabase
                .from("profiles")
                .update(payload) // English: Correctly passes Encodable struct
                .eq("id", value: userId.uuidString)
                .execute()
            
            print("LOG: Notification settings successfully saved to Supabase for user \(userId)")
        } catch {
            print("ERROR: Failed to save notification settings: \(error.localizedDescription)")
        }
    }
}
