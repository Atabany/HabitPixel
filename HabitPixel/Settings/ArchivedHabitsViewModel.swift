import SwiftUI
import SwiftData

class ArchivedHabitsViewModel: ObservableObject {
    @Published var archivedHabits: [HabitEntity] = []
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadArchivedHabits()
    }
    
    func loadArchivedHabits() {
        let descriptor = FetchDescriptor<HabitEntity>(
            predicate: #Predicate<HabitEntity> { habit in
                habit.isArchived == true
            },
            sortBy: [SortDescriptor(\.archivedDate, order: .reverse)]
        )
        
        do {
            archivedHabits = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch archived habits: \(error)")
        }
    }
    
    func unarchiveHabit(_ habit: HabitEntity) {
        habit.isArchived = false
        habit.archivedDate = nil
        
        do {
            try modelContext.save()
            loadArchivedHabits() // Refresh the list
        } catch {
            print("Failed to unarchive habit: \(error)")
        }
    }
    
    func deleteHabit(_ habit: HabitEntity) {
        modelContext.delete(habit)
        
        do {
            try modelContext.save()
            loadArchivedHabits() // Refresh the list
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }
}
