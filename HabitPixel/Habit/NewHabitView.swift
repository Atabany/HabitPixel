//
//  NewHabitView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI
import SwiftData

struct NewHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State private var name: String
    @State private var description: String
    @State private var selectedInterval: Interval
    @State private var completionsPerInterval: Int
    @State private var selectedDays: Set<Day>
    @State private var category: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var reminderTime: Date = Date()

    @State private var showingValidationAlert = false
    @State private var validationMessage = ""

    private let editingHabit: HabitEntity?

    @State private var highlightedIcon = false
    @State private var highlightedColor = false

    init(editingHabit: HabitEntity? = nil) {
        self.editingHabit = editingHabit
        _name = State(initialValue: editingHabit?.title ?? "")
        _description = State(initialValue: editingHabit?.habitDescription ?? "")
        _selectedInterval = State(initialValue: Interval(rawValue: editingHabit?.frequency ?? "") ?? .daily)
        _completionsPerInterval = State(initialValue: editingHabit?.goal ?? 1)
        _selectedDays = State(initialValue: [])
        _category = State(initialValue: editingHabit?.category ?? "None")
        _selectedIcon = State(initialValue: editingHabit?.iconName ?? "waveform.path.ecg")
        _selectedColor = State(initialValue: editingHabit?.color ?? .red)
        _reminderTime = State(initialValue: editingHabit?.reminderTime ?? Date())

        if let days = editingHabit?.reminderDays {
            _selectedDays = State(initialValue: Set(days.compactMap { Day(rawValue: $0) }))
        }
    }

    private var categories: [(String, String)] {
        Category.categories.dropFirst().map { ($0.name, $0.icon) }
    }

    private let quickIcons = [
        "waveform.path.ecg", "alarm", "apple.logo", "bed.double", "folder",
        "heart", "list.bullet", "paintbrush", "gamecontroller", "bicycle",
        "book", "brain", "music.note", "shower", "chart.bar",
        "pencil", "envelope", "calendar", "mic", "camera"
    ]

    private let quickColors: [Color] = [
        Color(hex: 0xFF6B6B), // Red
        Color(hex: 0xFF922B), // Orange
        Color(hex: 0xFABD2F), // Yellow
        Color(hex: 0xB8BB26), // Yellow-Green
        Color(hex: 0x8EC07C), // Green
        Color(hex: 0x83A598), // Blue-Green
        Color(hex: 0x458588), // Blue
        Color(hex: 0x689D6A), // Sea Green
        Color(hex: 0xD3869B), // Pink
        Color(hex: 0xB16286), // Purple
        Color(hex: 0xD65D0E), // Dark Orange
        Color(hex: 0xCC241D), // Dark Red
        Color(hex: 0x98971A), // Dark Yellow-Green
        Color(hex: 0x458588)  // Dark Blue
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

    var body: some View {
        let themeColors = AppColors.currentColorScheme

        NavigationStack {
            Form {
                HabitDetailsFormSection(
                    name: $name,
                    description: $description,
                    selectedInterval: $selectedInterval,
                    completionsPerInterval: $completionsPerInterval,
                    selectedDays: $selectedDays,
                    reminderTime: $reminderTime,
                    category: $category,
                    categories: categories,
                    themeColors: themeColors
                )

                Section {
                    HStack {
                        Text("Icon").foregroundColor(themeColors.onBackground)
                        Spacer()
                        Image(systemName: selectedIcon)
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(selectedColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(quickIcons, id: \.self) { icon in
                            IconButton(icon: icon, selectedIcon: selectedIcon, isHighlighted: highlightedIcon && selectedIcon == icon) {
                                selectedIcon = icon
                                withAnimation(.spring()) { highlightedIcon = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { highlightedIcon = false }
                                }
                            }
                        }
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: IconSelectionView(selectedIcon: $selectedIcon).onDisappear {
                                withAnimation(.spring()) { highlightedIcon = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { highlightedIcon = false }
                                }
                            }) { EmptyView() }.opacity(0)
                            ZStack {
                                Circle().fill(themeColors.surface)
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(themeColors.primary, lineWidth: 1))
                                Text("More").font(.caption2).fontWeight(.medium).foregroundColor(themeColors.primary)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))

                Section {
                    HStack {
                        Text("Color").foregroundColor(themeColors.onBackground)
                        Spacer()
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(themeColors.onBackground.opacity(0.5), lineWidth: 1))
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(quickColors, id: \.self) { color in
                            ColorButton(color: color, selectedColor: selectedColor, isHighlighted: highlightedColor && selectedColor == color) {
                                selectedColor = color
                                withAnimation(.spring()) { highlightedColor = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { highlightedColor = false }
                                }
                            }
                        }
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: ColorSelectionView(selectedColor: $selectedColor).onDisappear {
                                withAnimation(.spring()) { highlightedColor = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { highlightedColor = false }
                                }
                            }) { EmptyView() }.opacity(0)
                            ZStack {
                                Circle().fill(themeColors.surface)
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(themeColors.primary, lineWidth: 1))
                                Text("More").font(.caption2).fontWeight(.medium).foregroundColor(themeColors.primary)
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))

                Button("Save") {
                    if validateForm() {
                        saveHabit()
                        dismiss()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(themeColors.primary)
                .foregroundColor(themeColors.onPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .scrollContentBackground(.hidden)
            .background(themeColors.background)
            .navigationTitle(editingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarItems(leading: Button(action: { dismiss() }) {
                Image(systemName: "xmark").foregroundColor(themeColors.onBackground)
            }, trailing: Button("Save") {
                if validateForm() { saveHabit() }
            }.foregroundColor(themeColors.primary))
            .alert(isPresented: $showingValidationAlert) {
                Alert(title: Text("Validation Error"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func validateForm() -> Bool {
        guard !name.isEmpty else {
            validationMessage = "Name is required"
            showingValidationAlert = true
            return false
        }

        return true
    }

    func saveHabit() {
        if let existingHabit = editingHabit {
            existingHabit.title = name
            existingHabit.habitDescription = description
            existingHabit.frequency = selectedInterval.rawValue
            existingHabit.goal = completionsPerInterval
            existingHabit.iconName = selectedIcon
            existingHabit.category = category
            existingHabit.color = selectedColor
            existingHabit.reminderDays = selectedDays.map { $0.rawValue }.sorted()
            if !selectedDays.isEmpty {
                existingHabit.reminderTime = reminderTime
                NotificationManager.shared.scheduleNotifications(for: existingHabit)
            } else {
                existingHabit.reminderTime = nil
                NotificationManager.shared.removeNotifications(for: existingHabit)
            }
        } else {
            let habit = HabitEntity(
                title: name,
                description: description,
                goal: completionsPerInterval,
                frequency: selectedInterval.rawValue,
                iconName: selectedIcon,
                color: selectedColor,
                category: category,
                createdAt: Date(),
                reminderTime: selectedDays.isEmpty ? nil : reminderTime,
                reminderDays: selectedDays.map { $0.rawValue }.sorted(),
                isArchived: false
            )
            modelContext.insert(habit)

            if !selectedDays.isEmpty {
                NotificationManager.shared.scheduleNotifications(for: habit)
            }
        }

        try? modelContext.save()
        dismiss()
    }

    private struct HabitDetailsFormSection: View {
        @Binding var name: String
        @Binding var description: String
        @Binding var selectedInterval: Interval
        @Binding var completionsPerInterval: Int
        @Binding var selectedDays: Set<Day>
        @Binding var reminderTime: Date
        @Binding var category: String
        let categories: [(String, String)]
        let themeColors: ColorScheme

        var body: some View {
            Section(header: Text("Name").foregroundColor(themeColors.onBackground)) {
                TextField("Name", text: $name)
            }

            Section(header: Text("Description").foregroundColor(themeColors.onBackground)) {
                TextField("Description", text: $description)
            }

            Section {
                NavigationLink(destination: StreakGoalView(selectedInterval: $selectedInterval, completionsPerInterval: $completionsPerInterval)) {
                    HStack {
                        Text("Streak Goal")
                        Spacer()
                        Text("\(completionsPerInterval) \(selectedInterval.rawValue.lowercased())")
                            .foregroundColor(themeColors.caption)
                    }
                }

                NavigationLink(destination: ReminderView(selectedDays: $selectedDays, reminderTime: $reminderTime)) {
                    HStack {
                        Text("Reminder")
                        Spacer()
                        Text(selectedDays.isEmpty ? "None" : selectedDays.map { $0.rawValue }.sorted().joined(separator: ", "))
                            .foregroundColor(themeColors.caption)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.0) { categoryItem in
                            Button(action: {
                                category = categoryItem.0
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: categoryItem.1)
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(category == categoryItem.0 ? themeColors.primary : themeColors.surface)
                                        .foregroundColor(category == categoryItem.0 ? themeColors.onPrimary : themeColors.onBackground)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(themeColors.primary, lineWidth: category == categoryItem.0 ? 0 : 1)
                                        )

                                    Text(categoryItem.0)
                                        .font(.caption)
                                        .foregroundColor(category == categoryItem.0 ? themeColors.primary : themeColors.onBackground)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let selectedIcon: String
    let isHighlighted: Bool
    let action: () -> Void
    let themeColors = AppColors.currentColorScheme

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(selectedIcon == icon ? themeColors.primary : themeColors.surface)
                .foregroundColor(selectedIcon == icon ? themeColors.onPrimary : themeColors.onBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(themeColors.primary, lineWidth: selectedIcon == icon ? 2 : 1)
                )
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
        .animation(.easeOut(duration: 0.15), value: selectedIcon)
    }
}

struct ColorButton: View {
    let color: Color
    let selectedColor: Color
    let isHighlighted: Bool
    let action: () -> Void
    let themeColors = AppColors.currentColorScheme

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(selectedColor == color ? themeColors.primary : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
        .animation(.easeOut(duration: 0.15), value: selectedColor)
    }
}
