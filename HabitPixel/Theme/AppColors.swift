//
//  with.swift
//  HabitPixel
//
//  Created by Mohamed Elatabany on 22/03/2025.
//

import SwiftUI

// MARK: - Theme Colors
extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let primary = Color(hex: 0x9233E9)
    let background = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(hex: 0x151518)
        default: return UIColor(hex: 0xFBFBFB)
        }
    })
    
    let surface = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(hex: 0x07070B)
        default: return UIColor(hex: 0xFEFEFE)
        }
    })
    
    let onBackground = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return .white
        default: return UIColor(hex: 0x212121)
        }
    })
    
    let border = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(hex: 0x27272A)
        default: return UIColor(hex: 0xE4E4E7)
        }
    })
    
    let caption = Color(uiColor: UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark: return UIColor(hex: 0x848485)
        default: return UIColor(hex: 0x7F7F7F)
        }
    })
}

// MARK: - Color Variants
extension Color {
    static let variants: [ColorVariant] = [
        // Reds
        ColorVariant(light: Color(hex: 0xFF6B6B), dark: Color(hex: 0xFF5252)),
        ColorVariant(light: Color(hex: 0xFF8787), dark: Color(hex: 0xFF7373)),
        ColorVariant(light: Color(hex: 0xFFA5A5), dark: Color(hex: 0xFF9191)),
        ColorVariant(light: Color(hex: 0xFFCCCC), dark: Color(hex: 0xFFB8B8)),
        ColorVariant(light: Color(hex: 0xFF4444), dark: Color(hex: 0xE53935)),
        
        // Pinks
        ColorVariant(light: Color(hex: 0xFF7EB6), dark: Color(hex: 0xFF69B4)),
        ColorVariant(light: Color(hex: 0xFF9ECA), dark: Color(hex: 0xFF89C8)),
        ColorVariant(light: Color(hex: 0xFFBEDE), dark: Color(hex: 0xFFA9DC)),
        ColorVariant(light: Color(hex: 0xFF5E9D), dark: Color(hex: 0xFF499A)),
        ColorVariant(light: Color(hex: 0xFF3E83), dark: Color(hex: 0xFF2976)),
        
        // Oranges
        ColorVariant(light: Color(hex: 0xFFA940), dark: Color(hex: 0xFF9431)),
        ColorVariant(light: Color(hex: 0xFFBB6B), dark: Color(hex: 0xFFA75C)),
        ColorVariant(light: Color(hex: 0xFFCC99), dark: Color(hex: 0xFFB77F)),
        ColorVariant(light: Color(hex: 0xFF8833), dark: Color(hex: 0xFF7722)),
        ColorVariant(light: Color(hex: 0xFF6611), dark: Color(hex: 0xFF5500)),
        
        // Yellows
        ColorVariant(light: Color(hex: 0xFFD43B), dark: Color(hex: 0xFFC72C)),
        ColorVariant(light: Color(hex: 0xFFE066), dark: Color(hex: 0xFFD54F)),
        ColorVariant(light: Color(hex: 0xFFED8C), dark: Color(hex: 0xFFE476)),
        ColorVariant(light: Color(hex: 0xFFC61A), dark: Color(hex: 0xFFB700)),
        ColorVariant(light: Color(hex: 0xFFAB00), dark: Color(hex: 0xFF9900)),
        
        // Greens
        ColorVariant(light: Color(hex: 0x69DB7C), dark: Color(hex: 0x51CF66)),
        ColorVariant(light: Color(hex: 0x8CE99A), dark: Color(hex: 0x69DB7C)),
        ColorVariant(light: Color(hex: 0xB2F2BB), dark: Color(hex: 0x94E9A2)),
        ColorVariant(light: Color(hex: 0x40C057), dark: Color(hex: 0x37B24D)),
        ColorVariant(light: Color(hex: 0x2F9E44), dark: Color(hex: 0x2B8A3E)),
        
        // Teals
        ColorVariant(light: Color(hex: 0x20C997), dark: Color(hex: 0x12B886)),
        ColorVariant(light: Color(hex: 0x3DD5B0), dark: Color(hex: 0x25CAA0)),
        ColorVariant(light: Color(hex: 0x63E6BE), dark: Color(hex: 0x4DDCB4)),
        ColorVariant(light: Color(hex: 0x0CA678), dark: Color(hex: 0x099268)),
        ColorVariant(light: Color(hex: 0x087F5B), dark: Color(hex: 0x066649)),
        
        // Cyans
        ColorVariant(light: Color(hex: 0x15AABF), dark: Color(hex: 0x1098AD)),
        ColorVariant(light: Color(hex: 0x22B8CF), dark: Color(hex: 0x1CA7BE)),
        ColorVariant(light: Color(hex: 0x3BC9DB), dark: Color(hex: 0x28B8CD)),
        ColorVariant(light: Color(hex: 0x0C8599), dark: Color(hex: 0x0B7285)),
        ColorVariant(light: Color(hex: 0x0B7285), dark: Color(hex: 0x095C6B)),
        
        // Blues
        ColorVariant(light: Color(hex: 0x4DABF7), dark: Color(hex: 0x339AF0)),
        ColorVariant(light: Color(hex: 0x74C0FC), dark: Color(hex: 0x4DABF7)),
        ColorVariant(light: Color(hex: 0xA5D8FF), dark: Color(hex: 0x8BC4F9)),
        ColorVariant(light: Color(hex: 0x228BE6), dark: Color(hex: 0x1C7ED6)),
        ColorVariant(light: Color(hex: 0x1971C2), dark: Color(hex: 0x1864AB)),
        
        // Indigos
        ColorVariant(light: Color(hex: 0x5C7CFA), dark: Color(hex: 0x4C6EF5)),
        ColorVariant(light: Color(hex: 0x748FFC), dark: Color(hex: 0x6482FA)),
        ColorVariant(light: Color(hex: 0x91A7FF), dark: Color(hex: 0x849AF9)),
        ColorVariant(light: Color(hex: 0x4263EB), dark: Color(hex: 0x3B5BDB)),
        ColorVariant(light: Color(hex: 0x3B5BDB), dark: Color(hex: 0x364FC7)),
        
        // Purples
        ColorVariant(light: Color(hex: 0x9775FA), dark: Color(hex: 0x845EF7)),
        ColorVariant(light: Color(hex: 0xB197FC), dark: Color(hex: 0x9775FA)),
        ColorVariant(light: Color(hex: 0xCDB9FC), dark: Color(hex: 0xB9A0FA)),
        ColorVariant(light: Color(hex: 0x7950F2), dark: Color(hex: 0x6741D9)),
        ColorVariant(light: Color(hex: 0x6741D9), dark: Color(hex: 0x5F3DC4))
    ]
}

struct ColorVariant {
    let light: Color
    let dark: Color
    
    var adaptive: Color {
        Color(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark: return UIColor(dark)
            default: return UIColor(light)
            }
        })
    }
}

// MARK: - Helpers
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

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
