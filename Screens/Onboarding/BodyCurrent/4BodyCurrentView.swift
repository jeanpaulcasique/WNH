import SwiftUI
import UIKit

struct BodyCurrentView: View {
    @ObservedObject var viewModel = BodyCurrentViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    @State private var isButtonDisabled = false
    @State private var isLoading = false
    @State private var showSelectionAnimation = false
    @State private var userGender: Gender = .male
    
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
                VStack(spacing: 30) {
                    progressSection
                    headerSection
                    bodyShapeSelectionSection
                    motivationalSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Next button overlay
            if viewModel.selectedBodyShape != nil {
                VStack {
                    Spacer()
                    nextButtonSection
                        .padding(.horizontal, 0)
                        .padding(.bottom, 0)
                }
            }
        }
   
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            loadUserGender()
        }
        .overlay(
            // Success animation overlay
            Group {
                if showSelectionAnimation {
                    CurrentBodySelectionSuccessView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension BodyCurrentView {
    
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
        VStack(spacing: 20) {
            // Animated assessment icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                    .scaleEffect(viewModel.selectedBodyShape != nil ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedBodyShape)
            }
            
            VStack(spacing: 12) {
                Text("What's your current body shape?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
            
            }
        }
        .padding(.top, 10)
    }
    
    var bodyShapeSelectionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Select Your Current Shape")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(BodyCurrentViewModel.BodyShape.allCases, id: \.self) { shape in
                    EnhancedBodyOptionCard(
                        bodyShape: shape,
                        imageName: getImageName(for: shape),
                        isSelected: viewModel.selectedBodyShape == shape
                    ) {
                        selectBodyShape(shape)
                    }
                }
            }
        }
    }
    
    var motivationalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Remember")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                MotivationalCard(
                    icon: "heart.fill",
                    title: "Every Journey Starts Somewhere",
                    description: "Your current shape is just the beginning of your transformation",
                    color: .red
                )
                
                MotivationalCard(
                    icon: "target",
                    title: "Personalized Just for You",
                    description: "We'll create workouts that match your starting point perfectly",
                    color: .blue
                )
                
                MotivationalCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Over Perfection",
                    description: "Small consistent steps lead to amazing transformations",
                    color: .green
                )
            }
        }
    }
    
    var nextButtonSection: some View {
        VStack {
            NextButton(
                title: "Next",
                action: proceedToNext,
                isLoading: $isLoading,
                isDisabled: $isButtonDisabled
            )
            
            NavigationLink(
                        destination: BirthYearView(
                            viewModel: BirthYearViewModel(), 
                            progressViewModel: progressViewModel
                        ),
                        isActive: $navigateToNextView
                    ) {
                        EmptyView()
                    }
                    .hidden()
        }
    }
    
    // MARK: - Actions
    func loadUserGender() {
        if let savedGender = UserDefaults.standard.string(forKey: "gender"),
           let gender = Gender(rawValue: savedGender) {
            userGender = gender
        }
    }
    
    func getImageName(for shape: BodyCurrentViewModel.BodyShape) -> String {
        switch userGender {
        case .male:
            return shape.rawValue // Uses "mediumMen", "flabbyMen", "skinnyMen", "muscularMen"
        case .female:
            switch shape {
            case .medium:
                return "mediumWomen"
            case .flabby:
                return "flabbyWomen"
            case .skinny:
                return "skinnyWomen"
            case .muscular:
                return "muscularWomen"
            }
        }
    }
    func selectBodyShape(_ shape: BodyCurrentViewModel.BodyShape) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.selectBodyShape(shape)
        }
        
        // Show success animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSelectionAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSelectionAnimation = false
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func proceedToNext() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        progressViewModel.advanceProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToNextView = true
        }
    }
}

// MARK: - Supporting Views
struct EnhancedBodyOptionCard: View {
    let bodyShape: BodyCurrentViewModel.BodyShape
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var shapeInfo: (title: String, description: String, color: Color, icon: String) {
        switch bodyShape {
        case .skinny:
            return ("Lean Build", "Naturally thin with lower muscle mass", .blue, "figure.walk")
        case .medium:
            return ("Average Build", "Balanced proportions and moderate muscle", .green, "figure.stand")
        case .flabby:
            return ("Soft Build", "Higher body fat, ready for transformation", .orange, "figure.stand.line.dotted.figure.stand")
        case .muscular:
            return ("Athletic Build", "Well-developed muscle mass and definition", .purple, "figure.strengthtraining.traditional")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Real body shape image
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 100, height: 120)
                        
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 110)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isSelected ? shapeInfo.color : Color.clear,
                                        lineWidth: isSelected ? 3 : 0
                                    )
                            )
                    }
                    
                    // Shape info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(shapeInfo.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appWhite)
                            
                            Spacer()
                            
                            // Selection indicator
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.appWhite.opacity(0.3))
                            }
                        }
                        
                        Text(shapeInfo.description)
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                .padding(20)
                
                // Expandable encouragement section (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(shapeInfo.color.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                
                                Text("Your fitness journey starts here!")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appWhite)
                                
                                Spacer()
                            }
                            
                            Text(encouragementMessage)
                                .font(.system(size: 13))
                                .foregroundColor(.appWhite.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? shapeInfo.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? shapeInfo.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var encouragementMessage: String {
        switch bodyShape {
        case .skinny:
            return "Perfect for building lean muscle and strength. We'll help you gain healthy weight and definition."
        case .medium:
            return "Great starting point! We'll help you tone up, build muscle, or cut fat based on your goals."
        case .flabby:
            return "Ready to transform! We'll create a balanced plan of cardio and strength training just for you."
        case .muscular:
            return "Impressive foundation! We'll help you optimize your training to reach the next level of performance."
        }
    }
}

struct MotivationalCard: View {
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
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// Removed CurrentBodyInfoOverlayView - not needed

struct CurrentBodySelectionSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Shape selected!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
        }
    }
}

// Using your exact BodyCurrentViewModel.BodyShape cases

// MARK: - Preview
struct BodyCurrentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BodyCurrentView(
                progressViewModel: ProgressViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
