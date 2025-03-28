//
//  ColorSelectionView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//


import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColor: Color
    let themeColors = AppColors.currentColorScheme
    
    // Extended color palette
    private let colors: [Color] = [
        // Reds
        Color(hex: 0xFF0000), // Red
        Color(hex: 0xFF4500), // Orange Red
        Color(hex: 0xDC143C), // Crimson
        Color(hex: 0xB22222), // Fire Brick
        
        // Oranges
        Color(hex: 0xFFA500), // Orange
        Color(hex: 0xFF8C00), // Dark Orange
        Color(hex: 0xFFA07A), // Light Salmon
        Color(hex: 0xFFC0CB), // Light Coral
        
        // Yellows
        Color(hex: 0xFFFF00), // Yellow
        Color(hex: 0xFFFFE0), // Light Yellow
        Color(hex: 0xF7DC6F), // Golden Rod
        Color(hex: 0xDAA520),  // Golden Brown
        
        // Greens
        Color(hex: 0x00FF00), // Green
        Color(hex: 0x00FA9A), // Medium Spring Green
        Color(hex: 0x00FFFF), // Cyan
        Color(hex: 0x008000),  // Green
        
        // Blues
        Color(hex: 0x0000FF), // Blue
        Color(hex: 0x1E90FF), // Dodger Blue
        Color(hex: 0x00008B), // Dark Blue
        Color(hex: 0x6495ED),  // Corn Flower Blue
        
        // Purples
        Color(hex: 0x800080), // Purple
        Color(hex: 0x4B0082), // Indigo
        Color(hex: 0x800000), // Maroon
        Color(hex: 0x663399),  // Rebecca Purple
        
        // Pastels
        Color(hex: 0xFFB6C1), // Light Pink
        Color(hex: 0x98FB98), // Pale Green
        Color(hex: 0x87CEFA), // Light Sky Blue
        Color(hex: 0xDDA0DD),  // Plum
        
        // Deep Colors
        Color(hex: 0x006400), // Dark Green
        Color(hex: 0x000080), // Navy
        Color(hex: 0x4B0082), // Indigo
        Color(hex: 0x800080)  // Purple
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: { selectedColor = color }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                                
                                if selectedColor == color {
                                    Circle()
                                        .stroke(themeColors.onBackground, lineWidth: 2)
                                        .frame(width: 66, height: 66)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(themeColors.background)
        .navigationTitle("Select Color")
    }
}
