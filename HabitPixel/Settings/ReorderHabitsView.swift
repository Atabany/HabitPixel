import SwiftUI
import SwiftData
import WidgetKit

struct ReorderHabitsView: View {
    @Query(
        filter: #Predicate<HabitEntity> { habit in
            habit.isArchived == false
        },
        sort: \HabitEntity.createdAt
    ) private var habits: [HabitEntity]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            if habits.isEmpty {
                ContentUnavailableView("No habits found",
                    systemImage: "list.bullet",
                    description: Text("You need to create at least one habit to do something here")
                )
            } else {
                ForEach(habits) { habit in
                    HStack {
                        Image(systemName: habit.iconName)
                            .foregroundColor(habit.color)
                        Text(habit.title)
                    }
                }
                .onMove { from, to in
                    var updatedHabits = habits
                    updatedHabits.move(fromOffsets: from, toOffset: to)
                    
                    let now = Date()
                    for (index, habit) in updatedHabits.enumerated() {
                        habit.createdAt = now.addingTimeInterval(TimeInterval(index * 60))
                    }
                    
                    do {
                        try modelContext.save()
                        Task {
                            await HabitEntity.updateWidgetHabits(updatedHabits)
                        }
                    } catch {
                        print("Failed to save reordered habits: \(error)")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Reorder Habits")
        .environment(\.editMode, .constant(.active))
    }
}
