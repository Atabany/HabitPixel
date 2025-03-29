import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let habit: HabitEntity
    @State private var showingCalendar = false
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    

    private func archiveHabit() {
        habit.isArchived = true
        habit.archivedDate = Date()
        dismiss()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            let colors = AppColors.currentColorScheme
            
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                
                VStack(spacing: 20) {
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
                    }
                    .padding(.top)
                    
                    HabitActivityGrid(habit: habit)
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 35) {
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
                        
                        VStack {
                            Text("Streak")
                                .font(.subheadline)
                                .foregroundColor(colors.onBackground)
                            Text("\(habit.currentStreak(from: Date()))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(habit.color)
                        }
                        
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
                    .padding(.bottom, 8)
                    
                    HStack(spacing: 24) {
                        Button(action: { showingCalendar = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "calendar")
                                Text("Calendar")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: { showingEdit = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "square.and.pencil")
                                Text("Edit")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Delete")
                                    .font(.caption)
                            }
                        }
                    }
                    .foregroundColor(colors.onBackground)
                    
                    Button(role: .destructive, action: archiveHabit) {
                        HStack {
                            Image(systemName: "archivebox.fill")
                            Text("Archive Habit")
                        }
                    }
                }
                .padding()
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CompletionCalendarView(habit: habit)
        }
        .sheet(isPresented: $showingEdit) {
            NewHabitView(editingHabit: habit)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
}
