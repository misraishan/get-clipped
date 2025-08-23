//
//  GetClippedApp.swift
//  GetClipped
//
//  Created by Ishan Misra on 8/23/25.
//

import SwiftUI
import SwiftData

@main
struct GetClippedApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor()

//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardMonitor)
        }
        .windowResizability(.contentSize)
//        .modelContainer(sharedModelContainer)
    }
}
