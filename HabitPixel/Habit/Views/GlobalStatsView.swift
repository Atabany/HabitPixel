import SwiftUI
import SwiftData
import Charts

struct GlobalStatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<HabitEntity> { habit in
        habit.isArchived == false
    }) private var habits: [HabitEntity]
    
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var selectedTab: StatTab = .overview
    @State private var selectedHabit: HabitEntity?
    @State private var animateCharts = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    enum StatTab: String, CaseIterable {
        case overview = "Overview"
        case habits = "Habits"
        case insights = "Insights"
    }
    
    var body: some View {
        NavigationStack {
            StatsContent(
                habits: habits,
                selectedTimeFrame: $selectedTimeFrame,
                selectedTab: $selectedTab,
                selectedHabit: $selectedHabit,
                animateCharts: $animateCharts
            )
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.theme.onBackground)
                    }
                }
            }
            .sheet(item: $selectedHabit) { habit in
                NavigationStack {
                    HabitDetailView(habit: habit)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct StatsContent: View {
    let habits: [HabitEntity]
    @Binding var selectedTimeFrame: GlobalStatsView.TimeFrame
    @Binding var selectedTab: GlobalStatsView.StatTab
    @Binding var selectedHabit: HabitEntity?
    @Binding var animateCharts: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TabBarView(selectedTab: $selectedTab)
            
            if selectedTab != .habits {
                TimeFrameSelector(
                    selectedTimeFrame: $selectedTimeFrame,
                    animateCharts: $animateCharts,
                    selectedTab: $selectedTab
                )
            }
            
            TabContent(
                tab: selectedTab,
                habits: habits,
                timeFrame: selectedTimeFrame,
                selectedHabit: $selectedHabit,
                animate: animateCharts
            )
        }
    }
}

private struct TabBarView: View {
    @Binding var selectedTab: GlobalStatsView.StatTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(GlobalStatsView.StatTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.rawValue,
                        isSelected: selectedTab == tab,
                        action: { withAnimation { selectedTab = tab } }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.theme.surface)
    }
}

private struct TimeFrameSelector: View {
    @Binding var selectedTimeFrame: GlobalStatsView.TimeFrame
    @Binding var animateCharts: Bool
    @Binding var selectedTab: GlobalStatsView.StatTab
    
    var body: some View {
        let availableTimeFrames: [GlobalStatsView.TimeFrame] =
            selectedTab == .insights ? GlobalStatsView.TimeFrame.allCases.filter { $0 != .all } : GlobalStatsView.TimeFrame.allCases
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableTimeFrames, id: \.self) { timeFrame in
                    TimeFrameButton(
                        title: timeFrame.rawValue,
                        isSelected: selectedTimeFrame == timeFrame,
                        action: {
                            withAnimation {
                                selectedTimeFrame = timeFrame
                                animateCharts = false
                                Task {
                                    try? await Task.sleep(nanoseconds: 100_000_000)
                                    animateCharts = true
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

private struct TabContent: View {
    let tab: GlobalStatsView.StatTab
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    @Binding var selectedHabit: HabitEntity?
    let animate: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch tab {
                case .overview:
                    OverviewTab(
                        habits: habits,
                        timeFrame: timeFrame,
                        animate: animate
                    )
                case .habits:
                    HabitsTab(
                        habits: habits,
                        selectedHabit: $selectedHabit
                    )
                case .insights:
                    InsightsTab(
                        habits: habits,
                        timeFrame: timeFrame
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : Color.theme.onBackground)
                .background(isSelected ? Color.theme.primary : .clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .inset(by: 0.5)
                        .stroke(isSelected ? .clear : Color.theme.onBackground.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct TimeFrameButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? Color.theme.primary : Color.theme.onBackground)
                .background(isSelected ? Color.theme.primary.opacity(0.1) : .clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .inset(by: 0.5)
                        .stroke(isSelected ? Color.theme.primary : Color.theme.onBackground.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct HabitPerformanceRow: View {
    let habit: HabitEntity
    
    var body: some View {
        HStack {
            Image(systemName: habit.iconName)
                .foregroundColor(habit.color)
                .frame(width: 30)
            
            Text(habit.title)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(habit.entries.count)")
                .foregroundColor(Color.theme.caption)
        }
        .padding()
        .background(Color.theme.surface)
        .cornerRadius(10)
    }
}

struct TimeActivityChart: View {
    let distribution: [Date: Int]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let points = hourlyPoints()
                let maxValue = points.map { $0.1 }.max() ?? 1
                let width = geometry.size.width
                let height = geometry.size.height
                
                let step = width / CGFloat(23)
                
                for (index, point) in points.enumerated() {
                    let x = CGFloat(index) * step
                    let y = height - (CGFloat(point.1) / CGFloat(maxValue) * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 2
            )
        }
    }
    
    private func hourlyPoints() -> [(Int, Int)] {
        var points: [(Int, Int)] = []
        let calendar = Calendar.current
        
        for hour in 0...23 {
            let count = distribution.filter {
                calendar.component(.hour, from: $0.key) == hour
            }.values.reduce(0, +)
            
            points.append((hour, count))
        }
        
        return points
    }
}

struct CompletionTrendChart: View {
    let completions: [Date: Int]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let points = monthlyPoints()
                let maxValue = points.map { $0.1 }.max() ?? 1
                let width = geometry.size.width
                let height = geometry.size.height
                
                let step = width / CGFloat(points.count - 1)
                
                for (index, point) in points.enumerated() {
                    let x = CGFloat(index) * step
                    let y = height - (CGFloat(point.1) / CGFloat(maxValue) * height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
        }
    }
    
    private func monthlyPoints() -> [(Int, Int)] {
        var points: [(Int, Int)] = []
        let calendar = Calendar.current
        let sortedDates = completions.keys.sorted()
        
        for (index, date) in sortedDates.enumerated() {
            points.append((index, completions[date] ?? 0))
        }
        
        return points
    }
}
