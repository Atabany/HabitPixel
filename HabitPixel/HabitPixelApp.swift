//
//  HabitRixApp.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct HabitRixApp: App {
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
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<HabitEntity>(
                    predicate: #Predicate<HabitEntity> { habit in
                        !habit.isArchived // Sync only non-archived habits
                    }
                )
                let habits = try context.fetch(descriptor)

                // Convert habits to widget-friendly format
                let widgetHabits = habits.map { habit -> HabitDisplayInfo in
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())

                    // Get all entries for this habit
                    let entries = habit.entries

                    // Get completed dates and find first/last completion
                    let completedDates = Set(entries.map { calendar.startOfDay(for: $0.timestamp) })

                    let startDate: Date
                    let endDate: Date

                    // Determine start/end date based on entries or creation date
                    if let firstEntry = entries.min(by: { $0.timestamp < $1.timestamp }),
                       let lastEntry = entries.max(by: { $0.timestamp < $1.timestamp }) {
                        startDate = calendar.startOfDay(for: firstEntry.timestamp)
                        endDate = calendar.startOfDay(for: lastEntry.timestamp)
                    } else {
                        // Fallback if no entries - use creation date and today
                        startDate = calendar.startOfDay(for: habit.createdAt)
                        endDate = today // Use today as end date if no entries exist
                    }

                    return HabitDisplayInfo(
                        id: "\(habit.persistentModelID)", // Ensure ID is stable
                        title: habit.title,
                        iconName: habit.iconName,
                        color: habit.color,
                        completedDates: completedDates,
                        startDate: startDate, // Use calculated start date
                        endDate: endDate     // Use calculated end date
                    )
                }

                // Proceed only if there are habits to sync
                if !widgetHabits.isEmpty {
                    do {
                        let encoded = try JSONEncoder().encode(widgetHabits)
                        @AppStorage("WidgetHabits") var widgetHabitsData: Data = Data()
                        widgetHabitsData = encoded

                        // Reload widget timelines after successful sync
                        WidgetCenter.shared.reloadAllTimelines()
                    } catch {
                        // Log error - Failed to encode habits for widget sync. Error: \(error)
                    }
                } else {
                    // No active habits found to sync with the widget.
                    // Consider clearing widget data if needed:
                    // @AppStorage("WidgetHabits") private var widgetHabitsData: Data = Data()
                    // widgetHabitsData = Data()
                    // WidgetCenter.shared.reloadAllTimelines() // Reload to show empty/placeholder state
                }
            } catch {
                // Log error - Failed to fetch habits for widget sync. Error: \(error)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingContainerView()
                .applyTheme(themeManager)
                .environmentObject(themeManager)
                // Observe changes in the main context to trigger widget sync
                .onChange(of: container.mainContext.hasChanges) { _, hasChanges in
                    if hasChanges {
                        // Trigger widget sync when SwiftData context changes.
                        syncHabitsToWidget()
                    }
                }
        }
        .modelContainer(container)
    }
}
