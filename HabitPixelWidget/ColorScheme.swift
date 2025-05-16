//
//  ColorScheme.swift
//  HabitRix
//
//  Created by Mohamed Elatabany on 13/05/2025.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

struct ColorScheme {
    let systemScheme: SwiftUI.ColorScheme

    private let lightPrimary: Color = Color(hex: 0xFF6B6B)
    private let lightOnPrimary: Color = .white
    private let lightBackground: Color = Color(hex: 0xF2F2F7)
    private let lightSurface: Color = .white
    private let lightOnBackground: Color = .black
    private let lightOutline: Color = Color(hex: 0xD1D1D6)
    private let lightCaption: Color = Color(hex: 0x8E8E93)

    private let darkPrimary: Color = Color(hex: 0xFF6B6B)
    private let darkOnPrimary: Color = .white
    private let darkBackground: Color = .black
    private let darkSurface: Color = Color(hex: 0x1C1C1E)
    private let darkOnBackground: Color = .white
    private let darkOutline: Color = Color(hex: 0x3C3C3E)
    private let darkCaption: Color = Color(hex: 0x848485)

    var primary: Color { systemScheme == .light ? lightPrimary : darkPrimary }
    var onPrimary: Color { systemScheme == .light ? lightOnPrimary : darkOnPrimary }
    var background: Color { systemScheme == .light ? lightBackground : darkBackground }
    var surface: Color { systemScheme == .light ? lightSurface : darkSurface }
    var onBackground: Color { systemScheme == .light ? lightOnBackground : darkOnBackground }
    var outline: Color { systemScheme == .light ? lightOutline : darkOutline }
    var caption: Color { systemScheme == .light ? lightCaption : darkCaption }

    init(systemScheme: SwiftUI.ColorScheme) {
        self.systemScheme = systemScheme
    }
}

