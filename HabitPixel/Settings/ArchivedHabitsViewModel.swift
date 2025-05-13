import SwiftUI
import SwiftData
import WidgetKit

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
            // Log or handle error fetching archived habits
            // Error: \(error)
        }
    }
    
    func unarchiveHabit(_ habit: HabitEntity) {
        habit.isArchived = false
        habit.archivedDate = nil
        
        do {
            try modelContext.save()
            loadArchivedHabits() // Refresh the list
            
            // Update widget after unarchiving
            let allHabitsDescriptor = FetchDescriptor<HabitEntity>()
            if let allHabits = try? modelContext.fetch(allHabitsDescriptor) {
                Task { @MainActor in
                    await HabitEntity.updateWidgetHabits(allHabits)
                }
            }
        } catch {
            // Log or handle error unarchiving habit
            // Error: \(error)
        }
    }
    
    func deleteHabit(_ habit: HabitEntity) {
        modelContext.delete(habit)
        
        do {
            try modelContext.save()
            loadArchivedHabits() // Refresh the list
            
            // Update widget after deletion
            let allHabitsDescriptor = FetchDescriptor<HabitEntity>()
            if let allHabits = try? modelContext.fetch(allHabitsDescriptor) {
                Task { @MainActor in
                    await HabitEntity.updateWidgetHabits(allHabits)
                }
            }
        } catch {
            // Log or handle error deleting archived habit
            // Error: \(error)
        }
    }
}
