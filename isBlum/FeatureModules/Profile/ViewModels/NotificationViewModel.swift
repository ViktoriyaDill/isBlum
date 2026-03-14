//
//  NotificationViewModel.swift
//  isBlum
//
//  Created by Пользователь on 14/03/2026.
//

import Foundation
import SwiftUI
import UserNotifications
import Supabase


@MainActor
class NotificationViewModel: ObservableObject {
    @Published var orderStatusEnabled = true
    @Published var deliveryReminderEnabled = true
    @Published var promotionsEnabled = true
    @Published var deliveryMethod: String = "push"
    
    // Using your shared Supabase client
    private let supabase = SupabaseService.shared.client
    
    // Fetch settings from Supabase profiles table
    func fetchSettings(userId: UUID) async {
        do {
            let profile: UserNotification = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            self.orderStatusEnabled = profile.orderNotifications
            self.deliveryReminderEnabled = profile.deliveryReminders
            self.promotionsEnabled = profile.marketingNotifications
            self.deliveryMethod = profile.notificationMethod
            
            print("LOG: Notification settings successfully fetched for user \(userId)")
        } catch {
            print("ERROR: Failed to fetch notification settings: \(error.localizedDescription)")
        }
    }
    
    // Update settings in Supabase
    func saveSettings(userId: UUID) {
        // English comments: Using the struct instead of [String: Any] to satisfy Encodable requirements
        let updateBody = UserNotification(
            orderNotifications: orderStatusEnabled,
            deliveryReminders: deliveryReminderEnabled,
            marketingNotifications: promotionsEnabled,
            notificationMethod: deliveryMethod
        )
        
        Task {
            do {
                try await supabase
                    .from("profiles")
                    .update(updateBody) // updateBody now conforms to Encodable
                    .eq("id", value: userId.uuidString)
                    .execute()
                
                print("LOG: Notification settings successfully updated in Supabase for user \(userId)")
            } catch {
                print("ERROR: Failed to update notification settings: \(error.localizedDescription)")
            }
        }
    }
    
    // Request iOS system permissions for Push Notifications
    func requestPushPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("LOG: Push notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("ERROR: Notification permission denied or failed: \(error.localizedDescription)")
            }
        }
    }
}
