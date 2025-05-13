
import WidgetKit
import AppIntents
import Intents
import IntentsUI

struct SelectHabitIntent: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent {
    
    static let intentClassName: String = "SelectHabitIntent"
    static var title: LocalizedStringResource =  "Select Habit"
    static var description = IntentDescription("Choose a habit to track")
    
    @Parameter(title: "Habit", optionsProvider: HabitOptionsProvider())
    var habit: String?
    
    struct HabitOptionsProvider: DynamicOptionsProvider {
        func results() async throws -> [String] {
            HabitsHelper.loadAllHabits()?.compactMap(\.title) ?? []
        }

        func defaultResult() async -> String? {
            HabitsHelper.loadAllHabits()?.first?.title
        }
    }
}
