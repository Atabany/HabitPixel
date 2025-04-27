//
//  HabitPixelApp.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

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
            
            // Initial widget data sync
            syncHabitsToWidget()
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    private func syncHabitsToWidget() {
        Task {
            do {
                print("Starting widget sync...")
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<HabitEntity>(
                    predicate: #Predicate<HabitEntity> { habit in
                        !habit.isArchived
                    }
                )
                let habits = try context.fetch(descriptor)
                print("Found \(habits.count) habits to sync")
                
                // Convert habits to widget-friendly format
                let widgetHabits = habits.map { habit -> HabitDisplayInfo in
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    
                    // Get all entries for this habit
                    let entries = habit.entries
                    print("Habit '\(habit.title)' has \(entries.count) entries")
                    
                    // Get completed dates and find first/last completion
                    let completedDates = Set(entries.map { calendar.startOfDay(for: $0.timestamp) })
                    
                    let startDate: Date
                    let endDate: Date
                    
                    if let firstEntry = entries.min(by: { $0.timestamp < $1.timestamp }),
                       let lastEntry = entries.max(by: { $0.timestamp < $1.timestamp }) {
                        startDate = calendar.startOfDay(for: firstEntry.timestamp)
                        endDate = calendar.startOfDay(for: lastEntry.timestamp)
                    } else {
                        // Fallback if no entries
                        startDate = calendar.startOfDay(for: habit.createdAt)
                        endDate = today
                    }
                    
                    print("Habit '\(habit.title)' date range: \(startDate) to \(endDate)")
                    
                    return HabitDisplayInfo(
                        id: "\(habit.persistentModelID)",
                        title: habit.title,
                        iconName: habit.iconName,
                        color: habit.color,
                        completedDates: completedDates,
                        startDate: startDate,
                        endDate: endDate
                    )
                }
                
                if !widgetHabits.isEmpty {
                    do {
                        let encoded = try JSONEncoder().encode(widgetHabits)
                        let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")
                        defaults?.set(encoded, forKey: "WidgetHabits")
                        
                        if defaults?.synchronize() == true {
                            print("Successfully synced \(widgetHabits.count) habits to widget")
                            WidgetCenter.shared.reloadAllTimelines()
                        } else {
                            print("Failed to synchronize UserDefaults")
                        }
                        
                        // Verify data was saved
                        if let savedData = defaults?.data(forKey: "WidgetHabits"),
                           let decoded = try? JSONDecoder().decode([HabitDisplayInfo].self, from: savedData) {
                            print("Verified saved data: found \(decoded.count) habits")
                        } else {
                            print("Failed to verify saved data")
                        }
                    } catch {
                        print("Failed to encode widget data: \(error)")
                    }
                } else {
                    print("No habits to sync")
                }
            } catch {
                print("Error syncing habits to widget: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HabitKitView()
                .applyTheme(themeManager)
                .environmentObject(themeManager)
                .onChange(of: container.mainContext.hasChanges) { _, hasChanges in
                    if hasChanges {
                        syncHabitsToWidget()
                    }
                }
        }
        .modelContainer(container)
    }
}
