import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingProView = false
    @State private var showingProUpgradeForArchive = false
    @State private var showingProUpgradeForReorder = false
    private let isProUser = SharedStorage.shared.isPro
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pro Subscription Card (fills width)
                Button(action: { showingProView = true }) {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: 0x0CA678), // Teal
                                            Color(hex: 0x20C997), // Lighter teal
                                            Color(hex: 0xFFD43B), // Yellow
                                            Color(hex: 0x4DABF7)  // Blue
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HabitRix Pro")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.theme.primary)
                                Text("Unlock Premium Features")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.caption)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.theme.caption)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ProFeatureRow(icon: "infinity", text: "Unlimited Habits")
                            ProFeatureRow(icon: "arrow.up.arrow.down", text: "Custom Habit Order")
                            ProFeatureRow(icon: "archivebox.fill", text: "Archive Habits")
                            ProFeatureRow(icon: "square.and.arrow.down", text: "Import/Export Data")
                            ProFeatureRow(icon: "square.grid.2x2.fill", text: "Unlimited Widgets")
                        }
                    }
                    .padding()
                    .background(Color.theme.surface)
                    .cornerRadius(20)
                    .shadow(color: Color.theme.primary.opacity(0.12), radius: 16, x: 0, y: 6)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                List {
                    // App Settings Section
                    Section(header: Text("App")) {
                        NavigationLink(destination: ThemeSettingsView()) {
                            SettingsRowView(icon: "paintbrush.fill", title: "Theme", color: .orange)
                        }
                        
                        if isProUser {
                            NavigationLink(destination: ArchivedHabitsView(modelContext: modelContext)) {
                                SettingsRowView(icon: "archivebox.fill", title: "Archived Habits", color: .cyan)
                            }
                        } else {
                            Button(action: { showingProUpgradeForArchive = true }) {
                                SettingsRowView(icon: "archivebox.fill", title: "Archived Habits", color: .cyan)
                            }
                        }
                        
                        if isProUser {
                            NavigationLink(destination: ReorderHabitsView(modelContext: modelContext)) {
                                SettingsRowView(icon: "list.bullet", title: "Reorder Habits", color: .red)
                            }
                        } else {
                            Button(action: { showingProUpgradeForReorder = true }) {
                                SettingsRowView(icon: "list.bullet", title: "Reorder Habits", color: .red)
                            }
                        }
                    }
                    
                    // General Links Section
                    Section(header: Text("General")) {
                        Button(action: {
                            if let url = URL(string: "https://tamtom.github.io/habitrixpolicy.html") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            SettingsRowView(icon: "lock.fill", title: "Privacy Policy", color: .pink)
                        }
                        Button(action: {
                            if let url = URL(string: "https://tamtom.github.io/habitrixterms.html") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            SettingsRowView(icon: "doc.text.fill", title: "Terms of Use", color: .teal)
                        }
                    }
                }
                .listStyle(.insetGrouped)
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
            .sheet(isPresented: $showingProUpgradeForArchive) {
                UnlockProView()
            }
            .sheet(isPresented: $showingProUpgradeForReorder) {
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

struct ProFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: 0x0CA678))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.theme.onBackground)
            Spacer()
        }
    }
}
