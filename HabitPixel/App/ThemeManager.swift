import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var selectedTheme: ThemeMode = .system {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var forceUpdate = UUID()
    
    init() { }
    
    func updateTheme(to mode: ThemeMode) {
        selectedTheme = mode
        forceUpdate = UUID() // Force views to update
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

struct ThemeModifier: ViewModifier {
    @ObservedObject private var themeManager: ThemeManager
    
    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentColorScheme)
            .id(themeManager.forceUpdate) // Force view refresh on theme change
    }
}

extension View {
    func applyTheme(_ themeManager: ThemeManager) -> some View {
        modifier(ThemeModifier(themeManager: themeManager))
    }
}
