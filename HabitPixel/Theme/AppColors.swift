//
//  with.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

// AppColors struct with light and dark theme colors
struct AppColors {
    // Light Theme Colors
    static let lightPrimary = Color(hex: 0x9233E9)
    static let lightOnPrimary = Color.white
    static let lightBackground = Color(hex: 0xFBFBFB)
    static let lightOnBackground = Color(hex: 0x212121)
    static let lightSurface = Color(hex: 0xFEFEFE)
    static let lightBorder = Color(hex: 0xE4E4E7)
    static let lightCaption = Color(hex: 0x7F7F7F)
    
    // Dark Theme Colors
    static let darkPrimary = Color(hex: 0x9233E9)
    static let darkOnPrimary = Color.white
    static let darkBackground = Color(hex: 0x151518)
    static let darkOnBackground = Color.white
    static let darkSurface = Color(hex: 0x07070B)
    static let darkBorder = Color(hex: 0x27272A)
    static let darkCaption = Color(hex: 0x848485)
}

// Custom ColorScheme struct similar to Material's ColorScheme in Android
struct ColorScheme {
    let primary: Color
    let onPrimary: Color
    let background: Color
    let surface: Color
    let onBackground: Color
    let outline: Color
    
    // Caption color that changes based on theme
    var caption: Color {
        return AppColors.isDarkMode ? AppColors.darkCaption : AppColors.lightCaption
    }
}

// Extension to match Android's ColorScheme.onSurface property
extension ColorScheme {
    var onSurface: Color {
        return onBackground // In your Android code, onSurface isn't explicitly defined
    }
}

// Color schemes that match Android's lightColorScheme and darkColorScheme
extension AppColors {
    static var lightColorScheme: ColorScheme {
        return ColorScheme(
            primary: lightPrimary,
            onPrimary: lightOnPrimary,
            background: lightBackground,
            surface: lightSurface,
            onBackground: lightOnBackground,
            outline: lightBorder
        )
    }
    
    static var darkColorScheme: ColorScheme {
        return ColorScheme(
            primary: darkPrimary,
            onPrimary: darkOnPrimary,
            background: darkBackground,
            surface: darkSurface,
            onBackground: darkOnBackground,
            outline: darkBorder
        )
    }
    
    static var currentColorScheme: ColorScheme {
        return isDarkMode ? darkColorScheme : lightColorScheme
    }
    
    // Helper to determine dark mode status
    static var isDarkMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}

// Helper extension to create colors from hex values
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
