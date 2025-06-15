import SwiftUI
import UIKit

struct HeightView: View {
    @StateObject var viewModel = HeightViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToWeightView = false
    @State private var showMeasuringTape = false
    @State private var tapeMeasureOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showHeightDisplay = false
    @State private var showSelectionAnimation = false
    
    var body: some View {
        ZStack {
            // Gradient background matching other screens
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    progressSection
                    headerSection
                    heightDisplaySection
                    unitSelectorSection
                    measuringTapeSection
                    benefitsSection
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            // Next button overlay
            VStack {
                Spacer()
                nextButtonSection
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)
            }
        }
       
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadHeightFromUserDefaults()
            setupAnimations()
        }
        .overlay(
            // Success animation overlay
            Group {
                if showSelectionAnimation {
                    HeightSelectionSuccessView(height: viewModel.getCurrentHeightString())
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension HeightView {
    
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
    
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            // Animated ruler icon
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
                
                Image(systemName: "ruler.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appYellow)
                    .rotationEffect(.degrees(showMeasuringTape ? 45 : 0))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showMeasuringTape)
            }
            
            VStack(spacing: 10) {
                Text("What's your height?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
               
            }
        }
        .padding(.top, 15)
    }
    
    var heightDisplaySection: some View {
        VStack(spacing: 16) {
            if showHeightDisplay {
                VStack(spacing: 12) {
                    HStack {
                        Text("Your Height")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    HeightDisplayCard(
                        primaryHeight: viewModel.getCurrentHeightString(),
                        secondaryHeight: viewModel.getAlternativeHeightString(),
                        isCm: viewModel.isCmSelected
                    )
                }
                .transition(.scale.combined(with: .opacity))
            }
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
                UnitSelectorButton(
                    title: "Centimeters",
                    subtitle: "cm",
                    isSelected: viewModel.isCmSelected,
                    color: .blue
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleUnit(toCm: true)
                    }
                    generateHapticFeedback()
                }
                
                UnitSelectorButton(
                    title: "Feet & Inches",
                    subtitle: "ft/in",
                    isSelected: !viewModel.isCmSelected,
                    color: .green
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleUnit(toCm: false)
                    }
                    generateHapticFeedback()
                }
            }
        }
    }
    
    var measuringTapeSection: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Select Your Height")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                if showMeasuringTape {
                    Text("Drag the tape measure")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appYellow.opacity(0.8))
                }
            }
            
            // Measuring Tape Container
            ZStack {
                // Background measuring tape case
                VStack(spacing: 0) {
                    // Tape case top
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 35)
                        .overlay(
                            HStack {
                                Image(systemName: "ruler.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appYellow)
                                
                                Text("TAPE MEASURE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.appWhite)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                        )
                    
                    // Measuring tape itself
                    if showMeasuringTape {
                        MeasuringTapeView(
                            viewModel: viewModel,
                            offset: $tapeMeasureOffset,
                            isDragging: $isDragging
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Deploy button when tape is not shown
                if !showMeasuringTape {
                    Button(action: {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                            showMeasuringTape = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showHeightDisplay = true
                            }
                        }
                        
                        generateHapticFeedback()
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.appYellow)
                            
                            Text("Tap to Deploy Tape")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appYellow)
                        }
                        .padding(30)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: showMeasuringTape ? 350 : 180)
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showMeasuringTape)
        }
    }
    
    var benefitsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Why We Need Your Height")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HeightBenefitCard(
                    icon: "chart.bar.fill",
                    title: "BMI Calculation",
                    description: "Accurate body mass index for health insights",
                    color: .blue
                )
                
                HeightBenefitCard(
                    icon: "figure.strengthtraining.traditional",
                    title: "Exercise Scaling",
                    description: "Workouts adapted to your body proportions",
                    color: .green
                )
                
                HeightBenefitCard(
                    icon: "target",
                    title: "Goal Setting",
                    description: "Realistic targets based on your body type",
                    color: .purple
                )
            }
        }
    }
    
    var nextButtonSection: some View {
        VStack {
            NextButton(
                title: "Next",
                action: proceedToNext,
                isLoading: $viewModel.isLoading,
                isDisabled: $viewModel.isButtonDisabled
            )
            
            NavigationLink(
                destination: WeightView(
                    progressViewModel: progressViewModel,
                    userHeight: viewModel.isCmSelected ?
                        Double(viewModel.selectedHeightCm) :
                        Double(viewModel.selectedHeightFt * 12 + viewModel.selectedHeightInch) * 2.54
                ),
                isActive: $navigateToWeightView
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
    
    // MARK: - Actions
    func setupAnimations() {
        // Auto-deploy tape after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !showMeasuringTape {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showMeasuringTape = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showHeightDisplay = true
                    }
                }
            }
        }
    }
    
    func proceedToNext() {
        generateHapticFeedback()
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        
        showSelectionFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToWeightView = true
        }
    }
    
    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func showSelectionFeedback() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSelectionAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSelectionAnimation = false
            }
        }
    }
}

