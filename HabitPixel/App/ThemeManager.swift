import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: ThemeMode = .system {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var forceUpdate = UUID()
    
    init() { }
    
    func updateTheme(to mode: ThemeMode) {
        selectedTheme = mode
        forceUpdate = UUID()
        objectWillChange.send()
    }
    
    var currentColorScheme: SwiftUI.ColorScheme? {
        switch selectedTheme {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
}

// MARK: - View Modifier
struct ThemeModifier: ViewModifier {
    @ObservedObject private var themeManager: ThemeManager
    
    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(themeManager.forceUpdate)
    }
}

extension View {
    func applyTheme(_ themeManager: ThemeManager) -> some View {
        modifier(ThemeModifier(themeManager: themeManager))
    }
}

// MARK: - Environment Values
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ThemeMode = .system
}

extension EnvironmentValues {
    var themeMode: ThemeMode {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
