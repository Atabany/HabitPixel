//
//  HabitPixelWidget.swift
//  HabitPixelWidget
//
//  Created by Mohamed Elatabany on 29/03/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

// Color hex initializer
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// Color scheme for widget
struct ColorScheme {
    let systemScheme: SwiftUI.ColorScheme // Store the system scheme

    // Define light mode colors
    private let lightPrimary: Color = Color(hex: 0xFF6B6B)
    private let lightOnPrimary: Color = .white
    private let lightBackground: Color = Color(hex: 0xF2F2F7) // System Background Light
    private let lightSurface: Color = .white             // Secondary System Background Light
    private let lightOnBackground: Color = .black
    private let lightOutline: Color = Color(hex: 0xD1D1D6) // System Gray 4 Light
    private let lightCaption: Color = Color(hex: 0x8E8E93) // System Gray Light

    // Define dark mode colors
    private let darkPrimary: Color = Color(hex: 0xFF6B6B)
    private let darkOnPrimary: Color = .white
    private let darkBackground: Color = .black             // System Background Dark
    private let darkSurface: Color = Color(hex: 0x1C1C1E) // Secondary System Background Dark
    private let darkOnBackground: Color = .white
    private let darkOutline: Color = Color(hex: 0x3C3C3E) // System Gray 4 Dark
    private let darkCaption: Color = Color(hex: 0x848485) // System Gray Dark (approximation)

    // Return colors based on systemScheme
    var primary: Color { systemScheme == .light ? lightPrimary : darkPrimary }
    var onPrimary: Color { systemScheme == .light ? lightOnPrimary : darkOnPrimary }
    var background: Color { systemScheme == .light ? lightBackground : darkBackground }
    var surface: Color { systemScheme == .light ? lightSurface : darkSurface }
    var onBackground: Color { systemScheme == .light ? lightOnBackground : darkOnBackground }
    var outline: Color { systemScheme == .light ? lightOutline : darkOutline }
    var caption: Color { systemScheme == .light ? lightCaption : darkCaption }

    init(systemScheme: SwiftUI.ColorScheme) {
        self.systemScheme = systemScheme
    }
}

// The data model for your widget
struct HabitEntry: TimelineEntry {
    let date: Date
    let habit: HabitDisplayInfo
    let configuration: HabitSelectionIntent
}

// Main activity grid view
struct ActivityGridView: View {
    let habit: HabitDisplayInfo
    let colors: ColorScheme
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let isSmallWidget: Bool
    
