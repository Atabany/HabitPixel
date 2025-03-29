import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let colors = AppColors.currentColorScheme
    
    var body: some View {
        NavigationStack {
            List {
                // Pro Subscription Section
                Section {
                    NavigationLink(destination: Text("HabitKit Pro")) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
//                                .foregroundStyle(.purple, .blue, .green, .yellow)
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
                        SettingsRowView(icon: "gearshape.fill", title: "General", color: .blue)
                    }
                    NavigationLink(destination: Text("Theme Settings")) {
                        SettingsRowView(icon: "paintbrush.fill", title: "Theme", color: .orange)
                    }
                    NavigationLink(destination: Text("Archived Habits")) {
                        SettingsRowView(icon: "archivebox.fill", title: "Archived Habits", color: .gray)
                    }
                    NavigationLink(destination: Text("Data Import/Export")) {
                        SettingsRowView(icon: "square.and.arrow.up.on.square.fill", title: "Data Import/Export", color: .blue)
                    }
                    NavigationLink(destination: Text("Reorder Habits")) {
                        SettingsRowView(icon: "list.bullet", title: "Reorder Habits", color: .red)
                    }
                }
                
                // General Links Section
                Section("General") {
                    NavigationLink(destination: Text("Website")) {
                        SettingsRowView(icon: "globe", title: "Website", color: .green)
                    }
                    NavigationLink(destination: Text("Twitter")) {
                        SettingsRowView(icon: "bird.fill", title: "Follow on Twitter", color: .blue)
                    }
                    NavigationLink(destination: Text("Privacy Policy")) {
                        SettingsRowView(icon: "lock.fill", title: "Privacy Policy", color: .gray)
                    }
                    NavigationLink(destination: Text("Terms of Use")) {
                        SettingsRowView(icon: "doc.text.fill", title: "Terms of Use", color: .gray)
                    }
                    NavigationLink(destination: Text("Rate App")) {
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
