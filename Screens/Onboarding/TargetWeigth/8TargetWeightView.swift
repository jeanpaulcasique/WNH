import SwiftUI

// MARK: - Ultimate TargetWeightView
struct TargetWeightView: View {
    @StateObject var viewModel: TargetWeightViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var navigateToHowOftenView = false
    @State private var showWeightAnimation: Bool = false
    @State private var showComparisonAnimation: Bool = false
    @State private var showInsightsAnimation: Bool = false
    @State private var isDragging = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 28) {
                    progressSection
                    headerSection
                    epicWeightDisplaySection
                    ultimateSliderSection
                    unitSelectorSection
                    smartComparisonSection
                    insightsSection
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            nextButtonOverlay
        }
       
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            setupAnimations()
        }
    }
}

// MARK: - Background & Navigation
private extension TargetWeightView {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var backButton: some View {
        Button(action: {
            progressViewModel.decreaseProgress()
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var nextButtonOverlay: some View {
        VStack {
            Spacer()
            VStack {
                NextButton(
                    title: "Next",
                    action: proceedToNext,
                    isLoading: $viewModel.isLoading,
                    isDisabled: $viewModel.isNextButtonDisabled
                )
                
                NavigationLink(
                    destination: DietTypeView(progressViewModel: progressViewModel),
                    isActive: $navigateToHowOftenView
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding(.horizontal, 0)
            .padding(.bottom, 0)
        }
    }
}

// MARK: - Main Sections
private extension TargetWeightView {
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    var headerSection: some View {
        VStack(spacing: 16) {
            targetIcon
            headerText
        }
        .padding(.top, 15)
    }
    
    var targetIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.green.opacity(0.4), Color.green.opacity(0.1)],
                        center: .center,
                        startRadius: 30,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDragging)
            
            Image(systemName: "target")
                .font(.system(size: 45, weight: .medium))
                .foregroundColor(.green)
                .rotationEffect(.degrees(isDragging ? 360 : 0))
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isDragging)
        }
    }
    