    let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday = 2
        return calendar
    }()
    
    private var layout: (cellSize: CGFloat, spacing: CGFloat) {
        let columns: CGFloat = isSmallWidget ? 11 : 20
        let rows: CGFloat = 7
        
        // Calculate maximum possible cell size
        let availableWidth = containerWidth
        let availableHeight = containerHeight
        
        let maxCellWidth = availableWidth / columns
        let maxCellHeight = availableHeight / rows
        
        // Use the smaller dimension to maintain square cells
        let cellSize = min(maxCellWidth, maxCellHeight) * (isSmallWidget ? 0.9 : 0.85)
        let spacing = cellSize * (isSmallWidget ? 0.15 : 0.2)
        
        return (cellSize: cellSize, spacing: spacing)
    }
    
    var body: some View {
        HStack(spacing: layout.spacing) {
            ForEach(0..<(isSmallWidget ? 11 : 20)) { columnIndex in
                VStack(spacing: layout.spacing) {
                    ForEach(0..<7) { dayIndex in
                        let weekOffset = (isSmallWidget ? 10 : 19) - columnIndex
                        let date = getDate(weekOffset: weekOffset, weekday: dayIndex)
                        let isCompleted = habit.completedDates.contains(date)
                        
                        RoundedRectangle(cornerRadius: layout.cellSize * 0.25)
                            .fill(habit.color)
                            .frame(width: layout.cellSize, height: layout.cellSize)
                            .opacity(getOpacity(for: date, isCompleted: isCompleted))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getDate(weekOffset: Int, weekday: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        let thisWeekMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let targetDate = calendar.date(byAdding: .day, value: -(weekOffset * 7) + weekday, to: thisWeekMonday)!
        return calendar.startOfDay(for: targetDate)
    }
    
    private func getOpacity(for date: Date, isCompleted: Bool) -> Double {
        if isCompleted {
            return 1.0
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        let habitStart = calendar.startOfDay(for: habit.startDate)
        let habitEnd = calendar.startOfDay(for: habit.endDate)
        
        // Future dates
        if startOfDay > today {
            return 0.15
        }
        
        // Past dates within range
        if startOfDay >= habitStart && startOfDay <= habitEnd {
            return 0.3
        }
        
        // Dates outside range
        return 0.15
    }
}

// Provider using AppIntentTimelineProvider
struct Provider: AppIntentTimelineProvider {
    typealias Entry  = HabitEntry
    typealias Intent = HabitSelectionIntent

    let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")

    // Static constant for the "No Habit" state
    static let noHabitDisplayInfo: HabitDisplayInfo = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return HabitDisplayInfo(
            id: "system_no_habit_placeholder",
            title: "No Habits Yet",
            iconName: "questionmark.diamond.fill",
            color: Color.gray,
            completedDates: Set(),
            startDate: today,
            endDate: today
        )
    }()

    func recommendations() -> [AppIntentRecommendation<HabitSelectionIntent>] {
        return []
    }

    // Placeholder returns the static "no habit" state
    func placeholder(in context: Context) -> HabitEntry {
        let placeholderIntent = HabitSelectionIntent(habit: HabitEntity(id: Provider.noHabitDisplayInfo.id, title: Provider.noHabitDisplayInfo.title))
        return HabitEntry(date: Date(), habit: Provider.noHabitDisplayInfo, configuration: placeholderIntent)
    }

    // MARK: Snapshot - Prioritize First Habit if Unconfigured
    func snapshot(for configuration: HabitSelectionIntent, in context: Context) async -> HabitEntry {
        var habitToDisplay: HabitDisplayInfo?
        var intentForEntry = configuration // Start with the received intent
        let requestedHabitId = configuration.habit.id
        let isEmptyOrPlaceholderId = requestedHabitId.isEmpty || requestedHabitId == Provider.noHabitDisplayInfo.id

        // 1. If configuration IS specific and valid, try loading that habit
        if !isEmptyOrPlaceholderId {
            habitToDisplay = await loadHabit(for: requestedHabitId)
        }

        // 2. If no specific habit was configured OR loading it failed, load the first habit
        if habitToDisplay == nil {
            if let firstHabit = await loadAllHabits()?.first {
                habitToDisplay = firstHabit
                // Update the intentForEntry to reflect the habit being displayed
                intentForEntry = HabitSelectionIntent(habit: HabitEntity(id: firstHabit.id, title: firstHabit.title))
            }
        }

        // 3. Fallback to "No Habit" state only if everything else fails
        let finalHabit = habitToDisplay ?? Provider.noHabitDisplayInfo
        // If we fell back to placeholder, ensure intent reflects that too
        if finalHabit.id == Provider.noHabitDisplayInfo.id {
             intentForEntry = HabitSelectionIntent(habit: HabitEntity(id: finalHabit.id, title: finalHabit.title))
        }

        return HabitEntry(date: Date(), habit: finalHabit, configuration: intentForEntry)
    }

    // MARK: Timeline - Prioritize First Habit if Unconfigured
    func timeline(for configuration: HabitSelectionIntent, in context: Context) async -> Timeline<Entry> {
        var habitToDisplay: HabitDisplayInfo?
        var intentForEntry = configuration // Start with the received intent
        let requestedHabitId = configuration.habit.id
        let isEmptyOrPlaceholderId = requestedHabitId.isEmpty || requestedHabitId == Provider.noHabitDisplayInfo.id
        var policy: TimelineReloadPolicy = .atEnd

        // 1. If configuration IS specific and valid, try loading that habit
        if !isEmptyOrPlaceholderId {
            habitToDisplay = await loadHabit(for: requestedHabitId)
        }

        // 2. If no specific habit was configured OR loading it failed, load the first habit
        if habitToDisplay == nil {
            if let firstHabit = await loadAllHabits()?.first {
                habitToDisplay = firstHabit
                // Update the intentForEntry to reflect the habit being displayed
                intentForEntry = HabitSelectionIntent(habit: HabitEntity(id: firstHabit.id, title: firstHabit.title))
            }
        }

        // 3. Fallback to "No Habit" state only if everything else fails
        let finalHabit = habitToDisplay ?? Provider.noHabitDisplayInfo
         // If we fell back to placeholder, ensure intent reflects that too
        if finalHabit.id == Provider.noHabitDisplayInfo.id {
             intentForEntry = HabitSelectionIntent(habit: HabitEntity(id: finalHabit.id, title: finalHabit.title))
        }

        // Set refresh policy only if we have a real habit
        if finalHabit.id != Provider.noHabitDisplayInfo.id {
            let currentDate = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            policy = .after(nextUpdateDate)
        }

        let entries = [HabitEntry(date: Date(), habit: finalHabit, configuration: intentForEntry)]
        return Timeline(entries: entries, policy: policy)
    }

    // MARK: Helper - Load specific habit data
    private func loadHabit(for id: String) async -> HabitDisplayInfo? {
        guard !id.isEmpty, id != Provider.noHabitDisplayInfo.id else { return nil }
        guard let allHabits = await loadAllHabits() else { return nil }
        return allHabits.first { $0.id == id }
    }

    // MARK: Helper - Load all habits array
    private func loadAllHabits() async -> [HabitDisplayInfo]? {
        // CHANGE: Use optional chaining `defaults?.data(...)`
        guard let data = defaults?.data(forKey: "WidgetHabits") else {
            // No habit data found in UserDefaults for the specified key, or defaults itself is nil.
            return nil
        }
        do {
            let habits = try JSONDecoder().decode([HabitDisplayInfo].self, from: data)
            return habits // Return potentially empty array
        } catch {
            // Error decoding habit data from UserDefaults.
            return nil
        }
    }
}

// Views work with the single habit from the Entry
struct HabitPixelWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    private var colors: ColorScheme {
        ColorScheme(systemScheme: colorScheme)
    }

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry, colors: colors)
        case .systemMedium:
            MediumWidgetView(entry: entry, colors: colors)
        default:
            Text("Unsupported widget size")
        }
    }
}

