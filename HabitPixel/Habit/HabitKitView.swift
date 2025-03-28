//
//  HabitKitView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 23/03/2025.
//

import SwiftUI
import SwiftData

// Add CategoryFilterView
struct CategoryFilterView: View {
    let categories = ["Art", "Health", "Learning", "Fitness"]
    let colors: ColorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    HStack(spacing: 4) {
                        Image(systemName: category == "Art" ? "paintbrush.fill" : "circle")
                            .font(.caption)
                        Text(category)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(category == "Art" ? colors.primary.opacity(0.1) : colors.surface)
                    .foregroundColor(category == "Art" ? colors.primary : colors.onBackground)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
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
    @Query private var habits: [HabitEntity]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingNewHabit = false
    @State private var showingSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let colors = AppColors.currentColorScheme
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CategoryFilterView(colors: colors)
                    
                    ForEach(habits) { habit in
                        HabitCardView(
                            habit: habit,
                            onComplete: { toggleTodayCompletion(for: habit) },
                            isCompleted: isTodayCompleted(for: habit)
                        )
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
                Text("Settings View")
            }
        }
    }
    
    private func addHabit(_ habit: HabitEntity) {
        modelContext.insert(habit)
    }
    
    private func deleteHabit(_ habit: HabitEntity) {
        modelContext.delete(habit)
        try? modelContext.save()
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
