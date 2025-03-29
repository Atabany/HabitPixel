import SwiftUI

struct ArchivedHabitsView: View {
    @StateObject private var viewModel = ArchivedHabitsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.archivedHabits, id: \.self) { habit in
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.title)
                            .font(.headline)
                        Text("Archived on: \(habit.archivedDate?.formatted() ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.unarchiveHabit(habit) }) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Archived Habits")
    }
}
