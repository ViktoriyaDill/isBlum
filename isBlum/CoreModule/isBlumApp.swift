//
//  isBlumApp.swift
//  isBlum
//
//  Created by Пользователь on 08/02/2026.
//

import SwiftUI
import SwiftData

@main
struct isBlumApp: App {
    // Keep your SwiftData container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Replace ContentView with RootCoordinatorView
            // This is the starting point of your Navigation Logic
            RootCoordinatorView()
        }
        .modelContainer(sharedModelContainer)
    }
}
