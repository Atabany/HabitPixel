import SwiftUI

struct IconSelectionView: View {
    @Binding var selectedIcon: String
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    let themeColors = AppColors.currentColorScheme
    
    private let categories = [
        "All",
        "Health",
        "Learning",
        "Lifestyle",
        "Tech",
        "Nature",
        "Finance"
    ]
    
    private let icons = [
        // Health icons
        ("Health", ["heart", "figure.run", "figure.walk", "heart.fill", "lungs", "pills", "cross", "bed.double", "brain"]),
        // Learning icons
        ("Learning", ["book", "pencil", "graduationcap", "books.vertical", "book.closed", "book.closed.fill", "bookmark"]),
        // Lifestyle icons
        ("Lifestyle", ["cup.and.saucer", "fork.knife", "shower", "house", "car", "bicycle", "airplane"]),
        // Tech icons
        ("Tech", ["macbook", "desktopcomputer", "gamecontroller", "keyboard", "tv", "headphones", "iphone"]),
        // Nature icons
        ("Nature", ["leaf", "drop", "flame", "sun.max", "moon", "cloud", "snowflake"]),
        // Finance icons
        ("Finance", ["dollarsign.circle", "creditcard", "cart", "bag", "gift", "wallet.pass", "banknote"])
    ]
    
    var filteredIcons: [String] {
        let allIcons = icons.flatMap { $0.1 }
        let categoryIcons = selectedCategory == "All"
            ? allIcons
            : icons.first(where: { $0.0 == selectedCategory })?.1 ?? []
        
        if searchText.isEmpty {
            return categoryIcons
        }
        return categoryIcons.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeColors.caption)
                TextField("Search icons", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeColors.caption)
                    }
                }
            }
            .padding(12)
            .background(themeColors.surface)
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: { selectedCategory = category }) {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? themeColors.primary : themeColors.surface)
                                .foregroundColor(selectedCategory == category ? themeColors.onPrimary : themeColors.onBackground)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Icons grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                    ForEach(filteredIcons, id: \.self) { icon in
                        Button(action: { selectedIcon = icon }) {
                            VStack {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 60, height: 60)
                                    .background(selectedIcon == icon ? themeColors.primary : themeColors.surface)
                                    .foregroundColor(selectedIcon == icon ? themeColors.onPrimary : themeColors.onBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeColors.primary, lineWidth: selectedIcon == icon ? 0 : 1)
                                    )
                                
                                Text(icon.replacingOccurrences(of: ".", with: " "))
                                    .font(.caption2)
                                    .foregroundColor(themeColors.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(themeColors.background)
        .navigationTitle("Select Icon")
    }
}

struct SearchBar: View {
    @Binding var text: String
    let themeColors = AppColors.currentColorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeColors.onSurface)
            
            TextField("Search icons", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeColors.onSurface)
                }
            }
        }
        .padding(10)
        .background(themeColors.surface)
        .cornerRadius(10)
    }
}
