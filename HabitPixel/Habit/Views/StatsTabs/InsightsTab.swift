import SwiftUI

struct InsightsTab: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    @State private var selectedInsight: InsightType = .patterns
    let themeColors = AppColors.currentColorScheme
    
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

struct InsightTypeButton: View {
    let type: InsightsTab.InsightType
    let isSelected: Bool
    let action: () -> Void
    let themeColors = AppColors.currentColorScheme
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? themeColors.primary : Color.clear)
                .foregroundColor(isSelected ? themeColors.onPrimary : themeColors.onBackground)
                .clipShape(Capsule())
        }
    }
}

struct HabitPatterns: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    
    var body: some View {
        // Implementation for habit patterns
        Text("Habit Patterns")
    }
}

struct HabitProgress: View {
    let habits: [HabitEntity]
    let timeFrame: GlobalStatsView.TimeFrame
    
    var body: some View {
        // Implementation for habit progress
        Text("Habit Progress")
    }
}

struct HabitSuggestions: View {
    let habits: [HabitEntity]
    
    var body: some View {
        // Implementation for habit suggestions
        Text("Habit Suggestions")
    }
}