import SwiftUI
import SwiftData

struct HabitKitView: View {
    @Query private var habits: [HabitEntity]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNewHabit = false
    @State private var showingSettings = false
    @State private var selectedCategory: Category = .all
    
    var activeCategories: [Category] {
        let activeNames = Set(habits.map { $0.category })
        return [Category.all] + Category.categories
            .filter { category in
                activeNames.contains(category.name)
            }
    }
    
    var filteredHabits: [HabitEntity] {
        if selectedCategory == .all {
            return habits
        }
        return habits.filter { $0.category == selectedCategory.name }
    }
    
    var body: some View {
        let colors = AppColors.currentColorScheme
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !habits.isEmpty {
                        CategoryFilterView(
                            selectedCategory: $selectedCategory,
                            activeCategories: activeCategories
                        )
                    }
                    
                    if filteredHabits.isEmpty {
                        EmptyStateView(
                            habits: habits,
                            showingNewHabit: $showingNewHabit,
                            colors: colors
                        )
                    } else {
                        ForEach(filteredHabits) { habit in
                            HabitCardView(
                                habit: habit,
                                onComplete: { toggleTodayCompletion(for: habit) },
                                isCompleted: isTodayCompleted(for: habit)
                            )
                        }
                    }
                }
            }
            .background(colors.background)
            .navigationTitle("HabitKit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: SettingsButton(showingSettings: $showingSettings, colors: colors),
                trailing: TrailingButtons(showingNewHabit: $showingNewHabit, colors: colors)
            )
            .sheet(isPresented: $showingNewHabit) {
                NewHabitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: habits) { _, _ in
                if selectedCategory != .all && !activeCategories.contains(where: { $0.id == selectedCategory.id }) {
                    selectedCategory = .all
                }
            }
        }
    }
    
    private func toggleTodayCompletion(for habit: HabitEntity) {
        HabitEntity.toggleCompletion(habit: habit, date: Date(), context: modelContext)
    }
    
    private func isTodayCompleted(for habit: HabitEntity) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return habit.entries.contains { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
}
