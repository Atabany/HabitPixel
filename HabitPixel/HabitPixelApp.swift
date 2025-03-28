//
//  HabitPixelApp.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI
import SwiftData

@main
struct HabitPixelApp: App {
    let container: ModelContainer
    
    init() {
        do {
            // Basic schema configuration
            let schema = Schema([HabitEntity.self, EntryEntity.self])
            let config = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HabitKitView()
        }
        .modelContainer(container)
    }
}
