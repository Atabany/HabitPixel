import SwiftUI
import UIKit

struct IconSelectionView: View {
    @Binding var selectedIcon: String
    @State private var searchText = ""
    @State private var selectedCategory = Category.all
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var filteredIcons: [String] {
        let allIcons = selectedCategory == .all
            ? Category.allIcons
            : selectedCategory.suggestedIcons
            
        if searchText.isEmpty {
            return allIcons
        }
        return allIcons.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    init(selectedIcon: Binding<String>) {
        self._selectedIcon = selectedIcon
        lightHapticGenerator.prepare()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.theme.caption)
                TextField("Search icons", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.caption)
                    }
                }
            }
            .padding(12)
            .background(Color.theme.surface)
            .cornerRadius(12)
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Category.categories) { category in
                        Button(action: {
                            lightHapticGenerator.impactOccurred()
                            selectedCategory = category
                            lightHapticGenerator.prepare()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                Text(category.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory.id == category.id ? Color.theme.primary : Color.theme.surface)
                            .foregroundColor(selectedCategory.id == category.id ? .white : Color.theme.onBackground)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                    ForEach(filteredIcons, id: \.self) { icon in
                        Button(action: {
                            lightHapticGenerator.impactOccurred()
                            selectedIcon = icon
                            lightHapticGenerator.prepare()
                        }) {
                            VStack {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 60, height: 60)
                                    .background(selectedIcon == icon ? Color.theme.primary : Color.theme.surface)
                                    .foregroundColor(selectedIcon == icon ? .white : Color.theme.onBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.theme.primary, lineWidth: selectedIcon == icon ? 0 : 1)
                                    )
                                
                                Text(icon.replacingOccurrences(of: ".", with: " "))
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.theme.background)
        .navigationTitle("Select Icon")
    }
}
