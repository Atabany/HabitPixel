//
//  ActivityGridView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 13/05/2025.
//

import SwiftUI

struct ActivityGridView: View {
    let habit: HabitDisplayInfo
    let colors: ColorScheme
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let isSmallWidget: Bool
    
    let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }()
    
    private var columnCount: Int {
        isSmallWidget ? 11 : 20
    }
    
    private var layout: (cellSize: CGFloat, spacing: CGFloat) {
        let columns: CGFloat = CGFloat(columnCount)
        let rows: CGFloat = 7
        
        let availableWidth = containerWidth
        let availableHeight = containerHeight
        
        let maxCellWidth = availableWidth / columns
        let maxCellHeight = availableHeight / rows
        
        let cellSize = min(maxCellWidth, maxCellHeight) * (isSmallWidget ? 0.9 : 0.85)
        let spacing = cellSize * (isSmallWidget ? 0.15 : 0.2)
        
        return (cellSize: cellSize, spacing: spacing)
    }
    
    var body: some View {
        HStack(spacing: layout.spacing) {
            ForEach(0..<columnCount) { columnIndex in
                VStack(spacing: layout.spacing) {
                    ForEach(0..<7) { dayIndex in
                        let weekOffset = (columnCount - 1) - columnIndex
                        let date = getDate(weekOffset: weekOffset, weekday: dayIndex)
                        let isCompleted = habit.completedDates.contains(date)
                        
                        RoundedRectangle(cornerRadius: layout.cellSize * 0.25)
                            .fill(habit.color)
                            .frame(width: layout.cellSize, height: layout.cellSize)
                            .opacity(getOpacity(for: date, isCompleted: isCompleted))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getDate(weekOffset: Int, weekday: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        let thisWeekMonday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let targetDate = calendar.date(byAdding: .day, value: -(weekOffset * 7) + weekday, to: thisWeekMonday)!
        return calendar.startOfDay(for: targetDate)
    }
    
    private func getOpacity(for date: Date, isCompleted: Bool) -> Double {
        if isCompleted {
            return 1.0
        }
        
        let startOfDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        
        let firstCompletionDate = habit.completedDates.min()
        let lastCompletionDate = habit.completedDates.max()
        
        if let firstDate = firstCompletionDate,
           let lastDate = lastCompletionDate,
           startOfDay >= firstDate,
           startOfDay <= lastDate {
            return 0.4
        }
        
        return 0.15
    }
}
