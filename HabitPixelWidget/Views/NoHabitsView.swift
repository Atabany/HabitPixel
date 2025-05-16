//
//  NoHabitsView.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 13/05/2025.
//
import SwiftUI

struct NoHabitsView: View {
    let colors: ColorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 24))
                .foregroundColor(colors.primary)
            
            Text("No Habits Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(colors.onBackground)
                .multilineTextAlignment(.center)
            
            Text("Add habits in the app")
                .font(.system(size: 12))
                .foregroundColor(colors.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}
