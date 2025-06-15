import SwiftUI

struct WeightView: View {
    @StateObject private var viewModel = WeightViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isNavigatingToTargetWeightView = false
    @State private var showBMISheet = false
    
    var userHeight: Double

    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 20) {
                    progressSection
                    headerSection
                    weightDisplaySection
                    digitalScaleSection
                    unitSelectorSection
                    bmiSection
                    benefitsSection
                    
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
            viewModel.updateWeight(newWeight: viewModel.selectedWeightKg)
            viewModel.setupAnimations()
        }
        .sheet(isPresented: $showBMISheet) {
            BMIExplanationSheet(viewModel: viewModel, userHeight: userHeight)
        }
    }
}

// MARK: - Background & Navigation
private extension WeightView {
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
            viewModel.goBack(progressViewModel: progressViewModel) {
                presentationMode.wrappedValue.dismiss()
            }
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
                    action: {
                        viewModel.proceedToNext(progressViewModel: progressViewModel) {
                            isNavigatingToTargetWeightView = true
                        }
                    },
                    isLoading: $viewModel.isNextButtonLoading,
                    isDisabled: $viewModel.isNextButtonDisabled
                )
                
                NavigationLink(
                    destination: TargetWeightView(
                        viewModel: TargetWeightViewModel(),
                        progressViewModel: progressViewModel
                    ),
                    isActive: $isNavigatingToTargetWeightView
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
private extension WeightView {
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            scaleIcon
            headerText
        }
        .padding(.top, 15)
    }
    
    var scaleIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "scalemass.fill")
                .font(.system(size: 40))
                .foregroundColor(.appYellow)
                .rotationEffect(.degrees(viewModel.scaleRotation))
                .scaleEffect(viewModel.scaleScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.scaleRotation)
        }
    }
    
    var headerText: some View {
        VStack(spacing: 10) {
            Text("What's your current weight?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
          
        }
    }
    
    var weightDisplaySection: some View {
        VStack(spacing: 16) {
            if viewModel.showWeightAnimation {
                VStack(spacing: 12) {
                    HStack {
                        Text("Current Weight")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    WeightDisplayCard(viewModel: viewModel)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var digitalScaleSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Digital Scale")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                Text("Slide to adjust")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
            
            VStack(spacing: 20) {
                DigitalScaleDisplay(viewModel: viewModel)
                InteractiveWeightSlider(viewModel: viewModel)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    var unitSelectorSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Units")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack(spacing: 14) {
                WeightUnitButton(
                    title: "Kilograms",
                    subtitle: "kg",
                    isSelected: viewModel.isKgSelected,
                    color: .blue,
                    action: viewModel.selectKgUnit
                )
                
                WeightUnitButton(
                    title: "Pounds",
                    subtitle: "lb",
                    isSelected: !viewModel.isKgSelected,
                    color: .green,
                    action: viewModel.selectLbUnit
                )
            }
        }
    }
    
    var bmiSection: some View {
        VStack(spacing: 16) {
            if viewModel.showBMIDisplay {
                VStack(spacing: 12) {
                    HStack {
                        Text("Body Mass Index")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    BMIDisplayCard(
                        viewModel: viewModel,
                        userHeight: userHeight,
                        action: { showBMISheet = true }
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    var benefitsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Why We Track Weight")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(viewModel.getWeightBenefits().enumerated()), id: \.offset) { index, benefit in
                    WeightBenefitCard(benefit: benefit)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct DigitalScaleDisplay: View {
    @ObservedObject var viewModel: WeightViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                    )
                
                HStack(spacing: 8) {
                    Text(viewModel.formattedPrimaryWeight)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .opacity(viewModel.weightChanging ? 0.7 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: viewModel.weightChanging)
                    
                    Text(viewModel.primaryWeightUnit)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                }
                
                if viewModel.weightChanging {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .opacity(viewModel.weightChanging ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.weightChanging)
                    }
                    .padding(.trailing, 12)
                }
            }
            
            scalePlatform
        }
    }
    
    private var scalePlatform: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 20)
            .overlay(
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
                .padding(.horizontal, 20)
            )
    }
}

struct InteractiveWeightSlider: View {
    @ObservedObject var viewModel: WeightViewModel
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 16) {
            sliderHeader
            customSlider
        }
    }
    
    private var sliderHeader: some View {
        HStack {
            Text("Adjust Weight")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Range: ")
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.6))
                
                Text(viewModel.weightRangeText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
        }
    }
    
    private var customSlider: some View {
        ZStack {
            sliderTrack
            sliderProgress
            sliderThumb
        }
        .frame(height: 32)
    }
    
    private var sliderTrack: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 16)
    }
    
    private var sliderProgress: some View {
        GeometryReader { geometry in
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow, Color.yellow.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * viewModel.getSliderProgress(), height: 16)
                
                Spacer()
            }
        }
        .frame(height: 16)
    }
    
    private var sliderThumb: some View {
        HStack {
            Spacer()
            
            Circle()
                .fill(Color.appYellow)
                .frame(width: isDragging ? 32 : 28, height: isDragging ? 32 : 28)
                .overlay(
                    Circle()
                        .stroke(Color.appWhite, lineWidth: 3)
                )
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            
            Spacer()
        }
        .offset(x: viewModel.getThumbOffset())
        .gesture(sliderGesture)
    }
    
    private var sliderGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    viewModel.setWeightChanging(true)
                }
                viewModel.updateWeightFromSlider(translation: value.translation.width)
            }
            .onEnded { _ in
                isDragging = false
                viewModel.setWeightChanging(false)
                viewModel.generateHapticFeedback(style: .light)
            }
    }
}

