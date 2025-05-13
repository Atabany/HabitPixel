import SwiftUI
import SwiftData
import WidgetKit

struct ReorderHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<HabitEntity> { habit in
        habit.isArchived == false
    }, sort: \HabitEntity.title) private var habits: [HabitEntity]
    @State private var reorderableHabits: [HabitEntity]
    
    init(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<HabitEntity>(
            predicate: #Predicate<HabitEntity> { habit in
                habit.isArchived == false
            },
            sortBy: [SortDescriptor(\HabitEntity.title)]
        )
        
        _reorderableHabits = State(initialValue: (try? modelContext.fetch(descriptor)) ?? [])
    }
    
    var body: some View {
        List {
            if reorderableHabits.isEmpty {
                ContentUnavailableView("No habits found",
                    systemImage: "list.bullet",
                    description: Text("You need to create at least one habit to do something here")
                )
            } else {
                ForEach(reorderableHabits, id: \.self) { habit in
                    HStack {
                        Image(systemName: habit.iconName)
                            .foregroundStyle(habit.color)
                            .font(.title3)
                        Text(habit.title)
                    }
                }
                .onMove { indexSet, destination in
                    reorderableHabits.move(fromOffsets: indexSet, toOffset: destination)
                    
                    // Update order
                    Task {
                        // Make sure to pass the updated order to the widget
                        await WidgetManager.shared.syncWidgets(reorderableHabits)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Reorder Habits")
        .environment(\.editMode, .constant(.active))
    }
}
