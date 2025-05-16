//
//  MediumWidgetView.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 13/05/2025.
//

import SwiftUI

struct MediumWidgetView: View {
    let entry: HabitEntry
    let colors: ColorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                colors.background
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: entry.habit.iconName)
                            .font(.system(size: geometry.size.height * 0.13))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.13, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    .padding(.vertical, geometry.size.height * 0.02)
                    .frame(height: geometry.size.height * 0.18)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.97,
                        containerHeight: geometry.size.height * 0.8,
                        isSmallWidget: false
                    )
                    .padding(.horizontal, geometry.size.width * 0.015)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}
