import SwiftUI
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
    
    init(habit: HabitEntity) {
        self.habit = habit
    }
    
    func loadInitialData() async {
        gridData = await calculateGridData()
        calculateStreak()
    }
    
    func updateGridData() async {
        isUpdating = true
        defer { isUpdating = false }
        
        let newData = await calculateGridData()
        if gridData != newData {
            withAnimation(.easeInOut(duration: 0.2)) {
                gridData = newData
                calculateStreak()
            }
        }
    }
    
    func getDate(weekIndex: Int, dayIndex: Int, startDate: Date) -> Date {
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)) ?? startDate
        let daysToAdd = weekIndex * daysInWeek + dayIndex
        return calendar.date(byAdding: .day, value: daysToAdd, to: weekStart) ?? startDate
    }
    
    func getCellOpacity(for date: Date, isCompleted: Bool) -> Double {
        guard let data = gridData,
              let (firstDate, lastDate) = data.dateRange else {
            return 0.15
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        
        if isCompleted {
            return 1.0
        }
        
        if let first = firstDate,
           startOfDay >= calendar.startOfDay(for: first),
           startOfDay <= calendar.startOfDay(for: lastDate) {
            return 0.3
        }
        
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
    
    func toggleCompletion(for date: Date) {
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        guard targetDate <= today else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            HabitEntity.toggleCompletion(habit: habit, date: date, context: habit.modelContext!)
            calculateStreak()
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
        
        let defaultDate = calendar.date(byAdding: .month, value: -15, to: calendar.startOfDay(for: Date())) ?? Date()
        
        let startDate: Date
        if let earliestEntry = habit.entries.min(by: { $0.timestamp < $1.timestamp }) {
            let entryDate = calendar.startOfDay(for: earliestEntry.timestamp)
            if entryDate < defaultDate {
                startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entryDate)) ?? entryDate
            } else {
                startDate = defaultDate
            }
        } else {
            startDate = defaultDate
        }
        
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
        let numberOfWeeks = (components.weekOfYear ?? 0) + 1
        
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
        
        let dateRange: (first: Date?, last: Date)?
        if !habit.sortedEntries.isEmpty {
            dateRange = (habit.sortedEntries.first, habit.sortedEntries.last!)
        } else {
            dateRange = nil
        }
        
        return GridData(
            startDate: startDate,
            numberOfWeeks: numberOfWeeks,
            completedDates: completedDates,
            dateRange: dateRange
        )
    }
}