    var headerText: some View {
        VStack(spacing: 12) {
            Text("What's your target weight?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
            Text("Choose a realistic goal that motivates you to stay healthy")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    var epicWeightDisplaySection: some View {
        VStack(spacing: 20) {
            if showWeightAnimation {
                VStack(spacing: 16) {
                    HStack {
                        Text("Your Target")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    EpicWeightDisplay(viewModel: viewModel, isDragging: $isDragging)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var ultimateSliderSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Adjust Your Goal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                Text("40 - 150 kg")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            UltimateWeightSlider(viewModel: viewModel, isDragging: $isDragging)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.4), Color.blue.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
        }
    }
    
    var unitSelectorSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Measurement Unit")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack(spacing: 14) {
                UnitSelectorButton(
                    title: "Kilograms",
                    subtitle: "kg",
                    isSelected: viewModel.isKgSelected,
                    color: .blue,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.toggleUnit(toKg: true)
                        }
                        generateHapticFeedback()
                    }
                )
                
                UnitSelectorButton(
                    title: "Pounds",
                    subtitle: "lb",
                    isSelected: !viewModel.isKgSelected,
                    color: .purple,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.toggleUnit(toKg: false)
                        }
                        generateHapticFeedback()
                    }
                )
            }
        }
    }
    
    var smartComparisonSection: some View {
        VStack(spacing: 16) {
            if showComparisonAnimation {
                VStack(spacing: 12) {
                    HStack {
                        Text("Progress Overview")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    SmartComparisonCard(viewModel: viewModel)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var insightsSection: some View {
        VStack(spacing: 16) {
            if showInsightsAnimation {
                VStack(spacing: 12) {
                    HStack {
                        Text("Health Insights")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    HealthInsightsCard(viewModel: viewModel)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Helper Functions
private extension TargetWeightView {
    func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showWeightAnimation = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showComparisonAnimation = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showInsightsAnimation = true
            }
        }
    }
    
    func proceedToNext() {
        viewModel.isNextButtonDisabled = true
        viewModel.isLoading = true

        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }

        generateHapticFeedback(style: .heavy)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            navigateToHowOftenView = true
        }
    }
    
    func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Epic Weight Display
struct EpicWeightDisplay: View {
    @ObservedObject var viewModel: TargetWeightViewModel
    @Binding var isDragging: Bool
    
    private var formattedWeight: String {
        String(format: "%.1f", viewModel.weightInPreferredUnit)
    }
    
    private var weightUnit: String {
        viewModel.isKgSelected ? "kg" : "lb"
    }
    
    var body: some View {
        ZStack {
            // Background with holographic effect
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.15),
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.5), Color.blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .frame(height: 140)
            
            VStack(spacing: 16) {
                // Main weight display
                HStack(spacing: 8) {
                    Text(formattedWeight)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .scaleEffect(isDragging ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                    
                    Text(weightUnit)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                        .padding(.top, 16)
                }
                
                // Description
                Text("Target Weight Goal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.8))
            }
        }
    }
}

// MARK: - Ultimate Weight Slider
struct UltimateWeightSlider: View {
    @ObservedObject var viewModel: TargetWeightViewModel
    @Binding var isDragging: Bool
    
    private let minWeight: Double = 40
    private let maxWeight: Double = 150
    
    var body: some View {
        VStack(spacing: 20) {
            // Current value indicator
            HStack {
                Text("Slide to adjust")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                
                Spacer()
                
                Text("\(String(format: "%.1f", viewModel.weightInPreferredUnit)) \(viewModel.isKgSelected ? "kg" : "lb")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(8)
            }
            
            // Enhanced slider
            Slider(
                value: Binding(
                    get: { viewModel.selectedWeightKg },
                    set: { newValue in
                        viewModel.updateWeight(newWeight: newValue)
                    }
                ),
                in: minWeight...maxWeight,
                step: 0.5,
                onEditingChanged: { editing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isDragging = editing
                    }
                    
                    if editing {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    } else {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
            ) {
                Text("Target Weight")
            }
            .accentColor(.green)
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            
            // Range indicators
            HStack {
                VStack(spacing: 4) {
                    Text("Min")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.6))
                    Text("\(Int(minWeight)) kg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Healthy Range")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                    Text("50-90 kg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Max")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.6))
                    Text("\(Int(maxWeight)) kg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Unit Selector Button
struct UnitSelectorButtonT: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? color : .appWhite.opacity(0.4))
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .appWhite : .appWhite.opacity(0.7))
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? color : .appWhite.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Smart Comparison Card
struct SmartComparisonCard: View {
    @ObservedObject var viewModel: TargetWeightViewModel
    
    private var currentWeight: Double {
        UserDefaults.standard.double(forKey: "selectedWeightKg")
    }
    
    private var weightDifference: Double {
        abs(currentWeight - viewModel.selectedWeightKg)
    }
    
    private var isWeightLoss: Bool {
        viewModel.selectedWeightKg < currentWeight
    }
    
    private var progressPercentage: Double {
        guard currentWeight > 0 else { return 0 }
        return (weightDifference / currentWeight) * 100
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Visual comparison
            HStack(spacing: 20) {
                // Current weight
                VStack(spacing: 8) {
                    Text("Current")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.7))
                    
                    Text(String(format: "%.1f", currentWeight))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appYellow)
                    
                    Text(viewModel.isKgSelected ? "kg" : "lb")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appYellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Arrow with animation
                VStack {
                    Image(systemName: isWeightLoss ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(isWeightLoss ? .green : .blue)
                    
                    Text(isWeightLoss ? "Lose" : "Gain")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isWeightLoss ? .green : .blue)
                }
                
                // Target weight
                VStack(spacing: 8) {
                    Text("Target")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.7))
                    
                    Text(String(format: "%.1f", viewModel.weightInPreferredUnit))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text(viewModel.isKgSelected ? "kg" : "lb")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Progress summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal Difference")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.8))
                    
                    Text("\(String(format: "%.1f", weightDifference)) \(viewModel.isKgSelected ? "kg" : "lb")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isWeightLoss ? .green : .blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Change")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.8))
                    
                    Text("\(String(format: "%.1f", progressPercentage))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isWeightLoss ? .green : .blue)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.green.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Health Insights Card
struct HealthInsightsCard: View {
    @ObservedObject var viewModel: TargetWeightViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.healthBenefitMessage)
                .font(.system(size: 15))
                .foregroundColor(.appWhite.opacity(0.9))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.12),
                            Color.blue.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct TargetWeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TargetWeightView(viewModel: TargetWeightViewModel(), progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
