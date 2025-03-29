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
    @AppStorage("selectedTheme") private var selectedTheme: ThemeMode = .system
    let container: ModelContainer
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        do {
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
                .applyTheme(themeManager)
                .environmentObject(themeManager)
        }
        .modelContainer(container)
    }
}
