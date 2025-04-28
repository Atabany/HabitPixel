import SwiftUI
import Charts

extension Calendar {
    func numberOfDays(in timeFrame: GlobalStatsView.TimeFrame, from date: Date = Date()) -> Int {
        let startDate: Date
        
        switch timeFrame {
        case .week:
            startDate = self.date(byAdding: .day, value: -7, to: date) ?? date
        case .month:
            startDate = self.date(byAdding: .month, value: -1, to: date) ?? date
        case .year:
            startDate = self.date(byAdding: .year, value: -1, to: date) ?? date
        case .all:
            return 365
        }
        
        let components = self.dateComponents([.day], from: startDate, to: date)
        return components.day ?? 0
    }
    
    func dateInterval(for timeFrame: GlobalStatsView.TimeFrame, from date: Date = Date()) -> DateInterval {
        let startDate: Date
        
        switch timeFrame {
        case .week:
            startDate = self.date(byAdding: .day, value: -7, to: date) ?? date
        case .month:
            startDate = self.date(byAdding: .month, value: -1, to: date) ?? date
        case .year:
            startDate = self.date(byAdding: .year, value: -1, to: date) ?? date
        case .all:
            // For "all time", use the earliest entry date or app install date
            startDate = Date.distantPast
        }
        
        return DateInterval(start: startOfDay(for: startDate), end: endOfDay(for: date))
    }
    
    func endOfDay(for date: Date) -> Date {
        let components = DateComponents(hour: 23, minute: 59, second: 59)
        return self.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }
}

struct QuickStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct ActivityHeatMap: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    
    var body: some View {
        // Implementation for activity heat map
        Text("Activity Heat Map")
    }
}

struct TimeDistributionChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    let animate: Bool
    
    var body: some View {
        // Implementation for time distribution chart
        Text("Time Distribution Chart")
    }
}

struct OverviewTab: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    let animate: Bool
    let themeColors = AppColors.currentColorScheme
    @State private var selectedHabitId: String?
    
    var selectedHabit: HabitEntity? {
        guard let id = selectedHabitId else { return nil }
        return habits.first { "\($0.persistentModelID)" == id }
    }
    
    var displayHabits: [HabitEntity] {
        if let habit = selectedHabit {
            return [habit]
        }
        return habits
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Habit selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HabitSelectorButton(
                        title: "All Habits",
                        icon: "square.grid.2x2",
                        color: themeColors.primary,
                        isSelected: selectedHabitId == nil,
                        action: { selectedHabitId = nil }
                    )
                    
                    ForEach(habits) { habit in
                        HabitSelectorButton(
                            title: habit.title,
                            icon: habit.iconName,
                            color: habit.color,
                            isSelected: selectedHabitId == "\(habit.persistentModelID)",
                            action: { selectedHabitId = "\(habit.persistentModelID)" }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Quick stats
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                QuickStatView(
                    title: "Total Completions",
                    value: getTotalCompletions(),
                    icon: "checkmark.circle.fill",
                    color: selectedHabit?.color ?? themeColors.primary
                )
                
                QuickStatView(
                    title: "Current Streak",
                    value: getLongestStreak(),
                    icon: "flame.fill",
                    color: .orange
                )
                
                QuickStatView(
                    title: "Success Rate",
                    value: String(format: "%.0f%%", getCompletionRate()),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                if selectedHabit == nil {
                    QuickStatView(
                        title: "Active Habits",
                        value: "\(habits.count)",
                        icon: "list.bullet.rectangle.fill",
                        color: .blue
                    )
                } else {
                    QuickStatView(
                        title: "Goal Progress",
                        value: getGoalProgress(),
                        icon: "target",
                        color: selectedHabit?.color ?? .blue
                    )
                }
            }
            .padding(.horizontal)
            
            // Daily activity chart
            StatCard(title: "Daily Activity", icon: "clock") {
                DailyActivityChart(
                    habits: displayHabits,
                    timeFrame: timeFrame,
                    color: selectedHabit?.color ?? themeColors.primary
                )
                .frame(height: 200)
            }
            .padding(.horizontal)
            
            if selectedHabit == nil {
                // Category distribution (only show for all habits)
                StatCard(title: "Category Distribution", icon: "folder.fill") {
                    CategoryDistributionChart(habits: habits, timeFrame: timeFrame)
                        .frame(height: 200)
                }
                .padding(.horizontal)
            } else {
                // Completion heatmap (only show for individual habits)
                StatCard(title: "Completion Pattern", icon: "calendar") {
                    CompletionHeatMap(habit: selectedHabit!, timeFrame: timeFrame)
                        .frame(height: 200)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getTotalCompletions() -> String {
        let interval = Calendar.current.dateInterval(for: timeFrame)
        let completions = displayHabits.reduce(0) { sum, habit in
            sum + habit.entries.filter { interval.contains($0.timestamp) }.count
        }
        return completions >= 1000 ? String(format: "%.1fK", Double(completions) / 1000.0) : "\(completions)"
    }
    
    private func getLongestStreak() -> String {
        let interval = Calendar.current.dateInterval(for: timeFrame)
        let streaks = displayHabits.map { habit in
            habit.calculateStreak(within: interval)
        }
        return "\(streaks.max() ?? 0)"
    }
    
    private func getCompletionRate() -> Double {
        let interval = Calendar.current.dateInterval(for: timeFrame)
        let totalPossible = displayHabits.count * Calendar.current.numberOfDays(in: timeFrame)
        let completed = displayHabits.reduce(0) { sum, habit in
            sum + habit.entries.filter { interval.contains($0.timestamp) }.count
        }
        return totalPossible > 0 ? Double(completed) / Double(totalPossible) * 100 : 0
    }
    
    private func getGoalProgress() -> String {
        guard let habit = selectedHabit else { return "0%" }
        let current = habit.getCompletionsInCurrentInterval()
        return "\(current)/\(habit.goal)"
    }
}

struct HabitSelectorButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? color : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .inset(by: 0.5)
                    .stroke(color.opacity(isSelected ? 0.3 : 0.2), lineWidth: 1)
            )
        }
    }
}

