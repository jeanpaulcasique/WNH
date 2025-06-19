// MARK: - SubscriptionView.swift - Solo correcciones necesarias
import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showDowngradeAlert = false
    @State private var selectedPlanForDowngrade: SubscriptionPlan?
    
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
        .alert("Confirm Downgrade", isPresented: $showDowngradeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Downgrade", role: .destructive) {
                handleDowngrade()
            }
        } message: {
            Text("Are you sure you want to downgrade to the free plan? You will lose access to premium features when your current subscription expires.")
        }
        .overlay(
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
    
    private func handleDowngrade() {
        guard let plan = selectedPlanForDowngrade else { return }
        viewModel.selectedPlan = plan
        viewModel.updateSubscriptionToFree()
        viewModel.loadSubscriptionData()
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
                    Text(viewModel.subscriptionManager.currentStatus.tier.rawValue.capitalized)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appWhite)
                    
                    if viewModel.subscriptionManager.currentStatus.isActive {
                        Text("Active until \(viewModel.subscriptionManager.currentStatus.expirationDate, style: .date)")
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
                    .fill(viewModel.subscriptionManager.currentStatus.isActive ? .green : .gray)
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
                    isCurrentPlan: viewModel.subscriptionManager.currentStatus.tier.rawValue == plan.id
                ) {
                    handlePlanSelection(plan)
                }
            }
            
            if let selectedPlan = viewModel.selectedPlan,
               selectedPlan.id != viewModel.subscriptionManager.currentStatus.tier.rawValue,
               selectedPlan.id != "free" {
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
                ForEach(viewModel.premiumFeatures) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
    
    private func handlePlanSelection(_ plan: SubscriptionPlan) {
        if viewModel.subscriptionManager.currentStatus.tier == .free {
            viewModel.selectedPlan = plan
        } else if plan.id == "free" {
            selectedPlanForDowngrade = plan
            showDowngradeAlert = true
        } else {
            viewModel.selectedPlan = plan
        }
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
