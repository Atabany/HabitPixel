import Foundation

final class SharedStorage {
    static let shared = SharedStorage()
    
    let defaults: UserDefaults
    
    private init() {
        guard let defaults = UserDefaults(suiteName: "group.com.atabany.HabitRix") else {
            fatalError("Failed to initialize app group UserDefaults")
        }
        self.defaults = defaults
    }
    
    // MARK: - Keys
    enum Keys: String, CaseIterable {
        case widgetHabits = "WidgetHabits"
        case isPro = "isPro"
        // Add more keys as needed
    }
    
    // MARK: - Widget Data
    func saveWidgetHabits(_ data: Data) {
        defaults.set(data, forKey: Keys.widgetHabits.rawValue)
    }
    
    // MARK: - Pro Status
    var isPro: Bool {
        get { defaults.bool(forKey: Keys.isPro.rawValue) }
        set { defaults.set(newValue, forKey: Keys.isPro.rawValue) }
    }
    
    // MARK: - Utilities
    func synchronize() {
        defaults.synchronize()
    }
    
    func removeAll() {
        Keys.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
        synchronize()
    }
}
