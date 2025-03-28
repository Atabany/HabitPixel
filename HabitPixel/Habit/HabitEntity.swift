import Foundation
import SwiftUI
import SwiftData

@Model
final class HabitEntity {
    // Basic properties
    var title: String
    var habitDescription: String
    var goal: Int
    var frequency: String
    var iconName: String
    var category: String
    var createdAt: Date
    
    // Color properties
    var colorRed: Double
    var colorGreen: Double
    var colorBlue: Double
    var colorOpacity: Double
    
    // Feature properties
    var reminderTime: Date?
    var reminderDays: [String]
    var isArchived: Bool
    
    @Relationship(deleteRule: .cascade) var entries: [EntryEntity] = []
    
    var color: Color {
        get {
            Color(.sRGB, red: colorRed, green: colorGreen, blue: colorBlue, opacity: colorOpacity)
        }
        set {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var opacity: CGFloat = 0
            UIColor(newValue).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
            colorRed = Double(red)
            colorGreen = Double(green)
            colorBlue = Double(blue)
            colorOpacity = Double(opacity)
        }
    }
    
    // Optimized caching system
    @Transient private var completionCache: CompletionCache?
    
    // Cache structure for O(1) lookups
    private class CompletionCache {
        var dateMap: [String: Bool] = [:]
        var firstDate: Date?
        var lastDate: Date?
        var sortedDates: [Date]?
        
        init(entries: [EntryEntity]) {
            let calendar = Calendar.current
            let dates = entries.map { calendar.startOfDay(for: $0.timestamp) }
            
            // Pre-compute sorted dates
            sortedDates = dates.sorted()
            firstDate = sortedDates?.first
            lastDate = sortedDates?.last
            
            // Build lookup map
            dateMap = Dictionary(uniqueKeysWithValues:
                dates.map { date -> (String, Bool) in
                    let key = Self.makeKey(date)
                    return (key, true)
                }
            )
        }
        
        static func makeKey(_ date: Date) -> String {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return "\(components.year!)-\(components.month!)-\(components.day!)"
        }
        
        func isCompleted(_ date: Date) -> Bool {
            dateMap[Self.makeKey(date)] ?? false
        }
        
        func addCompletion(_ date: Date) {
            let key = Self.makeKey(date)
            dateMap[key] = true
            
            // Update date range
            if let first = firstDate {
                if date < first {
                    firstDate = date
                }
            } else {
                firstDate = date
            }
            
            if let last = lastDate {
                if date > last {
                    lastDate = date
                }
            } else {
                lastDate = date
            }
            
            // Update sorted dates
            if sortedDates != nil {
                sortedDates?.append(date)
                sortedDates?.sort()
            }
        }
        
        func removeCompletion(_ date: Date) {
            let key = Self.makeKey(date)
            dateMap.removeValue(forKey: key)
            
            // Update sorted dates
            sortedDates?.removeAll { $0 == date }
            
            // Update date range if needed
            if date == firstDate {
                firstDate = sortedDates?.first
            }
            if date == lastDate {
                lastDate = sortedDates?.last
            }
        }
    }
    
    private func ensureCacheInitialized() {
        if completionCache == nil {
            completionCache = CompletionCache(entries: entries)
        }
    }
    
    var dateRange: (first: Date?, last: Date)? {
        ensureCacheInitialized()
        guard let cache = completionCache,
              let first = cache.firstDate,
              let last = cache.lastDate else { return nil }
        return (first, last)
    }
    
    init(
        title: String,
        description: String = "",
        goal: Int = 1,
        frequency: String = "Daily",
        iconName: String = "checkmark",
        color: Color = .blue,
        category: String = "None",
        createdAt: Date = Date(),
        reminderTime: Date? = nil,
        reminderDays: [String] = [],
        isArchived: Bool = false
    ) {
        self.title = title
        self.habitDescription = description
        self.goal = goal
        self.frequency = frequency
        self.iconName = iconName
        self.category = category
        self.createdAt = createdAt
        self.reminderTime = reminderTime
        self.reminderDays = reminderDays
        self.isArchived = isArchived
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        self.colorRed = Double(red)
        self.colorGreen = Double(green)
        self.colorBlue = Double(blue)
        self.colorOpacity = Double(opacity)
    }
}

