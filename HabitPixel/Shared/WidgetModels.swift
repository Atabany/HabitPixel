import SwiftUI

// Color coding helper
struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(color: Color) {
        let components = color.components()
        red = components.red
        green = components.green
        blue = components.blue
        opacity = components.opacity
    }
    
    var color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: opacity)
    }
}

// Color components helper
extension Color {
    func components() -> (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}

// Shared model for widget data
struct HabitDisplayInfo: Codable {
    let id: String
    let title: String
    let iconName: String
    private let codableColor: CodableColor
    let completedDates: Set<Date>
    let startDate: Date
    let endDate: Date
    var color: Color {
        codableColor.color
    }
    
    init(id: String, title: String, iconName: String, color: Color, completedDates: Set<Date>, startDate: Date, endDate: Date) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.codableColor = CodableColor(color: color)
        self.completedDates = completedDates
        self.startDate = startDate
        self.endDate = endDate
    }
}
