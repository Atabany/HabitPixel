//
//  UpgradeOverlayView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 13/05/2025.
//
import SwiftUI

struct UpgradeOverlayView: View {
    let colors: ColorScheme
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.background.opacity(0.05))

            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(colors.primary)
                        
                        Text("Track More Habits")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(colors.onBackground)
                        
                        Text("Upgrade to Pro to add widgets for all your habits")
                            .font(.system(size: 13))
                            .foregroundColor(colors.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                )
        }
    }
}
