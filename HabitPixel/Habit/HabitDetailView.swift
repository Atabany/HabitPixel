import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    let habit: HabitEntity
    
    @State private var showingEditSheet = false
    @State private var showingCalendar = false
    
    var body: some View {
        let colors = AppColors.currentColorScheme
        
        ZStack {
            // Blur background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            // Main content
            VStack(spacing: 20) {
                // Header area
                HStack(spacing: 12) {
                    Image(systemName: habit.iconName)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(habit.color.opacity(0.1))
                        .foregroundColor(habit.color)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        if !habit.habitDescription.isEmpty {
                            Text(habit.habitDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
                .padding(.top)
                
                // Activity grid
                HabitActivityGrid(habit: habit)
                
                // Stats row
                HStack(spacing: 35) {
                    // Current interval progress
                    VStack {
                        Text(habit.frequency)
                            .font(.subheadline)
                            .foregroundColor(colors.onBackground)
                        HStack(spacing: 4) {
                            Text("\(habit.getCompletionsInCurrentInterval())")
                            Text("/")
                            Text("\(habit.goal)")
                        }
                        .font(.title2)
                        .fontWeight(.bold)
                    }
                    
                    // Streak
                    VStack {
                        Text("Streak")
                            .font(.subheadline)
                            .foregroundColor(colors.onBackground)
                        Text("\(habit.currentStreak())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(habit.color)
                    }
                    
                    // Remaining
                    VStack {
                        Text("Remaining")
                            .font(.subheadline)
                            .foregroundColor(colors.onBackground)
                        Text("\(habit.getRemainingForCurrentInterval())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Bottom actions
                HStack(spacing: 30) {
                    Button(action: { showingCalendar = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.title3)
                            Text("Calendar")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showingEditSheet = true }) {
                        VStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.title3)
                            Text("Edit")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { deleteHabit() }) {
                        VStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.title3)
                            Text("Delete")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { /* Share action */ }) {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("Share")
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(colors.onBackground)
                .padding(.bottom)
            }
            .padding()
            .background(colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .padding(30)
        }
        .sheet(isPresented: $showingEditSheet) {
            NewHabitView(editingHabit: habit)
        }
        .fullScreenCover(isPresented: $showingCalendar) {
            CompletionCalendarView(habit: habit)
                .presentationBackground(.clear)
        }
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        try? modelContext.save()
        dismiss()
    }
}
