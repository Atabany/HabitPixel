//
//  SmallWidgetView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 13/05/2025.
//

import SwiftUI

struct SmallWidgetView: View {
    let entry: HabitEntry
    let colors: ColorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                colors.background
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Image(systemName: entry.habit.iconName)
                            .font(.system(size: geometry.size.height * 0.12))
                            .foregroundColor(entry.habit.color)
                        Text(entry.habit.title)
                            .font(.system(size: geometry.size.height * 0.12, weight: .medium))
                            .foregroundColor(colors.onBackground)
                            .lineLimit(1)
                    }
                    .frame(height: geometry.size.height * 0.18)
                    .padding(.top, 4)
                    ActivityGridView(
                        habit: entry.habit,
                        colors: colors,
                        containerWidth: geometry.size.width * 0.98,
                        containerHeight: geometry.size.height * 0.78,
                        isSmallWidget: true
                    )
                    .padding(.horizontal, 2)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
        }
    }
}
