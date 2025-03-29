import SwiftUI

class ArchivedHabitsViewModel: ObservableObject {
    @Published var archivedHabits: [HabitEntity] = []
    
    init() {
        loadArchivedHabits()
    }
    
    func loadArchivedHabits() {
        // TODO: Load archived habits from persistent storage
        // This will be implemented when we add CoreData/UserDefaults
    }
    
    func unarchiveHabit(_ habit: HabitEntity) {
        // TODO: Implement unarchive logic
        if let index = archivedHabits.firstIndex(where: { $0.id == habit.id }) {
            habit.isArchived = false
            habit.archivedDate = nil
            archivedHabits.remove(at: index)
            // Save changes to persistent storage
        }
    }
}