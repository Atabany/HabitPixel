
import Foundation
import WidgetKit
import AppIntents
import SwiftUI

// MARK: - AppEntity representing a habit the user can pick
struct HabitEntity: Identifiable, Hashable, AppEntity {
    static var typeDisplayName: LocalizedStringResource = "Habit"

    var id: String
    var title: String

    static var defaultQuery = HabitQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    static func suggestedEntities() async throws -> [HabitEntity] {
        return try await HabitQuery().suggestedEntities()
    }

    static func defaultResult() async -> HabitEntity? {
        return try? await HabitQuery().suggestedEntities().first
    }
}

// MARK: EntityQuery supplying the dynamic list
struct HabitQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [HabitEntity] {
        guard let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel"),
              let data = defaults.data(forKey: "WidgetHabits") else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            return habits.map { HabitEntity(id: $0.id, title: $0.title) }
        } catch {
            return []
        }
    }
    
    func suggestedEntities() async throws -> [HabitEntity] {
        guard let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel"),
              let data = defaults.data(forKey: "WidgetHabits") else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let habits = try decoder.decode([HabitDisplayInfo].self, from: data)
            return habits.map { HabitEntity(id: $0.id, title: $0.title) }
        } catch {
            return []
        }
    }

    static func getSuggestedHabit() async -> HabitEntity? {
        let query = HabitQuery()
        return try? await query.suggestedEntities().first
    }
}
