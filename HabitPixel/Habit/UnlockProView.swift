import SwiftUI

struct UnlockProView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let monthlyPrice = "AED 7.99"
    private let annualPrice = "AED 49.99"
    private let lifetimePrice = "AED 119.99"
    
    @State private var selectedPlan: PricingPlan = .annual
    
    enum PricingPlan {
        case monthly, annual, lifetime
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Unlock HabitRix Pro")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Pricing Plans
                    VStack(spacing: 16) {
                        // Monthly Plan
                        planButton(
                            plan: .monthly,
                            title: "Monthly",
                            price: monthlyPrice
                        )
                        
                        // Annual Plan (Best Value)
                        planButton(
                            plan: .annual,
                            title: "Annual",
                            price: annualPrice,
                            savings: "-50%",
                            originalPrice: "95.88"
                        )
                        
                        // Lifetime Plan
                        planButton(
                            plan: .lifetime,
                            title: "Lifetime",
                            price: lifetimePrice,
                            subtitle: "Pay once. Unlimited access forever."
                        )
                    }
                    .padding(.vertical)
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 20) {
                        Text("By subscribing you'll also unlock:")
                            .font(.headline)
                        
                        featureRow(
                            icon: "number",
                            color: .green,
                            title: "Unlimited number of habits",
                            description: "Unlimited possibilities by creating as many habits as you like"
                        )
                        
                        featureRow(
                            icon: "chart.bar",
                            color: .orange,
                            title: "Charts & Statistics",
                            description: "See charts and statistics about your consistency"
                        )
                        
                        featureRow(
                            icon: "square.grid.2x2",
                            color: .blue,
                            title: "Home Screen Widgets",
                            description: "Show your favorite habits on your home screen"
                        )
                        
                        featureRow(
                            icon: "rectangle.grid.2x2",
                            color: .teal,
                            title: "Dashboard Customization",
                            description: "Show streaks and goals, show labels and categories"
                        )
                        
                        featureRow(
                            icon: "square.and.arrow.up",
                            color: .purple,
                            title: "Export your data",
                            description: "Generate a file from your habits and completions"
                        )
                    }
                    .padding()
                    
                    Button(action: {
                        // TODO: Handle purchase
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // TODO: Handle restore purchase
                    }) {
                        Text("Already subscribed? Restore purchase")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.primary)
                    }
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.theme.onBackground)
                }
            )
        }
    }
    
    private func planButton(
        plan: PricingPlan,
        title: String,
        price: String,
        savings: String? = nil,
        originalPrice: String? = nil,
        subtitle: String? = nil
    ) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if let savings = savings {
                            Text(savings)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    if let originalPrice = originalPrice {
                        Text(originalPrice)
                            .strikethrough()
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Text(price)
                    .font(.headline)
            }
            .padding()
            .background(
                selectedPlan == plan
                    ? Color.theme.primary.opacity(0.1)
                    : Color.theme.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedPlan == plan ? Color.theme.primary : Color.gray.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
