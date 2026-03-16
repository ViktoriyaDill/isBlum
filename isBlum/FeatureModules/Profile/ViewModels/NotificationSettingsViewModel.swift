//
//  NotificationSettingsViewModel.swift
//  isBlum
//

import Foundation
import SwiftUI
import Supabase
import UserNotifications

@MainActor
class NotificationSettingsViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var orderStatusEnabled = true
    @Published var deliveryReminderEnabled = true
    @Published var promotionsEnabled = false
    @Published var deliveryMethod = "push"
    @Published var isLoading = false
    
    private let client = SupabaseService.shared.client
    
    // MARK: - Fetch Settings
    func fetchSettings(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let settings: NotificationSettings = try await client
                .from("notification_settings")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            
            self.orderStatusEnabled = settings.orderStatusEnabled
            self.deliveryReminderEnabled = settings.deliveryReminderEnabled
            self.promotionsEnabled = settings.promotionsEnabled
            self.deliveryMethod = settings.deliveryMethod
            
        } catch {
            // No settings yet — use defaults
            print("Fetch settings error (using defaults):", error)
        }
    }
    
    // MARK: - Save Settings
    func saveSettings(userId: UUID) {
        Task {
            do {
                try await client
                    .from("notification_settings")
                    .upsert([
                        "user_id": userId.uuidString,
                        "order_status_enabled": orderStatusEnabled.description,
                        "delivery_reminder_enabled": deliveryReminderEnabled.description,
                        "promotions_enabled": promotionsEnabled.description,
                        "delivery_method": deliveryMethod
                    ], onConflict: "user_id")
                    .execute()
            } catch {
                print("Save settings error:", error)
            }
        }
    }
    
    // MARK: - Request Push Permission
    func requestPushPermission() {
        Task {
            let granted = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted == true {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                // User denied — revert to email
                deliveryMethod = "email"
            }
        }
    }
}


