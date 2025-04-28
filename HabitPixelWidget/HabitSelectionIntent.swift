import Foundation
import WidgetKit
import AppIntents

// MARK: - AppEntity representing a habit the user can pick
struct HabitEntity: Identifiable, Hashable, AppEntity {
    static var typeDisplayName: LocalizedStringResource = "Habit"

    var id: String
    var title: String

    // ADD: Instance display representation
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: nil
        )
    }

    // ADD: Type display representation
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Habit")
    }

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    static var defaultQuery = HabitEntityQuery()

    static func suggestedEntities() async throws -> [HabitEntity] {
        return try await HabitEntityQuery().suggestedEntities()
    }

    static func defaultResult() async -> HabitEntity? {
        return try? await HabitEntityQuery().defaultResult()
    }

    static func get(id: String) async -> HabitEntity? {
        try? await HabitEntityQuery().entities(for: [id]).first
    }
}

// MARK: EntityQuery supplying the dynamic list
struct HabitEntityQuery: EntityQuery {
    private let defaults = UserDefaults(suiteName: "group.com.atabany.HabitPixel")

    func entities(for identifiers: [String]) async throws -> [HabitEntity] {
        let all = try await suggestedEntities()
        guard !identifiers.isEmpty else { return all }
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        guard
            let data = defaults?.data(forKey: "WidgetHabits"),
            let habits = try? JSONDecoder().decode([HabitDisplayInfo].self, from: data)
        else { return [] }

        return habits.map { HabitEntity(id: $0.id, title: $0.title) }
    }

    func defaultResult() async -> HabitEntity? {
        try? await suggestedEntities().first
    }
}

// MARK: - AppIntent exposed to Widget configuration
struct HabitSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Choose which habit to display in the widget.")

    @Parameter(title: "Habit", description: "The habit to display in this widget")
    var habit: HabitEntity

    init() {
        // Provide a default, potentially loading the first available habit or a placeholder
        // For now, an empty placeholder entity suffices for initialization.
        // The defaultResult in HabitEntityQuery should handle the actual default selection.
        self.habit = HabitEntity(id: "", title: "Select Habit") // Use a placeholder title
    }

    init(habit: HabitEntity) {
        self.habit = habit
    }

    // CHANGE: Revert to simple string interpolation for Summary
    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$habit)")
    }

    // Required perform() method
    func perform() async throws -> some IntentResult {
        // This intent is just for configuration, so no action needed here.
        return .result()
    }
}
