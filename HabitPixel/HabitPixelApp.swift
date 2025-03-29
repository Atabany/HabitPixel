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
                .preferredColorScheme(getColorScheme())
        }
        .modelContainer(container)
    }
    
    private func getColorScheme() -> SwiftUI.ColorScheme? {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
