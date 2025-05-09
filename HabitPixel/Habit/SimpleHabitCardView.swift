import SwiftUI

struct SimpleHabitCardView: View {
    let habit: HabitEntity
    let onComplete: () -> Void
    let isCompleted: Bool
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and completion button
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: habit.iconName)
                            .font(.title2)
                            .frame(width: 36, height: 36)
                            .background(habit.color.opacity(0.1))
                            .foregroundColor(habit.color)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(habit.title)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color.theme.onBackground)
                            .lineLimit(1)
                    }
                    
                    Spacer(minLength: 8)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            onComplete()
                        }
                    }) {
                        Circle()
                            .fill(isCompleted ? habit.color : habit.color.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isCompleted ? .white : habit.color)
                            )
                    }
                }
                
                // Activity grid
                HabitActivityGrid(habit: habit, overrideColor: nil)
            }
            .padding(12)
            .background(Color.theme.surface)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            HabitDetailView(habit: habit)
                .presentationBackground(.clear)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
