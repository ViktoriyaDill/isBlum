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


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("LOG: Registered for remote notifications with token: \(tokenString)")
        
        // Save token if user is logged in
        Task {
            // Get current user ID from your Auth system
            if let userId = try? await SupabaseService.shared.client.auth.session.user.id {
                await SupabaseService.shared.updateDeviceToken(userId: userId, token: tokenString)
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("ERROR: Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
