import SwiftUI
import WidgetKit
import SwiftData

@MainActor
final class HabitActivityGridViewModel: ObservableObject {
    let habit: HabitEntity
    
    // Constants
    let daysInWeek = 7
    let cellSize: CGFloat = 8
    let spacing: CGFloat = 2
    let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        return calendar
    }()
    
    var gridHeight: CGFloat {
        (cellSize + spacing) * CGFloat(daysInWeek) + 16
    }
    
    // State
    @Published private(set) var gridData: GridData?
    @Published private(set) var isUpdating = false
    @Published private(set) var currentStreak = 0
    
    var allHabits: [HabitEntity]
    
    init(habit: HabitEntity, allHabits: [HabitEntity]) {
        self.habit = habit
        self.allHabits = allHabits
        // Initial widget sync
        Task {
            await Self.syncWidget(allHabits)
        }
    }
    
    func loadInitialData() async {
        gridData = await calculateGridData()
        calculateStreak()
        await Self.syncWidget(allHabits)
    }
    
    func updateGridData() async {
        guard !isUpdating else { return }
        
        isUpdating = true
        let newData = await calculateGridData()
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.gridData = newData
                self.calculateStreak()
            }
            self.isUpdating = false
        }
        await Self.syncWidget(self.allHabits)
    }

    // Static helper to ensure consistent widget syncing
    private static func syncWidget(_ habits: [HabitEntity]) async {
        await HabitEntity.updateWidgetHabits(habits)
        // Note: WidgetCenter.shared.reloadAllTimelines() is now handled within HabitEntity.updateWidgetHabits
    }
    
    func getDate(weekIndex: Int, dayIndex: Int, startDate: Date) -> Date {
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)) ?? startDate
        let daysToAdd = weekIndex * daysInWeek + dayIndex
        return calendar.date(byAdding: .day, value: daysToAdd, to: weekStart) ?? startDate
    }
    
    func getCellOpacity(for date: Date, isCompleted: Bool) -> Double {
        let startOfDay = calendar.startOfDay(for: date)
        
        // Completed dates always have full opacity
        if isCompleted {
            return 1.0
        }
        
        // Get first and last completion dates
        let firstCompletionDate = habit.sortedEntries.first.map { calendar.startOfDay(for: $0) }
        let lastCompletionDate = habit.sortedEntries.last.map { calendar.startOfDay(for: $0) }
        
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
    
    func scrollToCurrentWeek(_ proxy: ScrollViewProxy, startDate: Date) {
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: Date())
        let currentWeek = components.weekOfYear ?? 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo(currentWeek, anchor: .trailing)
            }
        }
    }
    
    func calculateStreak(from date: Date = Date()) {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: date)
        var streak = 0
        
        // Calculate backwards from the given date
        while let data = gridData {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let completions = countCompletions(for: startOfDay, in: data.completedDates)
            
            // Check if daily goal was met
            if completions >= habit.goal {
                streak += 1
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = previousDay
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        withAnimation {
            currentStreak = streak
        }
    }
    
    private func countCompletions(for date: Date, in completedDates: Set<Date>) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        return completedDates.contains(startOfDay) ? 1 : 0
    }
    
    private func calculateGridData() async -> GridData {
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Get today's date at start of day
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // Calculate default date based on creation date
        let defaultStartDate = min(
            calendar.startOfDay(for: habit.createdAt),
            calendar.date(byAdding: .month, value: -15, to: today) ?? today
        )
        
        // Align to start of week
        let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: defaultStartDate)) ?? defaultStartDate
        
        // Calculate weeks including the current week
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
        let numberOfWeeks = max((components.weekOfYear ?? 0) + 1, 1)  // Ensure at least 1 week
        
        
        let completedDates = await withTaskGroup(of: Set<Date>.self) { group in
            let batchSize = 100
            let entries = habit.entries
            var result = Set<Date>()
            
            for batch in stride(from: 0, to: entries.count, by: batchSize) {
                group.addTask {
                    let end = min(batch + batchSize, entries.count)
                    return Set(entries[batch..<end].map {
                        self.calendar.startOfDay(for: $0.timestamp)
                    })
                }
            }
            
            for await batchSet in group {
                result.formUnion(batchSet)
            }
            
            return result
        }
        
        // Always include today in the date range
        let dateRange: (first: Date?, last: Date)? = {
            if !habit.sortedEntries.isEmpty {
                return (habit.sortedEntries.first, today)
            } else {
                return (startDate, today)
            }
        }()
        
        return GridData(
            startDate: startDate,
            numberOfWeeks: numberOfWeeks,
            completedDates: completedDates,
            dateRange: dateRange
        )
    }
}