struct SmallWidgetView: View {
    let entry: HabitEntry
    let colors: ColorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                colors.background
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Image(systemName: entry.habit.iconName)
                            .font(.system(size: geometry.size.height * 0.11))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.11, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                    }
                    .frame(height: geometry.size.height * 0.15)
                    .padding(.top, 4)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.98,
                        containerHeight: geometry.size.height * 0.82,
                        isSmallWidget: true
                    )
                    .padding(.horizontal, 2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}

struct MediumWidgetView: View {
    let entry: HabitEntry
    let colors: ColorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                colors.background
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: entry.habit.iconName)
                            .font(.system(size: geometry.size.height * 0.12))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.12, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    .padding(.vertical, geometry.size.height * 0.02)
                    .frame(height: geometry.size.height * 0.15)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.97,
                        containerHeight: geometry.size.height * 0.83,
                        isSmallWidget: false
                    )
                    .padding(.horizontal, geometry.size.width * 0.015)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}

// Single Widget struct using AppIntentConfiguration
struct HabitPixelWidget: Widget {
    let kind: String = "HabitPixelWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: HabitSelectionIntent.self,
            provider: Provider()
        ) { entry in
            HabitPixelWidgetEntryViewWrapper(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track progress for a selected habit.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Wrapper view to access environment and apply container background
struct HabitPixelWidgetEntryViewWrapper: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    private var colors: ColorScheme {
        ColorScheme(systemScheme: colorScheme)
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            HabitPixelWidgetEntryView(entry: entry)
                .containerBackground(colors.background, for: .widget)
        } else {
            HabitPixelWidgetEntryView(entry: entry)
                .background(colors.background)
        }
    }
}
