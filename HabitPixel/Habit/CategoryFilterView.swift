import SwiftUI

// MARK: - Category Filter View
struct CategoryFilterView: View {
    @Binding var selectedCategory: Category
    let activeCategories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Always show "All" category
                categoryButton(for: Category.all)
                
                // Show only categories with habits
                ForEach(activeCategories.filter { $0 != .all }) { category in
                    categoryButton(for: category)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func categoryButton(for category: Category) -> some View {
        Button(action: { selectedCategory = category }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.name)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedCategory.id == category.id ? Color.theme.primary.opacity(0.1) : Color.theme.surface)
            .foregroundColor(selectedCategory.id == category.id ? Color.theme.primary : Color.theme.onBackground)
            .clipShape(Capsule())
        }
    }
} 
