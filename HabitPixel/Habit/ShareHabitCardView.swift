import SwiftUI

// MARK: - Share Habit Card View
struct ShareHabitCardView: View {
    let habit: HabitEntity
    
    var body: some View {
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
                        .foregroundColor(Color.theme.onBackground)
                    if !habit.habitDescription.isEmpty {
                        Text(habit.habitDescription)
                            .font(.caption)
                            .foregroundColor(Color.theme.caption)
                    }
                }
                
                Spacer()
            }
            
            // Activity grid
            HabitActivityGrid(habit: habit)
            
            HStack {
                Text("\(habit.goal) / \(habit.frequency)")
                    .font(.caption)
                    .foregroundColor(Color.theme.caption)
                
                Spacer()
                
                Text("HabitRix")
                    .font(.caption)
                    .foregroundColor(Color.theme.caption)
            }
        }
        .padding(16)
        .background(Color.theme.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
} 