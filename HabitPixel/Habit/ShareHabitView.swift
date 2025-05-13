import SwiftUI


struct ShareHabitView: View {
    let habit: HabitEntity
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @State private var isDarkMode = false
    @State private var selectedColor: Color
    @State private var showCompletionIndicator = true
    @State private var showDescription = true
    @State private var showStreak = true
    @State private var showingShareSheet = false
    @StateObject private var viewModel: HabitActivityGridViewModel
    @State private var selectedTab = 0
    @State private var cardScale: CGFloat = 1
    
    init(habit: HabitEntity) {
        self.habit = habit
        _selectedColor = State(initialValue: habit.color)
        _viewModel = StateObject(wrappedValue: HabitActivityGridViewModel(habit: habit, allHabits: []))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Preview Card Section
                    shareableCard
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    
                    // Customization Section
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            Text("Customize")
                                .font(.system(size: 22, weight: .bold))
                            
                            Spacer()
                            
                            Button(action: resetCustomization) {
                                Text("Reset")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                        
                        // Tabs
                        Picker("Customization", selection: $selectedTab) {
                            Text("Style").tag(0)
                            Text("Content").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        
                        // Tab Content
                        VStack {
                            if selectedTab == 0 {
                                styleSection
                            } else {
                                contentSection
                            }
                        }
                        .padding(.top, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Share Habit")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: shareHabit) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [renderShareImage()])
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
    
    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Theme Toggle
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                    Text("Theme")
                }
                .font(.body)
                
                HStack(spacing: 0) {
                    themeButton(title: "Light", isSelected: !isDarkMode) {
                        withAnimation { isDarkMode = false }
                    }
                    themeButton(title: "Dark", isSelected: isDarkMode) {
                        withAnimation { isDarkMode = true }
                    }
                }
                .background(Color(.systemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Color Picker
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                    Text("Color")
                }
                .font(.body)
                
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(Color.presetColors, id: \.self) { color in
                        colorButton(color)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            toggleOption(
                title: "Completion Indicator",
                icon: "checkmark.circle",
                isOn: $showCompletionIndicator
            )
            
            toggleOption(
                title: "Description",
                icon: "text.alignleft",
                isOn: $showDescription
            )
            
            toggleOption(
                title: "Streak",
                icon: "flame",
                isOn: $showStreak
            )
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func themeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.secondary.opacity(0.2) : Color.clear)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
    }
    
    private func colorButton(_ color: Color) -> some View {
        Button(action: {
            hapticFeedback()
            withAnimation {
                selectedColor = color
            }
        }) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                )
        }
    }
    
    private var shareableCard: some View {
        Group {
            if let data = viewModel.gridData {
                VStack(spacing: 16) {
                    // Header
                    HStack(spacing: 16) {
                        Image(systemName: habit.iconName)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(selectedColor.opacity(0.1))
                            .foregroundColor(selectedColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            if showDescription && !habit.habitDescription.isEmpty {
                                Text(habit.habitDescription)
                                    .font(.subheadline)
                                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        if showCompletionIndicator {
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                )
                        }
                    }
                    
                    // Grid
                    let calendar = viewModel.calendar
                    let now = Date()
                    let weeksToShow = 15
                    let daysInWeek = 7
                    
                    // Get the start of the current week (Monday)
                    let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
                    // Calculate the start date by going back (weeksToShow - 1) weeks
                    let startDate = calendar.date(byAdding: .day, value: -(weeksToShow - 1) * daysInWeek, to: weekStart) ?? now
                    
                    VStack(spacing: 3) {
                        ForEach(0..<daysInWeek, id: \.self) { dayIndex in
                            HStack(spacing: 3) {
                                ForEach(0..<weeksToShow, id: \.self) { weekIndex in
                                    let date = calendar.date(byAdding: .day, value: weekIndex * daysInWeek + dayIndex, to: startDate) ?? startDate
                                    let startOfDay = calendar.startOfDay(for: date)
                                    let isCompleted = data.completedDates.contains(startOfDay)
                                    
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(selectedColor.opacity(isCompleted ? 1 : 0.1))
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Footer
                    HStack(spacing: 35) {
                        VStack {
                            Text(habit.frequency)
                                .font(.subheadline)
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            HStack(spacing: 4) {
                                Text("\(habit.getCompletionsInCurrentInterval())")
                                Text("/")
                                Text("\(habit.goal)")
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        VStack {
                            Text("Streak")
                                .font(.subheadline)
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            Text("\(habit.currentStreak())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(selectedColor)
                        }
                        
                        VStack {
                            Text("Remaining")
                                .font(.subheadline)
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            Text("\(habit.getRemainingForCurrentInterval())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 8)

                    // App Branding
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("HabitRix")
                                .font(.caption)
                        }
                        .foregroundColor(isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5))
                    }
                }
                .padding(24)
                .background(isDarkMode ? Color.black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ProgressView()
            }
        }
    }
    
    private func toggleOption(title: String, icon: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.body)
        }
        .tint(.green)
    }
    
    private func renderShareImage() -> UIImage {
        let renderer = ImageRenderer(content:
            shareableCard
                .frame(width: UIScreen.main.bounds.width - 32)
        )
        renderer.scale = displayScale
        renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.width - 32, height: nil)
        
        return renderer.uiImage ?? UIImage()
    }
    
    private func shareHabit() {
        showingShareSheet = true
    }
    
    private func resetCustomization() {
        hapticFeedback()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isDarkMode = false
            selectedColor = habit.color
            showCompletionIndicator = true
            showDescription = true
            showStreak = true
        }
    }
    
    private func hapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension Color {
    static let presetColors: [Color] = [
        .red, .orange, .yellow, .green,
        .mint, .teal, .cyan, .blue,
        .indigo, .purple, .pink, .gray,
        .brown, .black
    ]
}
