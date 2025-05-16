//
//  HabitsHelper.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 13/05/2025.
//

import Foundation
import SwiftUI

struct HabitsHelper {
    static let defaults = UserDefaults(suiteName: "group.com.atabany.HabitRix")

    static func loadAllHabits() -> [HabitDisplayInfo]? {
        guard let data = defaults?.data(forKey: "WidgetHabits") else {
            print("No widget data found in UserDefaults")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            if habits.isEmpty {
                print("No habits found in widget data")
                return nil
            }
            return habits
        } catch {
            print("Error decoding widget data: \(error)")
            return nil
        }
    }
    
    static let noHabitDisplayInfo: HabitDisplayInfo = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return HabitDisplayInfo(
            id: "system_no_habit_placeholder",
            title: "No Habits Yet",
            iconName: "questionmark.diamond.fill",
            color: Color.gray,
            completedDates: Set(),
            startDate: today,
            endDate: today
        )
    }()
}
