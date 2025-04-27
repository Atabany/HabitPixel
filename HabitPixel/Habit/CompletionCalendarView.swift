import SwiftUI
import SwiftData

struct CompletionCalendarView: View {
    @Environment(\.dismiss) var dismiss
    let habit: HabitEntity
    
    @State private var selectedDate = Date()
    @State private var completedDates: Set<Date>
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allHabits: [HabitEntity]
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let weekRows = 6
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    init(habit: HabitEntity) {
        self.habit = habit
        let dates = habit.entries.map { Calendar.current.startOfDay(for: $0.timestamp) }
        _completedDates = State(initialValue: Set(dates))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Month navigation
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                
                Spacer()
                
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 4)
            
            // Calendar grid
            VStack(spacing: 12) {
                // Weekday headers
                HStack(spacing: 0) {
                    Text("WK")
                        .frame(width: 40, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Calendar days
                ForEach(0..<weekRows, id: \.self) { row in
                    HStack(spacing: 0) {
                        Text(getWeekNumber(forRow: row))
                            .frame(width: 40, alignment: .leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(0..<daysInWeek, id: \.self) { column in
                            if let date = getDate(forRow: row, column: column) {
                                let startOfDay = calendar.startOfDay(for: date)
                                CalendarDayButton(
                                    date: date,
                                    isToday: calendar.isDateInToday(date),
                                    isCompleted: completedDates.contains(startOfDay),
                                    color: habit.color,
                                    isCurrentMonth: calendar.component(.month, from: date) == calendar.component(.month, from: selectedDate),
                                    onTap: { toggleCompletion(for: date) }
                                )
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
            
            Text("Tap dates to add or remove completions")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.height(480)])
        .presentationDragIndicator(.visible)
    }
    
    private func toggleCompletion(for date: Date) {
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        guard targetDate <= today else { return }
        
        withAnimation(.easeInOut(duration: 0.05)) {
            HabitEntity.toggleCompletion(habit: habit, date: date, context: modelContext, allHabits: allHabits)
            
            // Update completedDates Set to reflect the new state
            if completedDates.contains(targetDate) {
                completedDates.remove(targetDate)
            } else {
                completedDates.insert(targetDate)
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func moveMonth(_ months: Int) {
        if let newDate = calendar.date(byAdding: .month, value: months, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func getWeekNumber(forRow row: Int) -> String {
        if let date = getDate(forRow: row, column: 0) {
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            
            let isFirstRow = row == 0
            let isLastRow = row == weekRows - 1
            let isCurrentMonth = calendar.component(.month, from: date) == calendar.component(.month, from: selectedDate)
            
            if isFirstRow || isLastRow || isCurrentMonth {
                return "\(weekOfYear)"
            }
        }
        return ""
    }
    
    private func getDate(forRow row: Int, column: Int) -> Date? {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return nil
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = (firstWeekday - 2 + daysInWeek) % daysInWeek
        
        let day = row * daysInWeek + column - offsetDays + 1
        var dateComponents = DateComponents(
            year: calendar.component(.year, from: selectedDate),
            month: calendar.component(.month, from: selectedDate),
            day: day
        )
        
        if day < 1 {
            if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth) {
                let previousMonthDays = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 30
                dateComponents.month = calendar.component(.month, from: previousMonth)
                dateComponents.year = calendar.component(.year, from: previousMonth)
                dateComponents.day = previousMonthDays + day
            }
        } else if let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth),
                day > calendar.component(.day, from: lastDayOfMonth) {
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) {
                dateComponents.month = calendar.component(.month, from: nextMonth)
                dateComponents.year = calendar.component(.year, from: nextMonth)
                dateComponents.day = day - calendar.component(.day, from: lastDayOfMonth)
            }
        }
        
        guard let date = calendar.date(from: dateComponents) else {
            return nil
        }
        
        return date
    }
}

struct CalendarDayButton: View {
    let date: Date
    let isToday: Bool
    let isCompleted: Bool
    let color: Color
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    private let size: CGFloat = 36
    
    private var isFutureDate: Bool {
        let today = calendar.startOfDay(for: Date())
        return date > today
    }
    
    var body: some View {
        Button(action: onTap) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 15))
                .fontWeight(isToday ? .medium : .regular)
                .frame(maxWidth: .infinity)
                .frame(height: size)
                .foregroundColor(foregroundColor)
                .background(
                    Circle()
                        .fill(isCompleted ? color : Color.clear)
                        .overlay(
                            Circle()
                                .strokeBorder(isToday && !isCompleted ? color : Color.clear, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFutureDate)
    }
    
    private var foregroundColor: Color {
        if isFutureDate {
            return Color.gray.opacity(0.3)
        } else if isCompleted {
            return .white
        } else if !isCurrentMonth {
            return Color.secondary.opacity(0.3)
        }
        return .primary
    }
}
