import Foundation
import SwiftData

@Model
final class EntryEntity {
    var timestamp: Date
    
    @Relationship var habit: HabitEntity?
    
    init(
        timestamp: Date = Date(),
        habit: HabitEntity? = nil
    ) {
        self.timestamp = timestamp
        self.habit = habit
    }
}