extension HabitEntity {
    private var intervalType: Interval {
        Interval(rawValue: frequency) ?? .daily
    }
    
    func currentStreak(from date: Date = Date()) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: date)
        
        // Get current interval bounds
        let currentInterval = intervalType.getIntervalBounds(for: currentDate)
        let currentCompletions = getCompletionsInInterval(for: currentDate)
        
        // Include current interval if complete
        if currentCompletions >= goal {
            streak += 1
        }
        
        // Start checking from previous interval
        if let previousStart = calendar.date(byAdding: intervalType.calendarComponent, value: -1, to: currentInterval.start) {
            currentDate = previousStart
        }
        
        // Check backwards through intervals
        while true {
            let intervalBounds = intervalType.getIntervalBounds(for: currentDate)
            let completionsInInterval = getCompletionsInInterval(for: currentDate)
            
            if completionsInInterval >= goal {
                streak += 1
                // Move to previous interval
                if let previousStart = calendar.date(byAdding: intervalType.calendarComponent, value: -1, to: intervalBounds.start) {
                    currentDate = previousStart
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getCompletionsInInterval(for date: Date) -> Int {
        let bounds = intervalType.getIntervalBounds(for: date)
        let completions = entries.filter { entry in
            let timestamp = Calendar.current.startOfDay(for: entry.timestamp)
            return timestamp >= bounds.start && timestamp < bounds.end
        }.count
        return completions
    }
    
    func getCurrentInterval() -> (start: Date, end: Date) {
        intervalType.getIntervalBounds(for: Date())
    }
    
    func getCompletionsInCurrentInterval() -> Int {
        let currentInterval = getCurrentInterval()
        let currentCompletions = entries.filter { entry in
            let timestamp = Calendar.current.startOfDay(for: entry.timestamp)
            return timestamp >= currentInterval.start && timestamp < currentInterval.end
        }.count
        return currentCompletions
    }
    
    func getRemainingForCurrentInterval() -> Int {
        let currentCompletions = getCompletionsInCurrentInterval()
        if currentCompletions >= goal {
            return 0
        }
        return goal - currentCompletions
    }
    
    func isIntervalComplete(for date: Date) -> Bool {
        getCompletionsInInterval(for: date) >= goal
    }
    
    static func getCompletionsForDay(habit: HabitEntity, date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return habit.entries.filter { entry in
            calendar.isDate(calendar.startOfDay(for: entry.timestamp), inSameDayAs: startOfDay)
        }.count
    }
    
    static func toggleCompletion(habit: HabitEntity, date: Date, context: ModelContext) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        habit.ensureCacheInitialized()
        
        if habit.completionCache?.isCompleted(startOfDay) ?? false {
            // Remove completion
            if let existingEntry = habit.entries.first(where: {
                calendar.isDate($0.timestamp, inSameDayAs: startOfDay)
            }) {
                context.delete(existingEntry)
                habit.completionCache?.removeCompletion(startOfDay)
            }
        } else {
            // Add completion
            let entry = EntryEntity(timestamp: startOfDay, habit: habit)
            habit.entries.append(entry)
            habit.completionCache?.addCompletion(startOfDay)
        }
        
        try? context.save()
    }
    
    static func isDateCompleted(habit: HabitEntity, date: Date) -> Bool {
        habit.ensureCacheInitialized()
        let calendar = Calendar.current
        return habit.completionCache?.isCompleted(calendar.startOfDay(for: date)) ?? false
    }
    
    func validate() -> String? {
        if goal < 1 {
            return "Goal must be at least 1"
        }
        
        switch intervalType {
        case .weekly:
            if goal > 7 {
                return "Weekly goal cannot exceed 7 days"
            }
        case .monthly:
            if goal > 31 {
                return "Monthly goal cannot exceed 31 days"
            }
        default:
            break
        }
        
        return nil
    }
    
    var sortedEntries: [Date] {
        ensureCacheInitialized()
        return completionCache?.sortedDates ?? []
    }
    
    func calculateStreak(from date: Date = Date()) -> Int {
        ensureCacheInitialized()
        var streak = 0
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: date)
        
        while let cache = completionCache,
              cache.isCompleted(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    func invalidateCache() {
        completionCache = nil
    }
}
