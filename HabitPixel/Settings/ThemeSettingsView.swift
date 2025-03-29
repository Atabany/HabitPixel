import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

struct ThemeSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: ThemeMode = .system
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme
    let colors = AppColors.currentColorScheme
    
    var body: some View {
        List {
            Section("Mode") {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    HStack {
                        Text(mode.rawValue)
                        Spacer()
                        if selectedTheme == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.purple)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            selectedTheme = mode
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme")
        .preferredColorScheme(selectedTheme == .dark ? .dark : selectedTheme == .light ? .light : nil)
    }
}
