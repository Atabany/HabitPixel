//
//  Interval.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

enum Interval: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { rawValue }
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }
    
    func getIntervalBounds(for date: Date) -> (start: Date, end: Date) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let startOfDay = calendar.startOfDay(for: date)
        
        switch self {
        case .daily:
            let end = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, end)
            
        case .weekly:
            // Get weekday number (1=Sunday, 2=Monday, ..., 7=Saturday)
            let weekday = calendar.component(.weekday, from: startOfDay)
            
            // Calculate days to subtract to get to Monday (weekday=2)
            let daysToSubtract = (weekday + 5) % 7 // This formula works for Monday start
            
            // Get start of week (Monday)
            let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay)!
            
            // Get end of week (next Monday)
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            
            return (weekStart, weekEnd)
            
        case .monthly:
            var components = calendar.dateComponents([.year, .month], from: startOfDay)
            let monthStart = calendar.date(from: components)!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return (monthStart, monthEnd)
        }
    }
}
