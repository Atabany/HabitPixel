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

// New placeholder view
struct UpgradeOverlayView: View {
    let colors: ColorScheme
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.background.opacity(0.05))

            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(colors.primary)
                        
                        Text("Track More Habits")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(colors.onBackground)
                        
                        Text("Upgrade to Pro to add widgets for all your habits")
                            .font(.system(size: 13))
                            .foregroundColor(colors.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                )
        }
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
        
        // Get first and last completion dates
        let firstCompletionDate = habit.completedDates.min()
        let lastCompletionDate = habit.completedDates.max()
        
        // Within habit's completion range (first completion to last completion)
        if let firstDate = firstCompletionDate,
           let lastDate = lastCompletionDate,
           startOfDay >= firstDate,
           startOfDay <= lastDate {
            return 0.4
        }
        
        // Before first completion or after last completion
        return 0.15
    }
}

// New placeholder view
struct NoHabitsView: View {
    let colors: ColorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 24))
                .foregroundColor(colors.primary)
            
            Text("No Habits Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(colors.onBackground)
                .multilineTextAlignment(.center)
            
            Text("Add habits in the app")
                .font(.system(size: 12))
                .foregroundColor(colors.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
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
                            .font(.system(size: geometry.size.height * 0.12))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.12, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                    }
                    .frame(height: geometry.size.height * 0.18)
                    .padding(.top, 4)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.98,
                        containerHeight: geometry.size.height * 0.78,
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
                            .font(.system(size: geometry.size.height * 0.13))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.13, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    .padding(.vertical, geometry.size.height * 0.02)
                    .frame(height: geometry.size.height * 0.18)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.97,
                        containerHeight: geometry.size.height * 0.8,
                        isSmallWidget: false
                    )
                    .padding(.horizontal, geometry.size.width * 0.015)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}

// Modify HabitSelectionIntent to conform to WidgetConfigurationIntent
struct HabitSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Choose a habit to display")

    @Parameter(title: "Habit", description: "The habit to display")
    var habit: HabitEntity
    
    var isFirstWidget: Bool?
    
    init() {
        self.habit = HabitEntity(id: "", title: "")
        self.isFirstWidget = true
    }
    
    init(habit: HabitEntity) {
        self.habit = habit
        self.isFirstWidget = true
    }

    static func allHabits() async throws -> [HabitEntity] {
        let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")
        guard let data = defaults?.data(forKey: "WidgetHabits") else { return [] }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            return habits.map { HabitEntity(id: $0.id, title: $0.title) }
        } catch {
            print("Error decoding widget data: \(error)")
            return []
        }
    }
}

// Provider using AppIntentTimelineProvider
struct Provider: AppIntentTimelineProvider {
    typealias Entry = HabitEntry
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
        // Empty recommendations - we'll handle default selection in snapshot
        return []
    }

    func placeholder(in context: Context) -> HabitEntry {
        let placeholderIntent = HabitSelectionIntent(habit: HabitEntity(id: Provider.noHabitDisplayInfo.id, title: Provider.noHabitDisplayInfo.title))
        return HabitEntry(date: Date(), habit: Provider.noHabitDisplayInfo, configuration: placeholderIntent)
    }

    func snapshot(for configuration: HabitSelectionIntent, in context: Context) async -> HabitEntry {
        var habitToDisplay: HabitDisplayInfo?
        var intentForEntry = configuration
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
        if finalHabit.id == Provider.noHabitDisplayInfo.id {
             intentForEntry = HabitSelectionIntent(habit: HabitEntity(id: finalHabit.id, title: finalHabit.title))
        }

        return HabitEntry(date: Date(), habit: finalHabit, configuration: intentForEntry)
    }

    func timeline(for configuration: HabitSelectionIntent, in context: Context) async -> Timeline<Entry> {
        let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")
        
        // Get the first habit from database for comparison
        let firstDatabaseHabit = await loadAllHabits()?.first
        let currentHabitId = configuration.habit.id
        
        // Update configuration
        var updatedConfig = configuration
        // Widget is free if it's for the first habit in database
        updatedConfig.isFirstWidget = currentHabitId == firstDatabaseHabit?.id || currentHabitId == Provider.noHabitDisplayInfo.id
        
        let entry = await snapshot(for: updatedConfig, in: context)
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }

    private func loadHabit(for id: String) async -> HabitDisplayInfo? {
        guard let data = defaults?.data(forKey: "WidgetHabits") else {
            print("No widget data found in UserDefaults")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            if let habit = habits.first(where: { $0.id == id }) {
                return habit
            } else {
                print("Habit with id \(id) not found in widget data")
                return nil
            }
        } catch {
            print("Error decoding widget data: \(error)")
            return nil
        }
    }

    private func loadAllHabits() async -> [HabitDisplayInfo]? {
        guard let data = defaults?.data(forKey: "WidgetHabits") else {
            print("No widget data found in UserDefaults")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            if habits.isEmpty {
                print("No habits found in widget data")
                return nil
            }
            return habits
        } catch {
            print("Error decoding widget data: \(error)")
            return nil
        }
    }
}

// Views work with the single habit from the Entry
struct HabitPixelWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    private var isPro: Bool {
        UserDefaults(suiteName: "group.com.atabany.HabitPixel")?.bool(forKey: "isPro") ?? false
    }
    
    private var isFirstWidget: Bool {
        entry.configuration.isFirstWidget ?? true
    }
    
    private var colors: ColorScheme {
        ColorScheme(systemScheme: colorScheme)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if entry.habit.id == Provider.noHabitDisplayInfo.id {
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
                
                // Show upgrade overlay for non-pro users trying to add/edit more than one widget
                if !isPro && !isFirstWidget {
                    UpgradeOverlayView(colors: colors)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(-20)
                }
            }
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