struct StatCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct CompletionHeatMap: View {
    let habit: HabitEntity
    let timeFrame: GlobalStatsView.TimeFrame
    
    var body: some View {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        let completedDates = Set(
            habit.entries
                .filter { interval.contains($0.timestamp) }
                .map { calendar.startOfDay(for: $0.timestamp) }
        )
        
        // Implementation similar to your existing activity grid
        HabitActivityGrid(habit: habit)
    }
}

struct DailyActivityChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    let color: Color
    let themeColors = AppColors.currentColorScheme
    
    var body: some View {
        let data = calculateDailyActivity()
        Chart(data, id: \.hour) { item in
            BarMark(
                x: .value("Hour", item.hour),
                y: .value("Completions", item.count)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                if let hour = value.as(Int.self) {
                    AxisValueLabel {
                        Text(formatHour(hour))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    private func calculateDailyActivity() -> [(hour: Int, count: Int)] {
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        
        for habit in habits {
            for entry in habit.entries {
                guard interval.contains(entry.timestamp) else { continue }
                let hour = calendar.component(.hour, from: entry.timestamp)
                hourCounts[hour, default: 0] += 1
            }
        }
        
        return (0...23).map { hour in
            (hour: hour, count: hourCounts[hour] ?? 0)
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date).lowercased()
    }
}

struct CategoryDistributionChart: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    let themeColors = AppColors.currentColorScheme
    
    var body: some View {
        let data = calculateCategoryDistribution()
        Chart(data, id: \.category) { item in
            SectorMark(
                angle: .value("Count", item.count),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(by: .value("Category", item.category))
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 20)
    }
    
    private func calculateCategoryDistribution() -> [(category: String, count: Int)] {
        var categoryCounts: [String: Int] = [:]
        let calendar = Calendar.current
        let interval = calendar.dateInterval(for: timeFrame)
        
        for habit in habits {
            let filteredEntries = habit.entries.filter { interval.contains($0.timestamp) }
            categoryCounts[habit.category, default: 0] += filteredEntries.count
        }
        
        return categoryCounts
            .map { (category: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}