// MARK: - Supporting Views
struct MeasuringTapeView: View {
    @ObservedObject var viewModel: HeightViewModel
    @Binding var offset: CGFloat
    @Binding var isDragging: Bool
    @State private var tapeLength: CGFloat = 300
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Tape background
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.9), Color.yellow.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width - 40, height: 60)
                    .overlay(
                        // Tape markings
                        HStack(spacing: 0) {
                            ForEach(0..<20, id: \.self) { index in
                                VStack(spacing: 2) {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: 1, height: index % 5 == 0 ? 25 : (index % 2 == 0 ? 15 : 10))
                                    
                                    if index % 10 == 0 {
                                        Text("\(100 + index * 5)")
                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 8)
                    )
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                
                // Draggable indicator
                VStack(spacing: 8) {
                    // Top arrow
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    
                    // Height display
                    Text(viewModel.getCurrentHeightString())
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(radius: 3)
                        )
                    
                    // Bottom arrow
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .offset(x: offset)
                .scaleEffect(isDragging ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let newOffset = max(-geometry.size.width/2 + 50, min(geometry.size.width/2 - 50, value.translation.width))
                            offset = newOffset
                            updateHeight(from: newOffset, geometry: geometry)
                        }
                        .onEnded { _ in
                            isDragging = false
                            // Haptic feedback on selection
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                )
            }
            .frame(height: 110)
        }
        .frame(height: 110)
    }
    
    private func updateHeight(from offset: CGFloat, geometry: GeometryProxy) {
        let percentage = (offset + geometry.size.width/2) / geometry.size.width
        let clampedPercentage = max(0, min(1, percentage))
        
        if viewModel.isCmSelected {
            let height = Int(100 + clampedPercentage * 130) // 100cm to 230cm
            viewModel.selectedHeightCm = height
        } else {
            let totalInches = Int(36 + clampedPercentage * 60) // 3ft to 8ft (approx)
            let feet = totalInches / 12
            let inches = totalInches % 12
            viewModel.selectedHeightFt = max(3, min(8, feet))
            viewModel.selectedHeightInch = max(0, min(11, inches))
        }
        
        viewModel.saveHeightToUserDefaults()
    }
}

struct HeightDisplayCard: View {
    let primaryHeight: String
    let secondaryHeight: String
    let isCm: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Primary")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                
                Text(primaryHeight)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.appYellow)
                
                Text(isCm ? "Centimeters" : "Feet & Inches")
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            VStack(spacing: 8) {
                Text("Alternative")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                
                Text(secondaryHeight)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(.blue)
                
                Text(isCm ? "Feet & Inches" : "Centimeters")
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct UnitSelectorButton: View {
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

struct HeightBenefitCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(description)
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

struct HeightSelectionSuccessView: View {
    let height: String
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Height \(height) - Perfect!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite)
                }
                
                Text("Your measurements are ready!")
                    .font(.system(size: 11))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
        }
    }
}


// MARK: - Preview
struct HeightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HeightView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
