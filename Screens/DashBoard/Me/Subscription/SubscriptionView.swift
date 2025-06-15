import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    currentPlanSection
                    subscriptionPlansSection
                    featuresSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.appWhite)
        .onAppear {
            viewModel.loadSubscriptionData()
        }
        .alert("Subscription", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .overlay(
            // Loading overlay
            Group {
                if viewModel.isLoading {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .appYellow))
                        .scaleEffect(1.5)
                }
            }
        )
    }
}

// MARK: - Subviews
private extension SubscriptionView {
    
    var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.appYellow)
            
            Text("Unlock Premium Features")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
            Text("Get unlimited access to all features and premium content")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    var currentPlanSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Current Plan")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentPlan.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appWhite)
                    
                    if viewModel.currentPlan.isActive {
                        Text("Active until \(viewModel.currentPlan.expirationDate, style: .date)")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    } else {
                        Text("Free Plan")
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.6))
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(viewModel.currentPlan.isActive ? .green : .gray)
                    .frame(width: 12, height: 12)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    var subscriptionPlansSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Choose Your Plan")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            ForEach(viewModel.availablePlans) { plan in
                SubscriptionPlanCard(
                    plan: plan,
                    isSelected: viewModel.selectedPlan?.id == plan.id,
                    isCurrentPlan: viewModel.currentPlan.id == plan.id
                ) {
                    viewModel.selectPlan(plan)
                }
            }
            
            if let selectedPlan = viewModel.selectedPlan, selectedPlan.id != viewModel.currentPlan.id {
                Button(action: {
                    viewModel.purchaseSelectedPlan()
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            Text("Subscribe to \(selectedPlan.name)")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appYellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    var featuresSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Premium Features")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.premiumFeatures, id: \.title) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
}

// MARK: - SubscriptionPlanCard
struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isCurrentPlan: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(plan.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appWhite)
                            
                            if plan.isPopular {
                                Text("POPULAR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.appYellow)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                        
                        Text(plan.description)
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if isCurrentPlan {
                            Text("CURRENT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        } else {
                            Text(plan.priceText)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            if !plan.periodText.isEmpty {
                                Text(plan.periodText)
                                    .font(.system(size: 12))
                                    .foregroundColor(.appWhite.opacity(0.6))
                            }
                        }
                    }
                }
                
                if plan.savings > 0 {
                    HStack {
                        Text("Save \(plan.savings)%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.appYellow :
                                isCurrentPlan ? Color.green : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FeatureCard
struct FeatureCard: View {
    let feature: PremiumFeature
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: 32))
                .foregroundColor(.appYellow)
            
            Text(feature.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
            
            Text(feature.description)
                .font(.system(size: 12))
                .foregroundColor(.appWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionView()
        }
        .preferredColorScheme(.dark)
    }
}
