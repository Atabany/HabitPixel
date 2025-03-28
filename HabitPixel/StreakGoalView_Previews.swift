//
//  StreakGoalView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct StreakGoalView_Previews: PreviewProvider {
    static var previews: some View {
        StreakGoalView(selectedInterval: .constant(.weekly), completionsPerInterval: .constant(3))
            .preferredColorScheme(.light)
        StreakGoalView(selectedInterval: .constant(.weekly), completionsPerInterval: .constant(3))
            .preferredColorScheme(.dark)
    }
}

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderView(selectedDays: .constant([.mon, .wed]))
            .preferredColorScheme(.light)
        ReminderView(selectedDays: .constant([.mon, .wed]))
            .preferredColorScheme(.dark)
    }
}

struct NewHabitView_Previews: PreviewProvider {
    static var previews: some View {
        NewHabitView()
            .preferredColorScheme(.light)
        NewHabitView()
            .preferredColorScheme(.dark)
    }
}

struct HabitKitView_Previews: PreviewProvider {
    static var previews: some View {
        HabitKitView()
            .preferredColorScheme(.light)
        HabitKitView()
            .preferredColorScheme(.dark)
    }
}
