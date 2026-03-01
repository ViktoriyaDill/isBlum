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

    var body: some Scene {
        WindowGroup {
            RootCoordinatorView()
                .environmentObject(authViewModel)
                .environmentObject(coordinator)
                .environmentObject(filterVM)
                .onOpenURL { url in
                    guard url.scheme == "isblum" else { return }
                    Task {
                        await authViewModel.handleAuthCallback(url: url)
                    }
                }
        }
    }
}
