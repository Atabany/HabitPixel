//
//  ColorSelectionView.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

struct ColorSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedColor: Color
    
    // Changed from 7 to 5 columns to accommodate larger sizes
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Color.variants, id: \.light) { variant in
                    ColorButton(
                        color: variant.adaptive,
                        selectedColor: selectedColor,
                        isHighlighted: false
                    ) {
                        selectedColor = variant.adaptive
                        dismiss()
                    }
                    .frame(maxWidth: 65, maxHeight: 65) // Limit the tap area
                }
            }
            .padding()
        }
        .background(Color.theme.background)
        .navigationTitle("Select Color")
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}
