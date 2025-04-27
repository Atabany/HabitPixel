import SwiftUI
import SwiftData
import WidgetKit

struct HabitActivityGrid: View {
    let habit: HabitEntity
    @Environment(\.modelContext) private var modelContext
    @Query private var allHabits: [HabitEntity]
    @StateObject private var viewModel: HabitActivityGridViewModel
    
    init(habit: HabitEntity) {
        self.habit = habit
        _allHabits = Query()
        _viewModel = StateObject(wrappedValue: HabitActivityGridViewModel(habit: habit, allHabits: []))
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
        .onChange(of: allHabits) { _, newValue in
            viewModel.allHabits = newValue
            Task {
                await viewModel.updateGridData()
            }
        }
        .onAppear {
            if !allHabits.isEmpty {
                viewModel.allHabits = allHabits
                HabitEntity.updateWidgetHabits(allHabits)
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
            ForEach(0..<7, id: \.self) { dayIndex in
                let date = viewModel.getDate(weekIndex: weekIndex, dayIndex: dayIndex, startDate: data.startDate)
                DayCell(
                    date: date,
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
            .contentShape(Rectangle())
    }
}
