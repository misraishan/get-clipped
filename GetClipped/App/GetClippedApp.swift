//
//  GetClippedApp.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftData
import SwiftUI

@main
struct GetClippedApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClipboardItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        MenuBarContentView()
            .menuBarExtraStyle(.automatic)
            .modelContainer(sharedModelContainer)

        WindowGroup("GetClipped", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
        .commands {
            // Removes the default "New Item" command
            CommandGroup(replacing: .newItem) {}
        }
    }
}
