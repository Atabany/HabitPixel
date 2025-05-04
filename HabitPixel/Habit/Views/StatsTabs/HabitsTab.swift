import SwiftUI

struct HabitsTab: View {
    let habits: [HabitEntity]
    @Binding var selectedHabit: HabitEntity?
    @State private var searchText = ""
    @State private var selectedCategory: Category = .all
    
    var filteredHabits: [HabitEntity] {
        habits
            .filter { habit in
                let matchesSearch = searchText.isEmpty ||
                    habit.title.localizedCaseInsensitiveContains(searchText)
                let matchesCategory = selectedCategory == .all ||
                    habit.category == selectedCategory.name
                return matchesSearch && matchesCategory
            }
            .sorted { $0.entries.count > $1.entries.count }
    }
    
    var activeCategories: [Category] {
        let categoryNames = Set(habits.map { $0.category })
        return [Category.all] + Category.categories.filter { categoryNames.contains($0.name) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.theme.caption)
                TextField("Search habits", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.caption)
                    }
                }
            }
            .padding(10)
            .background(Color.theme.surface)
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activeCategories, id: \.id) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Habits list
            ScrollView {
                if filteredHabits.isEmpty {
                    ContentUnavailableView(
                        "No Habits Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or category filter")
                    )
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredHabits) { habit in
                            HabitStatRow(
                                habit: habit,
                                onTap: {
                                    selectedHabit = habit
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.name)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.theme.primary.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? Color.theme.primary : Color.theme.onBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .inset(by: 1)
                    .stroke(isSelected ? Color.theme.primary : Color.theme.onBackground.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct HabitStatRow: View {
    let habit: HabitEntity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: habit.iconName)
                    .font(.title2)
                    .foregroundColor(habit.color)
                    .frame(width: 40, height: 40)
                    .background(habit.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundColor(Color.theme.onBackground)
                    
                    HStack {
                        Label("\(habit.currentStreak())", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        
                        Text("•")
                            .foregroundColor(Color.theme.caption)
                        
                        Label("\(habit.entries.count)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(habit.color)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.caption)
            }
            .padding()
            .background(Color.theme.surface)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
