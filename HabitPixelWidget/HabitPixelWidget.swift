//
//  HabitPixelWidget.swift
//  HabitPixelWidget
//
//  Created by Mohamed Elatabany on 29/03/2025.
//

import WidgetKit
import SwiftUI
import AppIntents


struct HabitEntry: TimelineEntry {
    let date: Date
    let habit: HabitDisplayInfo
    let isFreeHabit: Bool
    
    init(date: Date, habit: HabitDisplayInfo, isFreeHabit: Bool = true) {
        self.date = date
        self.habit = habit
        self.isFreeHabit = isFreeHabit
    }
}


struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: .now, habit: HabitsHelper.loadAllHabits()?.first ?? HabitsHelper.noHabitDisplayInfo)    }
    
    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> HabitEntry {
        HabitEntry(date: .now, habit: HabitsHelper.loadAllHabits()?.first ?? HabitsHelper.noHabitDisplayInfo)
    }
    
    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<HabitEntry> {
        let selectedTitle = configuration.habit
        let allHabits = HabitsHelper.loadAllHabits()
        
        let selectedHabit = allHabits?.first(where: { $0.title == selectedTitle }) ?? HabitsHelper.noHabitDisplayInfo
        
        let isFreeHabit = selectedHabit.id == allHabits?.first?.id
        
        let entry = HabitEntry(
            date: .now,
            habit: selectedHabit,
            isFreeHabit: isFreeHabit
        )
        
        // Set next update to the start of the next day (12:00 AM)
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let nextUpdateDate = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }}

struct HabitPixelWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    private var isPro: Bool {
        return true
        UserDefaults(suiteName: "group.com.atabany.HabitPixel")?.bool(forKey: "isPro") ?? false
    }
    
    private var colors: ColorScheme {
        ColorScheme(systemScheme: colorScheme)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if entry.habit.id == HabitsHelper.noHabitDisplayInfo.id {
                    NoHabitsView(colors: colors)
                } else {
                    switch widgetFamily {
                    case .systemSmall:
                        SmallWidgetView(entry: entry, colors: colors)
                    case .systemMedium:
                        MediumWidgetView(entry: entry, colors: colors)
                    default:
                        Text("Unsupported widget size")
                    }
                }
                
                if !isPro && !entry.isFreeHabit {
                    UpgradeOverlayView(colors: colors)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(-20)
                }
            }
        }
    }
}

struct HabitPixelWidget: Widget {
    let kind: String = "HabitPixelWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectHabitIntent.self,
            provider: Provider()
        ) { entry in
            HabitPixelWidgetEntryViewWrapper(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track progress for a selected habit.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HabitPixelWidgetEntryViewWrapper: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    private var colors: ColorScheme {
        ColorScheme(systemScheme: colorScheme)
    }

    var body: some View {
        HabitPixelWidgetEntryView(entry: entry)
            .containerBackground(colors.background, for: .widget)
    }
}
