import SwiftUI

struct UnlockProView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
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
                    // Header with Lottie animation
                    VStack(spacing: 8) {
                        LottieView(filename: colorScheme == .dark ? "upgrade-pro-dark" : "upgrade-pro-light")
                            .frame(width: 120, height: 120)
                        Text("Unlock HabitRix Pro")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Upgrade for the ultimate habit experience!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                    
                    // Pricing Plans
                    VStack(spacing: 16) {
                        planButton(
                            plan: .monthly,
                            title: "Monthly",
                            price: monthlyPrice
                        )
                        ZStack(alignment: .topTrailing) {
                            planButton(
                                plan: .annual,
                                title: "Annual",
                                price: annualPrice,
                                savings: "-50%",
                                originalPrice: "95.88"
                            )
                            if selectedPlan == .annual {
                                Text("Most Popular")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .offset(x: -12, y: -12)
                            }
                        }
                        planButton(
                            plan: .lifetime,
                            title: "Lifetime",
                            price: lifetimePrice,
                            subtitle: "Pay once. Unlimited access forever."
                        )
                    }
                    .padding(.vertical)
                    
                    // Secure purchase badge
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)
                        Text("Secure purchase. Cancel anytime.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
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
                    .background(Color.theme.surface.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    // Continue Button
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
                            .shadow(color: Color.theme.primary.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    // Restore Button
                    Button(action: {
                        // TODO: Handle restore purchase
                    }) {
                        Text("Already subscribed? Restore purchase")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.primary)
                    }
                    .padding(.bottom, 4)
                    
                    // Legal links and disclaimer
                    VStack(spacing: 8) {
                        HStack(spacing: 16) {
                            Button(action: {
                                if let url = URL(string: "https://tamtom.github.io/habitrixpolicy.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Privacy Policy")
                                    .font(.footnote)
                                    .underline()
                                    .foregroundColor(.gray)
                            }
                            Button(action: {
                                if let url = URL(string: "https://tamtom.github.io/habitrixterms.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Terms of Use")
                                    .font(.footnote)
                                    .underline()
                                    .foregroundColor(.gray)
                            }
                        }
                        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription in your App Store account settings after purchase.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .padding(.top, 8)
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
