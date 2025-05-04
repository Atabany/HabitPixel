import SwiftUI
import Charts

struct InsightsTab: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    @State private var selectedInsight: InsightType = .patterns
    
    enum InsightType: String, CaseIterable {
        case patterns = "Patterns"
        case progress = "Progress"
        case suggestions = "Suggestions"
    }
        
    var body: some View {
        VStack(spacing: 24) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(InsightType.allCases, id: \.self) { insight in
                        InsightTypeButton(
                            type: insight,
                            isSelected: selectedInsight == insight,
                            action: { selectedInsight = insight }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            if timeFrame == .all {
                Text("'All Time' is not supported in Insights. Please select Week, Month, or Year.")
                    .font(.headline)
                    .foregroundColor(Color.theme.caption)
                    .padding()
            } else {
                switch selectedInsight {
                case .patterns:
                    HabitPatterns(habits: habits, timeFrame: timeFrame)
                case .progress:
                    HabitProgress(habits: habits, timeFrame: timeFrame)
                case .suggestions:
                    HabitSuggestions(habits: habits)
                }
            }
        }
    }
}

struct InsightTypeButton: View {
    let type: InsightsTab.InsightType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.theme.primary : Color.clear)
                .foregroundColor(isSelected ? .white : Color.theme.onBackground)
                .clipShape(Capsule())
        }
    }
}

struct HabitPatterns: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                BestDayOfWeekChart(habits: habits, timeFrame: timeFrame)
                TimeOfDayChart(habits: habits, timeFrame: timeFrame)
                ConsistencyChart(habits: habits, timeFrame: timeFrame)
            }
            .padding(.vertical)
        }
    }
}

struct HabitProgress: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                LongestStreaksView(habits: habits)
                GoalAchievementRateView(habits: habits, timeFrame: timeFrame)
                HabitGrowthChart(habits: habits)
            }
            .padding(.vertical)
        }
    }
}

struct HabitSuggestions: View {
    let habits: [HabitEntity]

    var body: some View {
        VStack(spacing: 24) {
            Text("Suggestions coming soon! (e.g., best days, reminders, milestones, etc.)")
                .font(.headline)
                .padding()
        }
    }
}

// MARK: - Best/Worst Day of the Week Chart
struct BestDayOfWeekChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        let data = calculateBestDays()
        Chart(data, id: \ .day) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Completions", item.count)
            )
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let day = value.as(Int.self) {
                    AxisValueLabel {
                        Text(Calendar.current.shortWeekdaySymbols[day])
                    }
                }
            }
        }
        .frame(height: 180)
        .padding()
    }

    private func calculateBestDays() -> [(day: Int, count: Int)] {
        var dayCounts = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        for habit in habits {
            for entry in habit.entries where interval.contains(entry.timestamp) {
                let weekday = calendar.component(.weekday, from: entry.timestamp) - 1
                dayCounts[weekday] += 1
            }
        }
        return dayCounts.enumerated().map { (day: $0.offset, count: $0.element) }
    }
}

// MARK: - Completion Consistency Chart
struct ConsistencyChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        let data = calculateConsistency()
        Chart(data, id: \ .date) { item in
            LineMark(
                x: .value("Date", item.date),
                y: .value("Consistency", item.rate)
            )
        }
        .frame(height: 180)
        .padding()
    }

    private func calculateConsistency() -> [(date: Date, rate: Double)] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        var result: [(Date, Double)] = []
        let totalDays = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0

        if totalDays > 365 { // Aggregate by month for large intervals
            var date = calendar.date(from: calendar.dateComponents([.year, .month], from: interval.start))!
            let endMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: interval.end))!
            while date <= endMonth {
                // Get all completions in this month
                let monthInterval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 0)
                let completions = habits.reduce(0) { sum, habit in
                    sum + habit.entries.filter { monthInterval.contains($0.timestamp) }.count
                }
                let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
                let rate = habits.isEmpty ? 0 : Double(completions) / Double(daysInMonth * habits.count)
                result.append((date, rate))
                date = calendar.date(byAdding: .month, value: 1, to: date)!
            }
        } else {
            var date = interval.start
            while date <= interval.end {
                let completions = habits.reduce(0) { $0 + HabitEntity.getCompletionsForDay(habit: $1, date: date) }
                let rate = habits.isEmpty ? 0 : Double(completions) / Double(habits.count)
                result.append((date, rate))
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        return result
    }
}

// MARK: - Longest Streaks
struct LongestStreaksView: View {
    let habits: [HabitEntity]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Longest Streaks")
                .font(.headline)
                .foregroundColor(Color.theme.onBackground)
            ForEach(habits) { habit in
                HStack {
                    Text(habit.title)
                        .foregroundColor(Color.theme.onBackground)
                    Spacer()
                    Text("\(habit.calculateStreak()) days")
                        .foregroundColor(Color.theme.caption)
                }
            }
        }
        .padding()
        .background(Color.theme.surface)
        .cornerRadius(12)
    }
}

// MARK: - Time of Day Analysis
struct TimeOfDayChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        let data = calculateTimeOfDay()
        Chart(data, id: \ .hour) { item in
            BarMark(
                x: .value("Hour", item.hour),
                y: .value("Completions", item.count)
            )
        }
        .frame(height: 180)
        .padding()
    }

    private func calculateTimeOfDay() -> [(hour: Int, count: Int)] {
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        for habit in habits {
            for entry in habit.entries where interval.contains(entry.timestamp) {
                let hour = calendar.component(.hour, from: entry.timestamp)
                hourCounts[hour, default: 0] += 1
            }
        }
        return (0...23).map { hour in (hour: hour, count: hourCounts[hour] ?? 0) }
    }
}

// MARK: - Goal Achievement Rate
struct GoalAchievementRateView: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame

    var body: some View {
        let rate = calculateGoalAchievementRate()
        VStack(alignment: .leading) {
            Text("Goal Achievement Rate")
                .font(.headline)
                .foregroundColor(Color.theme.onBackground)
            Text(String(format: "%.1f%%", rate * 100))
                .font(.largeTitle)
                .foregroundColor(Color.theme.primary)
        }
        .padding()
        .background(Color.theme.surface)
        .cornerRadius(12)
    }

    private func calculateGoalAchievementRate() -> Double {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        var totalIntervals = 0
        var achieved = 0
        for habit in habits {
            var date = interval.start
            while date <= interval.end {
                totalIntervals += 1
                if habit.isIntervalComplete(for: date) {
                    achieved += 1
                }
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        return totalIntervals > 0 ? Double(achieved) / Double(totalIntervals) : 0
    }
}

// MARK: - Habit Growth
struct HabitGrowthChart: View {
    let habits: [HabitEntity]

    var body: some View {
        let data = calculateHabitGrowth()
        Chart(data, id: \ .month) { item in
            BarMark(
                x: .value("Month", item.month),
                y: .value("Habits Started", item.count)
            )
        }
        .frame(height: 180)
        .padding()
    }

    private func calculateHabitGrowth() -> [(month: String, count: Int)] {
        var monthCounts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        for habit in habits {
            let month = formatter.string(from: habit.createdAt)
            monthCounts[month, default: 0] += 1
        }
        return monthCounts.sorted { $0.key < $1.key }.map { (month: $0.key, count: $0.value) }
    }
}
