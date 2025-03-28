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
    
    // Replace HabitStore with direct state management
    @State private var name: String
    @State private var description: String
    @State private var selectedInterval: Interval
    @State private var completionsPerInterval: Int
    @State private var selectedDays: Set<Day>
    @State private var category: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    
    // Properties for validation
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    // Update editing habit type
    private let editingHabit: HabitEntity?
    
    // Keep your existing UI state properties
    @State private var highlightedIcon = false
    @State private var highlightedColor = false
    
    // Update initializer
    init(editingHabit: HabitEntity? = nil) {
        self.editingHabit = editingHabit
        _name = State(initialValue: editingHabit?.title ?? "")
        _description = State(initialValue: editingHabit?.habitDescription ?? "")
        _selectedInterval = State(initialValue: Interval(rawValue: editingHabit?.frequency ?? "") ?? .none)
        _completionsPerInterval = State(initialValue: editingHabit?.goal ?? 1)
        _selectedDays = State(initialValue: [])
        _category = State(initialValue: editingHabit?.category ?? "None")
        _selectedIcon = State(initialValue: editingHabit?.iconName ?? "waveform.path.ecg")
        _selectedColor = State(initialValue: editingHabit?.color ?? .red)
    }
    
    // Add predefined categories
    private let categories = [
        ("Fitness", "figure.walk"),
        ("Health", "heart"),
        ("Learning", "book"),
        ("Mindfulness", "brain.head.profile"),
        ("Productivity", "chart.bar"),
        ("Finance", "dollarsign.circle"),
        ("Social", "person.2"),
        ("Art", "paintbrush"),
        ("Other", "circle.grid.cross")
    ]
    
    // Add quick access icons and colors
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
    
    private var showSelectedIcon: Bool {
        !quickIcons.contains(selectedIcon)
    }
    
    private var showSelectedColor: Bool {
        !quickColors.contains(selectedColor)
    }
    
    var body: some View {
        let themeColors = AppColors.currentColorScheme
        
        NavigationStack {
            Form {
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
                            if selectedInterval != .none {
                                Text("\(completionsPerInterval) per \(selectedInterval.rawValue.lowercased())")
                                    .foregroundColor(themeColors.caption)
                            } else {
                                Text("Not set")
                                    .foregroundColor(themeColors.caption)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ReminderView(selectedDays: $selectedDays)) {
                        HStack {
                            Text("Reminder")
                            Spacer()
                            Text(selectedDays.isEmpty ? "None" : selectedDays.map { $0.rawValue }.joined(separator: ", "))
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
                
                Section(header: Text("Icon").foregroundColor(themeColors.onBackground)) {
                    VStack(alignment: .leading, spacing: 20) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            if showSelectedIcon {
                                IconButton(icon: selectedIcon, selectedIcon: selectedIcon, isHighlighted: false) {
                                    selectedIcon = selectedIcon
                                    withAnimation(.spring()) {
                                        highlightedIcon = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedIcon = false }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                .stroke(themeColors.primary, lineWidth: 2)
                                )
                            }
                            
                            ForEach(quickIcons.prefix(showSelectedIcon ? 19 : 20), id: \.self) { icon in
                                IconButton(icon: icon, selectedIcon: selectedIcon, isHighlighted: highlightedIcon && selectedIcon == icon) {
                                    selectedIcon = icon
                                    withAnimation(.spring()) {
                                        highlightedIcon = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedIcon = false }
                                    }
                                }
                            }
                            
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: IconSelectionView(selectedIcon: $selectedIcon).onDisappear {
                                    withAnimation(.spring()) {
                                        highlightedIcon = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedIcon = false }
                                    }
                                }) {
                                    EmptyView()
                                }
                                .opacity(0)
                                ZStack {
                                    Circle()
                                        .fill(themeColors.surface)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(themeColors.primary, lineWidth: 1)
                                        )
                                    
                                    Text("More")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeColors.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Color").foregroundColor(themeColors.onBackground)) {
                    VStack(alignment: .leading, spacing: 20) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            if showSelectedColor {
                                ColorButton(color: selectedColor, selectedColor: selectedColor, isHighlighted: false) {
                                    selectedColor = selectedColor
                                    withAnimation(.spring()) {
                                        highlightedColor = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedColor = false }
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(themeColors.primary, lineWidth: 2)
                                )
                            }
                            
                            ForEach(quickColors.prefix(showSelectedColor ? 12 : 13), id: \.self) { color in
                                ColorButton(color: color, selectedColor: selectedColor, isHighlighted: highlightedColor && selectedColor == color) {
                                    selectedColor = color
                                    withAnimation(.spring()) {
                                        highlightedColor = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedColor = false }
                                    }
                                }
                            }
                            
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: ColorSelectionView(selectedColor: $selectedColor).onDisappear {
                                    withAnimation(.spring()) {
                                        highlightedColor = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { highlightedColor = false }
                                    }
                                }) {
                                    EmptyView()
                                }
                                .opacity(0)
                                ZStack {
                                    Circle()
                                        .fill(themeColors.surface)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                            .stroke(themeColors.primary, lineWidth: 1)
                                        )
                                    
                                    Text("More")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeColors.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
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
            .background(themeColors.background)
            .navigationTitle(editingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarItems(leading: Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(themeColors.onBackground)
            })
            .alert(isPresented: $showingValidationAlert) {
                Alert(title: Text("Validation Error"), message: Text(validationMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Update validation function
    func validateForm() -> Bool {
        guard !name.isEmpty else {
            validationMessage = "Name is required"
            showingValidationAlert = true
            return false
        }
        
        guard selectedInterval != .none else {
            validationMessage = "Please select an interval"
            showingValidationAlert = true
            return false
        }
        
        return true
    }
    
    // Update save function to match the new model
    func saveHabit() {
        if let existingHabit = editingHabit {
            // Update existing habit
            existingHabit.title = name
            existingHabit.habitDescription = description
            existingHabit.frequency = selectedInterval.rawValue
            existingHabit.goal = completionsPerInterval
            existingHabit.iconName = selectedIcon
            existingHabit.category = category
            existingHabit.color = selectedColor
            existingHabit.reminderDays = selectedDays.map { $0.rawValue }
        } else {
            // Create new habit with all features
            let habit = HabitEntity(
                title: name,
                description: description,
                goal: completionsPerInterval,
                frequency: selectedInterval.rawValue,
                iconName: selectedIcon,
                color: selectedColor,
                category: category,
                createdAt: Date(),
                reminderTime: nil,
                reminderDays: selectedDays.map { $0.rawValue },
                isArchived: false
            )
            modelContext.insert(habit)
        }
        
        try? modelContext.save()
        dismiss()
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
                        .stroke(themeColors.primary, lineWidth: selectedIcon == icon ? 0 : 1)
                )
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
    }
}

struct ColorButton: View {
    let color: Color
    let selectedColor: Color
    let isHighlighted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(selectedColor == color ? .white : Color.clear, lineWidth: 2)
                )
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHighlighted)
    }
}
