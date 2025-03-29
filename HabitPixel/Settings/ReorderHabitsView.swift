import SwiftUI
import SwiftData

struct ReorderHabitsView: View {
    @Query(sort: \HabitEntity.createdAt) private var habits: [HabitEntity]
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
                    
                    // Update all habits with new timestamps for ordering
                    let now = Date()
                    for (index, habit) in updatedHabits.enumerated() {
                        // Using minutes as offset to ensure proper ordering
                        habit.createdAt = now.addingTimeInterval(TimeInterval(index * 60))
                    }
                    
                    try? modelContext.save()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Reorder Habits")
        .environment(\.editMode, .constant(.active))
    }
}
