import SwiftUI

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: HabitEntity
    let onComplete: () -> Void
    let isCompleted: Bool
    @State private var showingDetail = false
    @State private var showingShareView = false
    @State private var isAnimating = false
    @Environment(\.displayScale) private var displayScale
    
    var body: some View {
        Button(action: { showingDetail = true }) {
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
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            showingShareView = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color.theme.onBackground)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isAnimating = true
                                onComplete()
                            }
                            // Reset animation after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isAnimating = false
                                }
                            }
                        }) {
                            ZStack {
                                // Background circle with gradient
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                isCompleted ? habit.color : habit.color.opacity(0.1),
                                                isCompleted ? habit.color.opacity(0.8) : habit.color.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                
                                // Inner circle for depth
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                isCompleted ? .white.opacity(0.2) : .clear,
                                                isCompleted ? .white.opacity(0.1) : .clear
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                
                                // Checkmark with shadow
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isCompleted ? .white : habit.color)
                                    .shadow(color: isCompleted ? .black.opacity(0.2) : .clear, radius: 2, x: 0, y: 1)
                                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            }
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .shadow(color: isCompleted ? habit.color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        }
                    }
                }
                
                // Activity grid
                HabitActivityGrid(habit: habit)
                
                // Stats row
                HStack(spacing: 25) {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.caption2)
                            Text(habit.frequency)
                                .font(.caption)
                        }
                        .foregroundColor(Color.theme.caption)
                        HStack(spacing: 4) {
                            Text("\(habit.getCompletionsInCurrentInterval())")
                            Text("/")
                            Text("\(habit.goal)")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.onBackground)
                    }
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("Streak")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        Text("\(habit.currentStreak())")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "hourglass")
                                .font(.caption2)
                            Text("Remaining")
                                .font(.caption)
                        }
                        .foregroundColor(Color.theme.caption)
                        Text("\(habit.getRemainingForCurrentInterval())")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.caption)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color.theme.surface)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingDetail) {
            HabitDetailView(habit: habit)
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $showingShareView) {
            ShareHabitView(habit: habit)
        }
    }
    
    private func renderShareImage() -> UIImage {
        let renderer = ImageRenderer(content: ShareHabitCardView(habit: habit))
        renderer.scale = displayScale
        
        // Configure renderer props
        renderer.proposedSize = ProposedViewSize(width: UIScreen.main.bounds.width - 32, height: nil)
        
        // Create the image
        return renderer.uiImage ?? UIImage()
    }
    
    private func shareHabit() {
        showingShareView = true
    }
} 