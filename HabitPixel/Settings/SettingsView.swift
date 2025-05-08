import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingProView = false
    
    var body: some View {
        NavigationStack {
            List {
                // Pro Subscription Section
                Section(header: Text("")) {
                    Button(action: { showingProView = true }) {
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
                                    .foregroundColor(Color.theme.caption)
                            }
                        }
                    }
                }
                
                // App Settings Section
                Section(header: Text("App")) {
                    NavigationLink(destination: ThemeSettingsView()) {
                        SettingsRowView(icon: "paintbrush.fill", title: "Theme", color: .orange)
                    }
                    NavigationLink(destination: ArchivedHabitsView(modelContext: modelContext)) {
                        SettingsRowView(icon: "archivebox.fill", title: "Archived Habits", color: .cyan)
                    }
                    NavigationLink(destination: ReorderHabitsView()) {
                        SettingsRowView(icon: "list.bullet", title: "Reorder Habits", color: .red)
                    }
                }
                
                // General Links Section
                Section(header: Text("General")) {
                    NavigationLink(destination: Text("Website")) {
                        SettingsRowView(icon: "globe", title: "Website", color: .green)
                    }
                    NavigationLink(destination: Text("Follow on Twitter")) {
                        SettingsRowView(icon: "bird.fill", title: "Follow on Twitter", color: .blue)
                    }
                    NavigationLink(destination: Text("Privacy Policy")) {
                        SettingsRowView(icon: "lock.fill", title: "Privacy Policy", color: .pink)
                    }
                    NavigationLink(destination: Text("Terms of Use")) {
                        SettingsRowView(icon: "doc.text.fill", title: "Terms of Use", color: .teal)
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
                            .foregroundColor(Color.theme.onBackground)
                    }
                }
            }
            .sheet(isPresented: $showingProView) {
                UnlockProView()
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
                .foregroundColor(Color.theme.onBackground)
        }
    }
}
