import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let colors = AppColors.currentColorScheme // Assuming AppColors is defined elsewhere
    
    var body: some View {
        NavigationStack {
            List {
                // Pro Subscription Section
                Section {
                    NavigationLink(destination: Text("HabitKit Pro")) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [.purple, .blue, .green, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            VStack(alignment: .leading) {
                                Text("Subscribe to HabitKit Pro")
                                    .font(.headline)
                                Text("Unlimited habits, import/export data,...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // App Settings Section
                Section("App") {
                    NavigationLink(destination: Text("General Settings")) {
                        SettingsRowView(icon: "gearshape.fill", title: "General", color: .pink) // Updated color to match screenshot
                    }
                    NavigationLink(destination: ThemeSettingsView()) {
                        SettingsRowView(icon: "paintbrush.fill", title: "Theme", color: .orange)
                    }
                    NavigationLink(destination: ArchivedHabitsView()) {
                        SettingsRowView(icon: "archivebox.fill", title: "Archived Habits", color: .cyan) // Updated color to match screenshot
                    }
                    NavigationLink(destination: ReorderHabitsView()) {
                        SettingsRowView(icon: "list.bullet", title: "Reorder Habits", color: .red)
                    }
                }
                
                // General Links Section
                Section("General") {
                    NavigationLink(destination: Text("Website")) {
                        SettingsRowView(icon: "globe", title: "Website", color: .green)
                    }
                    NavigationLink(destination: Text("Follow on Twitter")) {
                        SettingsRowView(icon: "bird.fill", title: "Follow on Twitter", color: .blue) // Matches screenshot label
                    }
                    NavigationLink(destination: Text("Privacy Policy")) {
                        SettingsRowView(icon: "lock.fill", title: "Privacy Policy", color: .pink) // Updated color to match screenshot
                    }
                    NavigationLink(destination: Text("Terms of Use")) {
                        SettingsRowView(icon: "doc.text.fill", title: "Terms of Use", color: .teal) // Updated color to match screenshot
                    }
                    NavigationLink(destination: Text("Rate the app")) {
                        SettingsRowView(icon: "star.fill", title: "Rate the app", color: .purple)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colors.onBackground)
                    }
                }
            }
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
