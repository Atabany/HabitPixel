import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeMode = .system
}

extension EnvironmentValues {
    var appTheme: ThemeMode {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    
    var body: some View {
        List {
            Section("Mode") {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.rawValue)
                        Spacer()
                        if themeManager.currentColorScheme == (mode == .dark ? .dark : mode == .light ? .light : nil) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            themeManager.updateTheme(to: mode)
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme")
        .applyTheme(themeManager)
    }
}
