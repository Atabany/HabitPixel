import SwiftUI
import WidgetKit
import SwiftData

@Observable
final class WidgetManager {
    static let shared = WidgetManager()
    private let storage = SharedStorage.shared
    
    private init() {}
    
    func syncWidgets(_ habits: [HabitEntity]) {
        Task { @MainActor in
            // Create display info snapshots
            let displayInfos = habits.map {
                HabitDisplayInfo(
                    id: "\($0.persistentModelID)",
                    title: $0.title,
                    iconName: $0.iconName,
                    color: $0.color,
                    completedDates: Set($0.entries.map { Calendar.current.startOfDay(for: $0.timestamp) }),
                    startDate: $0.dateRange?.first ?? $0.createdAt,
                    endDate: $0.dateRange?.last ?? $0.createdAt
                )
            }
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(displayInfos)
                storage.saveWidgetHabits(data)
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Error encoding/saving widget data: \(error)")
            }
        }
    }
    
}
