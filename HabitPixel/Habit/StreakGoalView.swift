//
//  StreakGoalView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct StreakGoalView: View {
    @Binding var selectedInterval: Interval
    @Binding var completionsPerInterval: Int
    let themeColors = AppColors.currentColorScheme
    
    private let intervals = [
        (interval: Interval.none, description: "No specific goal"),
        (interval: Interval.daily, description: "Daily goal"),
        (interval: Interval.weekly, description: "Weekly goal"),
        (interval: Interval.monthly, description: "Monthly goal")
    ]
    
    private let minCompletionsPerInterval = 1
    private let maxCompletionsPerInterval = 100

    var body: some View {
        Form {
            Section(header: Text("Goal Interval").foregroundColor(themeColors.onBackground)) {
                ForEach(intervals, id: \.interval) { item in
                    Button(action: {
                        selectedInterval = item.interval
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.interval.rawValue.capitalized)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.caption)
                                    .foregroundColor(themeColors.caption)
                            }
                            
                            Spacer()
                            
                            if selectedInterval == item.interval {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeColors.primary)
                            }
                        }
                    }
                    .foregroundColor(themeColors.onBackground)
                }
            }
            
            if selectedInterval != .none {
                Section(header: Text("Completions Goal").foregroundColor(themeColors.onBackground)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How many times do you want to complete this habit per \(selectedInterval.rawValue)?")
                            .font(.subheadline)
                            .foregroundColor(themeColors.caption)
                        
                        CompletionsControl(value: $completionsPerInterval,
                                         min: minCompletionsPerInterval,
                                         max: maxCompletionsPerInterval,
                                         themeColors: themeColors)
                            .padding(.vertical, 8)
                        
                        Text(getGoalDescription())
                            .font(.subheadline)
                            .foregroundColor(themeColors.caption)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .background(themeColors.background)
        .navigationTitle("Streak Goal")
    }
    
    private func getGoalDescription() -> String {
        switch selectedInterval {
        case .daily:
            return "Complete this habit \(completionsPerInterval) time\(completionsPerInterval > 1 ? "s" : "") each day"
        case .weekly:
            return "Complete this habit \(completionsPerInterval) time\(completionsPerInterval > 1 ? "s" : "") each week"
        case .monthly:
            return "Complete this habit \(completionsPerInterval) time\(completionsPerInterval > 1 ? "s" : "") each month"
        case .none:
            return ""
        }
    }
}

struct CompletionsControl: View {
    @Binding var value: Int
    let min: Int
    let max: Int
    let themeColors: ColorScheme
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: decrement) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(value > min ? themeColors.primary : themeColors.caption)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value <= min)
            
            Text("\(value)")
                .font(.system(size: 32, weight: .medium))
                .frame(minWidth: 60)
                .foregroundColor(themeColors.onBackground)
            
            Button(action: increment) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(value < max ? themeColors.primary : themeColors.caption)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value >= max)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func increment() {
        if value < max {
            value += 1
        }
    }
    
    private func decrement() {
        if value > min {
            value -= 1
        }
    }
}
