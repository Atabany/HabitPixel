//
//  OnboardingView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ViewModifier {    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.theme.primary)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct OnboardingContainerView: View {
    @AppStorage(StorageConstants.hasSeenOnboarding) private var hasSeenOnboarding = false
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            } else {
                HabitKitView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: hasSeenOnboarding)
    }
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.theme.background.edgesIgnoringSafeArea(.all)
            VStack {
                welcomeHeader()
                
                Spacer().frame(height: 30)
                
                featureList()
                
                continueButton()
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func welcomeHeader() -> some View {
        VStack {
            Text("Welcome to")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.onBackground)
            Text("HabitPixel")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.primary)
        }
    }
    
    private func featureList() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    FeatureRow(
                        icon: "square.grid.2x2.fill",
                        color: Color.theme.primary,
                        title: "Build new habits",
                        description: "Create your habits and track your progress"
                    )
                    FeatureRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        title: "Check it off",
                        description: "Mark when you completed your habits"
                    )
                    FeatureRow(
                        icon: "square.grid.3x3.fill",
                        color: .blue,
                        title: "See the big picture",
                        description: "Get your completions visualized in a cool tile grid"
                    )
                    FeatureRow(
                        icon: "flame.fill",
                        color: .red,
                        title: "Get motivation from streaks",
                        description: "The streak count displays how consistent you are"
                    )
                    FeatureRow(
                        icon: "clock.fill",
                        color: .teal,
                        title: "Don't miss a completion",
                        description: "Get notifications at the specified times"
                    )
                    FeatureRow(
                        icon: "gearshape.fill",
                        color: .green,
                        title: "Build your dashboard",
                        description: "Choose from different colors, icons and themes"
                    )
                    FeatureRow(
                        icon: "calendar",
                        color: .blue,
                        title: "Search through your history",
                        description: "See past completions and edit them"
                    )
                    FeatureRow(
                        icon: "square.and.arrow.up",
                        color: .green,
                        title: "Share your progress",
                        description: "Generate a cool image to share your consistency"
                    )
                    FeatureRow(
                        icon: "square.grid.2x2",
                        color: Color.theme.primary,
                        title: "Home Screen Widgets",
                        description: "Show your favorite habits on your home screen"
                    )
                    FeatureRow(
                        icon: "lock.fill",
                        color: Color.theme.primary,
                        title: "Preserve your privacy",
                        description: "Your data will never leave your phone"
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func continueButton() -> some View {
        Button(action: {
            hasSeenOnboarding = true
        }) {
            Text("Continue")
                .modifier(PrimaryButtonStyle())
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.theme.onBackground)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.caption)
            }
        }
    }
}