struct WeightDisplayCard: View {
    @ObservedObject var viewModel: WeightViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            primaryWeightCard
            secondaryWeightCard
        }
    }
    
    private var primaryWeightCard: some View {
        VStack(spacing: 8) {
            Text("Primary")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            HStack(spacing: 4) {
                Text(viewModel.formattedPrimaryWeight)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.appYellow)
                
                Text(viewModel.primaryWeightUnit)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
            
            Text(viewModel.primaryWeightUnitName)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var secondaryWeightCard: some View {
        VStack(spacing: 8) {
            Text("Alternative")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            HStack(spacing: 4) {
                Text(viewModel.formattedSecondaryWeight)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(.blue)
                
                Text(viewModel.secondaryWeightUnit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
            }
            
            Text(viewModel.secondaryWeightUnitName)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct WeightUnitButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? color : .appWhite.opacity(0.4))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .appWhite : .appWhite.opacity(0.7))
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? color : .appWhite.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BMIDisplayCard: View {
    @ObservedObject var viewModel: WeightViewModel
    let userHeight: Double
    let action: () -> Void
    
    private var bmi: Double {
        viewModel.calculateBMI(heightInCm: userHeight)
    }
    
    private var category: String {
        viewModel.getBMICategory(bmi: bmi)
    }
    
    private var color: Color {
        viewModel.getBMIColor(bmi: bmi)
    }
    
    var body: some View {
        Button(action: {
            action()
            viewModel.generateHapticFeedback(style: .light)
        }) {
            HStack(spacing: 16) {
                bmiInfo
                infoSection
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bmiInfo: some View {
        VStack(spacing: 8) {
            Text("BMI")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            Text(viewModel.getFormattedBMI(heightInCm: userHeight))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Text(category)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var infoSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.appYellow)
            
            Text("Tap to learn\nabout BMI")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.appYellow.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

struct WeightBenefitCard: View {
    let benefit: WeightBenefit
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(benefit.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: benefit.icon)
                    .font(.system(size: 20))
                    .foregroundColor(benefit.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(benefit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(benefit.description)
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - BMI Sheet
struct BMIExplanationSheet: View {
    @ObservedObject var viewModel: WeightViewModel
    let userHeight: Double
    @Environment(\.presentationMode) var presentationMode
    
    private var bmi: Double {
        viewModel.calculateBMI(heightInCm: userHeight)
    }
    
    private var category: String {
        viewModel.getBMICategory(bmi: bmi)
    }
    
    private var categoryColor: Color {
        viewModel.getBMIColor(bmi: bmi)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        bmiHeader
                        bmiCategoriesSection
                        calculationSection
                        importantNote
                        actionButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("BMI Information")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.appYellow)
            )
        }
    }
    
    private var bmiHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 8) {
                    Text(viewModel.getFormattedBMI(heightInCm: userHeight))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(categoryColor)
                    
                    Text("BMI")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite)
                }
            }
            
            VStack(spacing: 8) {
                Text(category)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("Your BMI Category")
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.8))
            }
        }
    }
    
    private var bmiCategoriesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("BMI Categories")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(viewModel.getBMICategories(userCategory: category).enumerated()), id: \.offset) { index, bmiCategory in
                    BMICategoryRow(category: bmiCategory)
                }
            }
        }
    }
    
    private var calculationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How We Calculate")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(Array(viewModel.getCalculationData(userHeight: userHeight).enumerated()), id: \.offset) { index, calculation in
                    CalculationRow(calculation: calculation)
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    private var importantNote: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Important Note")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
            }
            
            Text("BMI is a useful screening tool, but it doesn't directly measure body fat or muscle mass. For a complete health assessment, consult with a healthcare professional.")
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var actionButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                
                Text("Got it!")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.appBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [categoryColor, categoryColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(28)
        }
    }
}

struct BMICategoryRow: View {
    let category: BMICategory
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(category.color)
                .frame(width: 16, height: 16)
            
            Text(category.range)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.appWhite)
                .frame(width: 80, alignment: .leading)
            
            Text(category.category)
                .font(.system(size: 14, weight: category.isUserCategory ? .bold : .regular))
                .foregroundColor(category.isUserCategory ? category.color : .appWhite.opacity(0.8))
            
            Spacer()
            
            if category.isUserCategory {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(category.color)
                    
                    Text("You")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(category.color)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(category.isUserCategory ? category.color.opacity(0.1) : Color.clear)
        )
    }
}

struct CalculationRow: View {
    let calculation: CalculationData
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: calculation.icon)
                .font(.system(size: 18))
                .foregroundColor(.appYellow)
                .frame(width: 24)
            
            Text(calculation.label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appWhite)
            
            Spacer()
            
            Text(calculation.value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.appYellow)
        }
    }
}

// MARK: - Preview
struct WeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightView(progressViewModel: ProgressViewModel(), userHeight: 175.0)
        }
        .preferredColorScheme(.dark)
    }
}
