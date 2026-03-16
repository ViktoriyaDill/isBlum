//
//  isBlumApp.swift
//  isBlum
//
//  Created by Пользователь on 08/02/2026.
//

import SwiftUI
import SwiftData
import UIKit
import Supabase

@main
struct isBlumApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var filterVM = FilterViewModel()
    
    // MARK: - Localization Support
    // We listen to the same key used in SelectionModalView
    @AppStorage("app_language") private var appLanguage: String = "uk"

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environmentObject(authViewModel)
                .environmentObject(coordinator)
                .environmentObject(filterVM)
                // MARK: - Inject Locale
                // This forces all views to redraw when appLanguage changes
                .environment(\.locale, .init(identifier: appLanguage))
                .onOpenURL { url in
                    guard url.scheme == "isblum" else { return }
                    Task {
                        await authViewModel.handleAuthCallback(url: url)
                    }
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - App Launch
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            print("Push permission: \(granted)")
        }
        return true
    }
    
    // MARK: - Show notification when app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
    
    // MARK: - Remote notifications
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("LOG: Device token: \(tokenString)")
        
        Task {
            if let userId = try? await SupabaseService.shared.client.auth.session.user.id {
                await SupabaseService.shared.updateDeviceToken(userId: userId, token: tokenString)
            }
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("ERROR: Failed to register: \(error.localizedDescription)")
    }
}
