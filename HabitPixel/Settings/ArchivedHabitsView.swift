import SwiftUI
import SwiftData

struct ArchivedHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ArchivedHabitsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ArchivedHabitsViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        Group {
            if viewModel.archivedHabits.isEmpty {
                ContentUnavailableView(
                    "No Archived Habits",
                    systemImage: "archivebox",
                    description: Text("Habits you archive will appear here")
                )
            } else {
                List {
                    ForEach(viewModel.archivedHabits, id: \.self) { habit in
                        ArchivedHabitRow(habit: habit, viewModel: viewModel)
                    }
                }
            }
        }
        .navigationTitle("Archive")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
    }
}

struct ArchivedHabitRow: View {
    let habit: HabitEntity
    let viewModel: ArchivedHabitsViewModel
    @State private var showUnarchiveAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.iconName)
                .foregroundStyle(habit.color)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                
                if let archivedDate = habit.archivedDate {
                    Text("Archived \(archivedDate.formatted(Date.RelativeFormatStyle(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                showUnarchiveAlert = true
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(habit.color)
                    .font(.title2)
            }
        }
        .alert("Unarchive Habit?", isPresented: $showUnarchiveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Unarchive") {
                withAnimation {
                    viewModel.unarchiveHabit(habit)
                }
            }
        } message: {
            Text("This habit will be restored to your active habits.")
        }
        .swipeActions(edge: .leading) {
            Button {
                withAnimation {
                    viewModel.unarchiveHabit(habit)
                }
            } label: {
                Label("Unarchive", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation {
                    viewModel.deleteHabit(habit)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
