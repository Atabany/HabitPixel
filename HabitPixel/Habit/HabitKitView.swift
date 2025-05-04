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
            .background(selectedCategory.id == category.id ? Color.theme.primary.opacity(0.1) : Color.theme.surface)
            .foregroundColor(selectedCategory.id == category.id ? Color.theme.primary : Color.theme.onBackground)
            .clipShape(Capsule())
        }
    }
}

struct ShareHabitCardView: View {
    let habit: HabitEntity
    
    var body: some View {
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
                        .foregroundColor(Color.theme.onBackground)
                    if !habit.habitDescription.isEmpty {
                        Text(habit.habitDescription)
                            .font(.caption)
                            .foregroundColor(Color.theme.caption)
                    }
                }
                
                Spacer()
            }
            
            // Activity grid
            HabitActivityGrid(habit: habit)
            
            HStack {
                Text("\(habit.goal) / \(habit.frequency)")
                    .font(.caption)
                    .foregroundColor(Color.theme.caption)
                
                Spacer()
                
                Text("HabitKit")
                    .font(.caption)
                    .foregroundColor(Color.theme.caption)
            }
        }
        .padding(16)
        .background(Color.theme.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct HabitCardView: View {
    let habit: HabitEntity
    let onComplete: () -> Void
    let isCompleted: Bool
    @State private var showingDetail = false
    @State private var showingShareView = false
    @Environment(\.displayScale) private var displayScale
    
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
                            .foregroundColor(Color.theme.onBackground)
                        if !habit.habitDescription.isEmpty {
                            Text(habit.habitDescription)
                                .font(.caption)
                                .foregroundColor(Color.theme.caption)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showingShareView = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color.theme.onBackground)
                        }
                        
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
                }
                
                // Activity grid
                HabitActivityGrid(habit: habit, overrideColor: nil)
            }
            .padding(16)
            .background(Color.theme.surface)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            HabitDetailView(habit: habit)
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $showingShareView) {
            ShareHabitView(habit: habit)
        }
    }
    
    private func renderShareImage() -> UIImage {
        let renderer = ImageRenderer(content: ShareHabitCardView(habit: habit))
        renderer.scale = displayScale
        
        // Configure renderer props
        renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.width - 32, height: nil)
        
        // Create the image
        return renderer.uiImage ?? UIImage()
    }
    
    private func shareHabit() {
        showingShareView = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
    @State private var showingStats = false
    @State private var showingProUpgrade = false
    @State private var selectedCategory: Category = .all
    
    private var isProUser: Bool {
        // TODO: Replace with actual premium status check
        false
    }
    
    private var canAddMoreHabits: Bool {
        isProUser || habits.count < 3
    }
    
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
                                .foregroundColor(Color.theme.caption)
                            
                            Text(habits.isEmpty ? "No habits yet" : "No habits in this category")
                                .font(.headline)
                                .foregroundColor(Color.theme.caption)
                            
                            Button(action: { showingNewHabit = true }) {
                                Text("Add Habit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.theme.primary)
                                    .foregroundColor(.white)
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
            .background(Color.theme.background)
            .navigationTitle("HabitKit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color.theme.onBackground)
                },
                trailing: HStack(spacing: 16) {
                    Button(action: { showingProUpgrade = true }) {
                        Text("PRO")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(Color.theme.onBackground)
                    }
                    
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color.theme.onBackground)
                    }
                    
                    Button(action: {
                        if canAddMoreHabits {
                            showingNewHabit = true
                        } else {
                            showingProUpgrade = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.onBackground)
                    }
                }
            )
            .sheet(isPresented: $showingNewHabit) {
                NewHabitView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingStats) {
                GlobalStatsView()
            }
            .sheet(isPresented: $showingProUpgrade) {
                UnlockProView()
            }
            .onChange(of: habits) { _, _ in
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
