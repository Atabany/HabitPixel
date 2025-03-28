import SwiftUI
import SwiftData

struct CompletionCalendarView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    let habit: HabitEntity
    
    @State private var selectedDate = Date()
    let calendar = Calendar.current
    private let daysInWeek = 7
    private let weekRows = 6
    
    var body: some View {
        let colors = AppColors.currentColorScheme
        
        ZStack {
            // Blur background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            // Calendar content
            VStack(spacing: 20) {
                // Month navigation
                HStack {
                    Button(action: { moveMonth(-1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: selectedDate))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: { moveMonth(1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                // Week day headers
                HStack {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(colors.caption)
                    }
                }
                
                // Calendar grid
                VStack(spacing: 8) {
                    ForEach(0..<weekRows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<daysInWeek, id: \.self) { column in
                                let date = getDate(forRow: row, column: column)
                                if let date = date {
                                    CalendarDayView(
                                        date: date,
                                        isCompleted: HabitEntity.isDateCompleted(habit: habit, date: date),
                                        color: habit.color,
                                        isToday: calendar.isDateInToday(date)
                                    )
                                    .onTapGesture {
                                        toggleCompletion(for: date)
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 40)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(colors.background)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(30)
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
    
    private func getDate(forRow row: Int, column: Int) -> Date? {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return nil
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = (firstWeekday - 2 + daysInWeek) % daysInWeek
        
        let day = row * daysInWeek + column - offsetDays + 1
        let dateComponents = DateComponents(year: calendar.component(.year, from: selectedDate),
                                          month: calendar.component(.month, from: selectedDate),
                                          day: day)
        
        guard let date = calendar.date(from: dateComponents),
              calendar.component(.month, from: date) == calendar.component(.month, from: selectedDate) else {
            return nil
        }
        
        return date
    }
    
    private func toggleCompletion(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        // Only prevent future dates
        guard targetDate <= today else { return }
        
        HabitEntity.toggleCompletion(habit: habit, date: date, context: modelContext)
    }
}

struct CalendarDayView: View {
    let date: Date
    let isCompleted: Bool
    let color: Color
    let isToday: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? color : color.opacity(0.1))
            
            if isToday {
                Circle()
                    .stroke(color, lineWidth: 2)
            }
            
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isCompleted ? .white : .primary)
        }
        .frame(width: 40, height: 40)
    }
}

// End of file
