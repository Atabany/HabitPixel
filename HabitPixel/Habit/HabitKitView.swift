//
//  HabitKitView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 23/03/2025.
//

import SwiftUI
import SwiftData

struct CategoryFilterView: View {
    @Binding var selectedCategory: Category
    let activeCategories: [Category]
    let themeColors = AppColors.currentColorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Always show "All" category
                categoryButton(for: Category.all)
                
                // Show only categories with habits
                ForEach(activeCategories.filter { $0 != .all }) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func categoryButton(for category: Category) -> some View {
        Button(action: { selectedCategory = category }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.name)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedCategory.id == category.id ? themeColors.primary.opacity(0.1) : themeColors.surface)
            .foregroundColor(selectedCategory.id == category.id ? themeColors.primary : themeColors.onBackground)
            .clipShape(Capsule())
        }
    }
}

// Add HabitCardView
struct HabitCardView: View {
    let habit: HabitEntity
    let onComplete: () -> Void
    let isCompleted: Bool
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(spacing: 12) {
                // Habit header
                HStack(spacing: 12) {
                    Image(systemName: habit.iconName)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(habit.color.opacity(0.1))
                        .foregroundColor(habit.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.headline)
                        if !habit.habitDescription.isEmpty {
                            Text(habit.habitDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onComplete) {
                        Circle()
                            .fill(isCompleted ? habit.color : habit.color.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .foregroundColor(isCompleted ? .white : habit.color)
                            )
                    }
                }
                
                // Activity grid
                HabitActivityGrid(habit: habit)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            HabitDetailView(habit: habit)
                .presentationBackground(.clear)
        }
    }
}

// Main view
struct HabitKitView: View {
    @Query(
        filter: #Predicate<HabitEntity> { habit in
            habit.isArchived == false
        },
        sort: \HabitEntity.createdAt
    ) private var habits: [HabitEntity]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNewHabit = false
    @State private var showingSettings = false
    @State private var selectedCategory: Category = .all
    
    var activeCategories: [Category] {
        // Get unique category names from habits
        let activeNames = Set(habits.map { $0.category })
        
        // Always include "All" category and then filter Category.categories
        // to only include those that have habits
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
                        VStack(spacing: 12) {
                            Image(systemName: "square.grid.2x2")
                                .font(.largeTitle)
                                .foregroundColor(colors.caption)
                            
                            Text(habits.isEmpty ? "No habits yet" : "No habits in this category")
                                .font(.headline)
                                .foregroundColor(colors.caption)
                            
                            Button(action: { showingNewHabit = true }) {
                                Text("Add Habit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(colors.primary)
                                    .foregroundColor(colors.onPrimary)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 40)
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
                leading: Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(colors.onBackground)
                },
                trailing: HStack(spacing: 16) {
                    Button(action: {}) {
                        Text("PRO")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(colors.onBackground)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(colors.onBackground)
                    }
                    
                    Button(action: { showingNewHabit = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(colors.onBackground)
                    }
                }
            )
            .sheet(isPresented: $showingNewHabit) {
                NewHabitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: habits) { _, _ in
                // If the selected category no longer has habits, switch to "All"
                if selectedCategory != .all && !activeCategories.contains(where: { $0.id == selectedCategory.id }) {
                    selectedCategory = .all
                }
            }
        }
    }
    
    private func addHabit(_ habit: HabitEntity) {
        modelContext.insert(habit)
    }
    
    private func toggleTodayCompletion(for habit: HabitEntity) {
        HabitEntity.toggleCompletion(habit: habit, date: Date(), context: modelContext, allHabits: habits)
    }
    
    private func isTodayCompleted(for habit: HabitEntity) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return habit.entries.contains { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
}
