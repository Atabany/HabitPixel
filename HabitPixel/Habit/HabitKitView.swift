//
//  HabitKitView.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 23/03/2025.
//

import SwiftUI
import SwiftData
import UIKit

enum DisplayMode: String, CaseIterable {
    case cards, rows, week

    var iconName: String {
        switch self {
        case .cards:
            return "square.grid.2x2.fill"
        case .rows:
            return "list.bullet.rectangle.fill"
        case .week:
            return "calendar"
        }
    }
    
    var title: String {
        switch self {
        case .cards:
            return "Grid View"
        case .rows:
            return "List View"
        case .week:
            return "Week View"
        }
    }
}

// MARK: - Main HabitKitView
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
    @AppStorage("displayMode") private var displayMode: DisplayMode = .rows
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @State private var showingDetail: HabitEntity? = nil
    
    private var isProUser: Bool {
        SharedStorage.shared.isPro
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
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    mainContent
                }
                floatingDisplayModeBar
            }
            .background(Color.theme.background)
            .navigationTitle("HabitRix")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    lightHapticGenerator.impactOccurred()
                    showingSettings = true
                    lightHapticGenerator.prepare()
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color.theme.onBackground)
                },
                trailing: HStack(spacing: 16) {
                    Button(action: {
                        lightHapticGenerator.impactOccurred()
                        showingProUpgrade = true
                        lightHapticGenerator.prepare()
                    }) {
                        Text("PRO")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(Color.theme.onBackground)
                    }
                    
                    Button(action: {
                        lightHapticGenerator.impactOccurred()
                        if isProUser {
                            showingStats = true
                        } else {
                            showingProUpgrade = true
                        }
                        lightHapticGenerator.prepare()
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(Color.theme.onBackground)
                    }
                    
                    Button(action: {
                        lightHapticGenerator.impactOccurred()
                        if canAddMoreHabits {
                            showingNewHabit = true
                        } else {
                            showingProUpgrade = true
                        }
                        lightHapticGenerator.prepare()
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
            .onAppear {
                hapticGenerator.prepare()
                lightHapticGenerator.prepare()
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            if !habits.isEmpty {
                HStack {
                    CategoryFilterView(
                        selectedCategory: $selectedCategory,
                        activeCategories: activeCategories
                    )
                }
                .padding(.top, 8)
            }
            
            if filteredHabits.isEmpty {
                VStack(spacing: 18) {
                    LottieView(filename: "empty-state.json")
                        .frame(width: 120, height: 120)
                    Text(habits.isEmpty ? "No habits yet" : "No habits in this category")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.onBackground)
                    Text("Start building positive routines! Tap below to add your first habit.")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button(action: {
                        lightHapticGenerator.impactOccurred()
                        showingNewHabit = true
                        lightHapticGenerator.prepare()
                    }) {
                        Text("Add Habit")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.theme.primary)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.theme.primary.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                switch displayMode {
                case .cards:
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredHabits) { habit in
                            SimpleHabitCardView(
                                habit: habit,
                                onComplete: { toggleTodayCompletion(for: habit) },
                                isCompleted: isTodayCompleted(for: habit)
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                case .rows:
                    LazyVStack(spacing: 12) {
                        ForEach(filteredHabits) { habit in
                            HabitCardView(
                                habit: habit,
                                onComplete: { toggleTodayCompletion(for: habit) },
                                isCompleted: isTodayCompleted(for: habit)
                            )
                        }
                    }
                case .week:
                    LazyVStack(spacing: 20) {
                        ForEach(filteredHabits) { habit in
                            WeekHabitCardView(
                                habit: habit,
                                onShowDetail: { showingDetail = habit },
                                onToggleDay: { date in toggleCompletion(for: habit, on: date) }
                            )
                        }
                    }
                    .fullScreenCover(item: $showingDetail) { habit in
                        HabitDetailView(habit: habit)
                    }
                }
            }
        }
        .padding(.bottom, 70)
    }
    
    private func addHabit(_ habit: HabitEntity) {
        modelContext.insert(habit)
    }
    
    private func toggleTodayCompletion(for habit: HabitEntity) {
        HabitEntity.toggleCompletion(habit: habit, date: Date(), context: modelContext, allHabits: habits)
        hapticGenerator.impactOccurred()
        hapticGenerator.prepare()
    }
    
    private func isTodayCompleted(for habit: HabitEntity) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return habit.entries.contains { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
    
    private func toggleCompletion(for habit: HabitEntity, on date: Date) {
        if let entry = habit.entries.first(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }) {
            // Remove completion
            if let context = habit.modelContext {
                context.delete(entry)
                try? context.save()
            }
        } else {
            // Add completion
            let newEntry = EntryEntity(timestamp: date)
            habit.entries.append(newEntry)
            if let context = habit.modelContext {
                try? context.save()
            }
        }
    }
    
    @ViewBuilder
    private var floatingDisplayModeBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 16) {
                ForEach(DisplayMode.allCases, id: \.self) { mode in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            displayMode = mode
                        }
                    }) {
                        Image(systemName: mode.iconName)
                            .foregroundColor(displayMode == mode ? Color.theme.primary : Color.theme.onBackground)
                            .frame(width: 32, height: 32)
                            .background(displayMode == mode ? Color.theme.primary.opacity(0.12) : Color.theme.surface)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.theme.surface.opacity(0.95))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 4)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct WeekGridView: View {
    let habit: HabitEntity
    let onToggleDay: (Date) -> Void
    @State private var animatingIndex: Int? = nil

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private var weekSymbols: [String] {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
        return Array(symbols[1...6]) + [symbols[0]]
    }

    private var weekColumns: [(symbol: String, date: Date)] {
        Array(zip(weekSymbols, weekDates))
    }

    @ViewBuilder
    private func dayColumn(offset: Int, symbol: String, date: Date, pillWidth: CGFloat) -> some View {
        let isCompleted = habit.entries.contains { entry in
            Calendar.current.isDate(entry.timestamp, inSameDayAs: date)
        }
        VStack(spacing: 6) {
            Text(symbol)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.caption)
                .frame(height: 16)
            Button(action: {
                animatingIndex = offset
                onToggleDay(date)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    animatingIndex = nil
                }
            }) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isCompleted ?
                            AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [habit.color, habit.color.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.theme.surface)
                    )
                    .frame(width: pillWidth, height: 30)
                    .overlay(
                        Group {
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.scale)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isCompleted ? habit.color : Color.theme.border, lineWidth: isCompleted ? 2 : 1)
                    )
                    .scaleEffect(animatingIndex == offset ? 1.13 : 1.0)
                    .shadow(color: isCompleted ? habit.color.opacity(0.13) : .clear, radius: isCompleted ? 3 : 0, x: 0, y: 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: animatingIndex == offset)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("\(symbol) for \(habit.title)"))
        }
        .frame(width: pillWidth)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 12 * 6 // 6 spaces between 7 pills
            let pillWidth = max(28, (geometry.size.width - totalSpacing) / 7)
            HStack(spacing: 12) {
                ForEach(Array(weekColumns.enumerated()), id: \.offset) { offset, column in
                    dayColumn(offset: offset, symbol: column.symbol, date: column.date, pillWidth: pillWidth)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .background(Color.theme.surface.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .padding(.horizontal, 8)
        }
        .frame(height: 64)
    }
}

struct WeekHabitCardView: View {
    let habit: HabitEntity
    let onShowDetail: () -> Void
    let onToggleDay: (Date) -> Void

    var body: some View {
        Button(action: onShowDetail) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: habit.iconName)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(habit.color.opacity(0.12))
                        .foregroundColor(habit.color)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(habit.title)
                        .font(.headline)
                        .frame(minWidth: 80, alignment: .leading)
                    Spacer()
                }
                
                WeekGridView(habit: habit, onToggleDay: onToggleDay)
                    .allowsHitTesting(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.theme.surface)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

