//
//  HabitPixelWidget.swift
//  HabitPixelWidget
//
//  Created by Mohamed Elatabany on 29/03/2025.
//

import WidgetKit
import SwiftUI

// ADD: Color hex initializer
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
    let primary: Color = Color(hex: 0xFF6B6B)
    let onPrimary: Color = .white
    let background: Color = .black
    let surface: Color = Color(hex: 0x1C1C1E)
    let onBackground: Color = .white
    let outline: Color = Color(hex: 0x3C3C3E)
    var caption: Color = Color(hex: 0x848485)
    
    static var current: ColorScheme {
        ColorScheme()
    }
}

// The data model for your widget
struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [HabitDisplayInfo]
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

// The provider generates the widget's timeline
struct Provider: TimelineProvider {
    let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")
    
    func placeholder(in context: Context) -> HabitEntry {
        print("Widget loading placeholder content")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create sample habit with realistic data
        return HabitEntry(date: Date(), habits: [
            HabitDisplayInfo(
                id: "placeholder",
                title: "Sample Habit",
                iconName: "star.fill",
                color: Color(hex: 0xFF6B6B),
                completedDates: Set([today]), // Show today as completed for preview
                startDate: today,
                endDate: today
            )
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let habits = loadHabits()
        let entry = HabitEntry(date: Date(), habits: habits)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> ()) {
        let habits = loadHabits()
        let currentDate = Date()
        
        // Create entries for more frequent updates
        let entries = [
            HabitEntry(date: currentDate, habits: habits),
            HabitEntry(date: Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!, habits: habits)
        ]
        
        let timeline = Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!))
        completion(timeline)
    }
    
    private func loadHabits() -> [HabitDisplayInfo] {
        guard let data = defaults?.data(forKey: "WidgetHabits") else {
            print("Widget: No data found in UserDefaults")
            return sampleHabits
        }
        
        do {
            let habits = try JSONDecoder().decode([HabitDisplayInfo].self, from: data)
            print("Widget: Successfully loaded \(habits.count) habits")
            return habits
        } catch {
            print("Widget: Failed to decode habits: \(error)")
            return sampleHabits
        }
    }
    
    private var sampleHabits: [HabitDisplayInfo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return [
            HabitDisplayInfo(
                id: "sample",
                title: "Sample",
                iconName: "star.fill",
                color: Color(hex: 0xFF6B6B),
                completedDates: Set([today]),
                startDate: today,
                endDate: today
            )
        ]
    }
}

struct HabitPixelWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    let colors = ColorScheme.current
    
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
                
                if let habit = entry.habits.first {
                    VStack(spacing: 0) {
                        // Compact header for small widget
                        HStack(spacing: 4) {
                            Image(systemName: habit.iconName)
                                .font(.system(size: geometry.size.height * 0.11))
                                .foregroundColor(habit.color)
                            
                            Text(habit.title)
                                .font(.system(size: geometry.size.height * 0.11, weight: .medium))
                                .foregroundColor(colors.onBackground)
                                .lineLimit(1)
                        }
                        .frame(height: geometry.size.height * 0.15)
                        .padding(.top, 4)
                        
                        // Optimized grid for small widget
                        ActivityGridView(
                            habit: habit,
                            colors: colors,
                            containerWidth: geometry.size.width * 0.98,
                            containerHeight: geometry.size.height * 0.82,
                            isSmallWidget: true
                        )
                        .padding(.horizontal, 2)
                    }
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
                
                if let habit = entry.habits.first {
                    VStack(spacing: 0) {
                        // Spacious header for medium widget
                        HStack {
                            Image(systemName: habit.iconName)
                                .font(.system(size: geometry.size.height * 0.12))
                                .foregroundColor(habit.color)
                            
                            Text(habit.title)
                                .font(.system(size: geometry.size.height * 0.12, weight: .medium))
                                .foregroundColor(colors.onBackground)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        .padding(.horizontal, geometry.size.width * 0.03)
                        .padding(.vertical, geometry.size.height * 0.02)
                        .frame(height: geometry.size.height * 0.15)
                        
                        // Full-size grid for medium widget
                        ActivityGridView(
                            habit: habit,
                            colors: colors,
                            containerWidth: geometry.size.width * 0.97,
                            containerHeight: geometry.size.height * 0.83,
                            isSmallWidget: false
                        )
                        .padding(.horizontal, geometry.size.width * 0.015)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}

struct HabitPixelWidget: Widget {
    let kind: String = "HabitPixelWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HabitPixelWidgetEntryView(entry: entry)
                    .containerBackground(.black, for: .widget)
            } else {
                HabitPixelWidgetEntryView(entry: entry)
                    .background(Color.black)
            }
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your habits progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
