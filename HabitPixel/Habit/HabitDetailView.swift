import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let habit: HabitEntity
    @State private var showingCalendar = false
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingArchiveAlert = false
    @State private var showingShareSheet = false
    
    private func archiveHabit() {
        withAnimation {
            habit.isArchived = true
            habit.archivedDate = Date()
            try? modelContext.save()
            dismiss()
        }
    }
    
    var body: some View {
        Group {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
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
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color.theme.onBackground)
                            }
                            
                            Button(action: { showingEdit = true }) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(habit.color)
                            }
                        }
                    }
                    .padding(.top)
                    
                    HabitActivityGrid(habit: habit)
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 35) {
                        VStack {
                            Text(habit.frequency)
                                .font(.subheadline)
                                .foregroundColor(Color.theme.onBackground)
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
                                .foregroundColor(Color.theme.onBackground)
                            Text("\(habit.currentStreak(from: Date()))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(habit.color)
                        }
                        
                        VStack {
                            Text("Remaining")
                                .font(.subheadline)
                                .foregroundColor(Color.theme.onBackground)
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
                                    .font(.title3)
                                Text("Calendar")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: { showingArchiveAlert = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "archivebox")
                                    .font(.title3)
                                Text("Archive")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.title3)
                                Text("Delete")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.red)
                    }
                    .foregroundColor(Color.theme.onBackground)
                }
                .padding()
                .background(Color.theme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .padding(.horizontal, 30)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Close")
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CompletionCalendarView(habit: habit)
        }
        .sheet(isPresented: $showingEdit) {
            NewHabitView(editingHabit: habit)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareHabitView(habit: habit)
        }
        .alert("Archive Habit", isPresented: $showingArchiveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Archive") {
                archiveHabit()
            }
        } message: {
            Text("This habit will be moved to archives. You can restore it later.")
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
        .presentationBackground(.clear)
        .presentationCornerRadius(0)
        .interactiveDismissDisabled()
    }
}
