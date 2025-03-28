//
//  OnboardingView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    let colors: ColorScheme
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(colors.onPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.primary)
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
        let colors = AppColors.currentColorScheme
        
        ZStack {
            colors.background.edgesIgnoringSafeArea(.all)
            VStack {
                welcomeHeader(colors: colors)
                
                Spacer().frame(height: 30)
                
                featureList(colors: colors)
                
                continueButton(colors: colors)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func welcomeHeader(colors: ColorScheme) -> some View {
        VStack {
            Text("Welcome to")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colors.onBackground)
            Text("HabitPixel")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colors.primary)
        }
    }
    
    private func featureList(colors: ColorScheme) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    FeatureRow(
                        icon: "square.grid.2x2.fill",
                        color: AppColors.lightPrimary,
                        title: "Build new habits",
                        description: "Create your habits and track your progress",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        title: "Check it off",
                        description: "Mark when you completed your habits",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "square.grid.3x3.fill",
                        color: .blue,
                        title: "See the big picture",
                        description: "Get your completions visualized in a cool tile grid",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "flame.fill",
                        color: .red,
                        title: "Get motivation from streaks",
                        description: "The streak count displays how consistent you are",
                        titleColor: colors.primary,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "clock.fill",
                        color: .teal,
                        title: "Don't miss a completion",
                        description: "Get notifications at the specified times",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "gearshape.fill",
                        color: .green,
                        title: "Build your dashboard",
                        description: "Choose from different colors, icons and themes",
                        titleColor: .yellow,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "calendar",
                        color: .blue,
                        title: "Search through your history",
                        description: "See past completions and edit them",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "square.and.arrow.up",
                        color: .green,
                        title: "Share your progress",
                        description: "Generate a cool image to share your consistency",
                        titleColor: colors.onBackground,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "square.grid.2x2",
                        color: AppColors.lightPrimary,
                        title: "Home Screen Widgets",
                        description: "Show your favorite habits on your home screen",
                        titleColor: colors.primary,
                        colors: colors
                    )
                    FeatureRow(
                        icon: "lock.fill",
                        color: AppColors.lightPrimary,
                        title: "Preserve your privacy",
                        description: "Your data will never leave your phone",
                        titleColor: colors.primary,
                        colors: colors
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func continueButton(colors: ColorScheme) -> some View {
        Button(action: {
            hasSeenOnboarding = true
        }) {
            Text("Continue")
                .modifier(PrimaryButtonStyle(colors: colors))
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let titleColor: Color
    let colors: ColorScheme
    
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
                    .foregroundColor(titleColor)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(colors.caption)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView(hasSeenOnboarding: .constant(false))
                .preferredColorScheme(.dark)
            OnboardingView(hasSeenOnboarding: .constant(false))
                .preferredColorScheme(.light)
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView()
    }
}
