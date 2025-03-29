import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let suggestedIcons: [String]
    
    static let all = Category(name: "All", icon: "square.grid.2x2", suggestedIcons: [])
    
    static let categories: [Category] = [
        all,
        Category(name: "Fitness",
                icon: "figure.walk",
                suggestedIcons: ["figure.walk", "figure.run", "figure.strengthtraining.traditional", "figure.mixed.cardio", "figure.gymnastics", "figure.yoga", "dumbbell", "bicycle"]),
        
        Category(name: "Health",
                icon: "heart",
                suggestedIcons: ["heart", "heart.fill", "lungs", "pills", "cross", "bed.double", "brain", "bandage"]),
        
        Category(name: "Learning",
                icon: "book",
                suggestedIcons: ["book", "pencil", "graduationcap", "books.vertical", "book.closed", "book.closed.fill", "bookmark", "text.book.closed"]),
        
        Category(name: "Mindfulness",
                icon: "brain.head.profile",
                suggestedIcons: ["brain.head.profile", "leaf", "moon", "sun.max", "cloud", "drop", "flame.fill"]),
        
        Category(name: "Productivity",
                icon: "chart.bar",
                suggestedIcons: ["chart.bar", "list.clipboard", "checklist", "doc", "calendar", "clock", "timer", "archivebox"]),
        
        Category(name: "Finance",
                icon: "dollarsign.circle",
                suggestedIcons: ["dollarsign.circle", "creditcard", "cart", "bag", "gift", "wallet.pass", "banknote", "chart.line.uptrend.xyaxis"]),
        
        Category(name: "Social",
                icon: "person.2",
                suggestedIcons: ["person.2", "person.3", "bubble.left", "message", "phone", "envelope", "video", "shareplay"]),
        
        Category(name: "Art",
                icon: "paintbrush",
                suggestedIcons: ["paintbrush", "pencil.line", "guitar", "music.note", "camera", "photo", "movieclapper", "paintpalette"]),
        
        Category(name: "Other",
                icon: "circle.grid.cross",
                suggestedIcons: ["circle.grid.cross", "star", "flag", "gear", "bell", "tag", "hammer", "key"])
    ]
    
    static var allIcons: [String] {
        categories.flatMap { $0.suggestedIcons }
    }
    
    static func category(for icon: String) -> Category? {
        categories.first { $0.suggestedIcons.contains(icon) }
    }
}
