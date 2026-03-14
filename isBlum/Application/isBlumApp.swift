//
//  isBlumApp.swift
//  isBlum
//
//  Created by Пользователь on 08/02/2026.
//

import SwiftUI
import SwiftData
import Supabase

@main
struct isBlumApp: App {
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
