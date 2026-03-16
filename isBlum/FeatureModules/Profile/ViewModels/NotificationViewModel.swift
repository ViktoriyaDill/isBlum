//
//  NotificationViewModel.swift
//  isBlum
//
//  Created by Пользователь on 15/03/2026.
//

import Foundation
import Supabase

@MainActor
class NotificationViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var unreadCount: Int = 0
    
    private let client = SupabaseService.shared.client
    private var realtimeTask: Task<Void, Never>?
    
    // MARK: - Fetch Notifications
    func fetchNotifications() async {
        guard let userId = client.auth.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data: [AppNotification] = try await client
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.notifications = data
            self.updateUnreadCount()
            
        } catch {
            print("Fetch notifications error:", error)
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Mark As Read
    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }
        
        // Optimistic update
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
        
        do {
            try await client
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: notification.id)
                .execute()
        } catch {
            // Revert optimistic update on failure
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].isRead = false
                updateUnreadCount()
            }
            print("Mark as read error:", error)
        }
    }
    
    // MARK: - Mark All As Read
    func markAllAsRead() async {
        guard let userId = client.auth.currentUser?.id else { return }
        
        // Optimistic update
        notifications = notifications.map {
            var n = $0; n.isRead = true; return n
        }
        updateUnreadCount()
        
        do {
            try await client
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
        } catch {
            // Revert on failure
            await fetchNotifications()
            print("Mark all as read error:", error)
        }
    }
    
    // MARK: - Delete Notification
    func deleteNotification(_ notification: AppNotification) async {
        // Optimistic update
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
        
        do {
            try await client
                .from("notifications")
                .delete()
                .eq("id", value: notification.id)
                .execute()
        } catch {
            // Revert on failure
            await fetchNotifications()
            print("Delete notification error:", error)
        }
    }
    
    // MARK: - Delete All Notifications
    func deleteAllNotifications() async {
        guard let userId = client.auth.currentUser?.id else { return }
        
        // Optimistic update
        notifications.removeAll()
        updateUnreadCount()
        
        do {
            try await client
                .from("notifications")
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            await fetchNotifications()
            print("Delete all notifications error:", error)
        }
    }
    
    // MARK: - Realtime Subscription
    // Listens for new notifications pushed from the backend
    func subscribeToRealtime() {
        guard let userId = client.auth.currentUser?.id else { return }
        
        realtimeTask = Task {
            let channel = client.realtimeV2.channel("notifications:\(userId)")
            
            let changes = await channel.postgresChange(
                InsertAction.self,
                schema: "public",
                table: "notifications",
                filter: "user_id=eq.\(userId)"
            )
            
            await channel.subscribe()
            
            for await insert in changes {
                // Decode new notification from realtime payload
                if let newNotification = decodeNotification(from: insert.record) {
                    // Prepend to list so newest appears first
                    self.notifications.insert(newNotification, at: 0)
                    self.updateUnreadCount()
                }
            }
        }
    }
    
    // MARK: - Unsubscribe Realtime
    func unsubscribeFromRealtime() {
        realtimeTask?.cancel()
        realtimeTask = nil
    }
    
    // MARK: - Save Push Token
    func savePushToken(_ token: String) async {
        guard let userId = client.auth.currentUser?.id else { return }
        
        do {
            try await client
                .from("push_tokens")
                .upsert([
                    "user_id": userId.uuidString,
                    "token": token,
                    "platform": "ios"
                ], onConflict: "user_id")
                .execute()
            
            print("Push token saved successfully")
        } catch {
            print("Save push token error:", error)
        }
    }
    
    // MARK: - Delete Push Token (on sign out)
    func deletePushToken() async {
        guard let userId = client.auth.currentUser?.id else { return }
        
        do {
            try await client
                .from("push_tokens")
                .delete()
                .eq("user_id", value: userId)
                .execute()
        } catch {
            print("Delete push token error:", error)
        }
    }
    
    // MARK: - Private Helpers
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func decodeNotification(from record: [String: AnyJSON]) -> AppNotification? {
        guard
            let idString = record["id"]?.stringValue,
            let id = UUID(uuidString: idString),
            let title = record["title"]?.stringValue
        else { return nil }
        
        return AppNotification(
            id: id,
            title: title,
            body: record["body"]?.stringValue ?? "",
            type: record["type"]?.stringValue ?? "",
            isRead: record["is_read"]?.boolValue ?? false,
            createdAt: formatDate(record["created_at"]?.stringValue ?? "")
        )
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoString) else { return "" }
        
        let now = Date()
        let diff = now.timeIntervalSince(date)
        
        // Less than 1 minute
        if diff < 60 {
            return "Зараз"
        }
        
        // Less than 1 hour
        if diff < 3600 {
            let minutes = Int(diff / 60)
            return "\(minutes) хв тому"
        }
        
        // Less than 24 hours
        if diff < 86400 {
            let hours = Int(diff / 3600)
            return "\(hours) год тому"
        }
        
        // Older — show full date
        let display = DateFormatter()
        display.locale = Locale(identifier: "uk_UA")
        display.dateFormat = "d MMMM, yyyy"
        return display.string(from: date)
    }
}
