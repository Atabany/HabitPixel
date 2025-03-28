import SwiftUI
import SwiftData

struct HabitActivityGrid: View {
    let habit: HabitEntity
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: HabitActivityGridViewModel
    
    init(habit: HabitEntity) {
        self.habit = habit
        _viewModel = StateObject(wrappedValue: HabitActivityGridViewModel(habit: habit))
    }
    
    var body: some View {
        Group {
            if let data = viewModel.gridData {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: viewModel.spacing) {
                            ForEach(0..<data.numberOfWeeks, id: \.self) { weekIndex in
                                WeekView(
                                    weekIndex: weekIndex,
                                    data: data,
                                    viewModel: viewModel
                                )
                                .id(weekIndex)
                            }
                        }
                        .padding(.vertical, 8)
                        .onAppear {
                            viewModel.scrollToCurrentWeek(proxy, startDate: data.startDate)
                        }
                    }
                }
                .frame(height: viewModel.gridHeight)
            } else {
                ProgressView()
                    .task {
                        await viewModel.loadInitialData()
                    }
            }
        }
        .onChange(of: habit.entries) { _, _ in
            Task {
                await viewModel.updateGridData()
            }
        }
    }
}

// Week column view
private struct WeekView: View {
    let weekIndex: Int
    let data: GridData
    let viewModel: HabitActivityGridViewModel
    
    var body: some View {
        VStack(spacing: viewModel.spacing) {
            ForEach(0..<viewModel.daysInWeek, id: \.self) { dayIndex in
                DayCell(
                    date: viewModel.getDate(weekIndex: weekIndex, dayIndex: dayIndex, startDate: data.startDate),
                    data: data,
                    viewModel: viewModel
                )
            }
        }
    }
}

// Individual day cell
private struct DayCell: View {
    let date: Date
    let data: GridData
    let viewModel: HabitActivityGridViewModel
    
    var body: some View {
        let startOfDay = viewModel.calendar.startOfDay(for: date)
        let isCompleted = data.completedDates.contains(startOfDay)
        
        RoundedRectangle(cornerRadius: 2)
            .fill(viewModel.habit.color.opacity(viewModel.getCellOpacity(for: date, isCompleted: isCompleted)))
            .frame(width: viewModel.cellSize, height: viewModel.cellSize)
            .overlay(viewModel.isUpdating ? Color.clear : nil)
    }
}

