import SwiftUI
import Combine

// MARK: - Enhanced DietTypeView with Visual Improvements
struct DietTypeView: View {
    @StateObject private var viewModel = DietTypeViewModel()
    
    @State private var navigateToNextView = false
    @State private var navigateToPreviousView = false
    @State private var showComparisonView = false
    @State private var dragOffset: CGSize = .zero
    @State private var selectedCardScale: CGFloat = 1.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Simple white background
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced header with animated elements
                EnhancedHeader()
                
                // Main content with simplified animations - only cascade effect
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<viewModel.imageCount, id: \.self) { index in
                            EnhancedDietCard(
                                diet: viewModel.getDietDetails(for: index),
                                index: index,
                                isSelected: index == viewModel.currentIndex,
                                isRecommended: index == viewModel.getRecommendedDietIndex(),
                                onTap: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.selectDiet(index)
                                    }
                                    
                                    // Enhanced haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }
                            )
                            .scaleEffect(index == viewModel.currentIndex ? 1.02 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.currentIndex)
                            // Cascade effect - simple delay based on index
                            .offset(y: 0)
                            .opacity(1.0)
                            .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1), value: true)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // Enhanced floating action buttons
            VStack {
                Spacer()
                EnhancedActionButtons()
            }
            
            // Comparison modal
            if showComparisonView {
                ComparisonModal(
                    diets: (0..<viewModel.imageCount).map { viewModel.getDietDetails(for: $0) },
                    selectedIndex: viewModel.currentIndex,
                    onClose: { showComparisonView = false },
                    onSelect: { index in
                        viewModel.selectDiet(index)
                        showComparisonView = false
                    }
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(1000)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Simplified animations - only cascade effect
            startCascadeAnimations()
        }
    }
    
    // MARK: - Enhanced Header
    @ViewBuilder
    private func EnhancedHeader() -> some View {
        VStack(spacing: 12) {
            // Simple logo without particles
            OnboardingLogo()
                .scaleEffect(1.1)
            
            // Enhanced title card
            VStack(spacing: 8) {
                Text("WHICH DIET SUITS YOU BEST?")
                    .font(.system(size: 26, weight: .black, design: .default))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Choose your transformation path")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Add comparison button
                Button(action: { showComparisonView = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                        Text("Compare All")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.black, lineWidth: 2)
                            .background(Capsule().fill(Color.white.opacity(0.9)))
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black, lineWidth: 4)
                    )
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Enhanced Action Buttons
    @ViewBuilder
    private func EnhancedActionButtons() -> some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                navigateToPreviousView = true
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color(white: 0.18))
                    .clipShape(Circle())
            }

            Spacer()
            
            // Next button - only show when user has made a selection
            if viewModel.hasValidSelection {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToNextView = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.black)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.yellow.opacity(0.9))
                            .shadow(color: Color.yellow.opacity(0.4), radius: 10, x: 0, y: 4)
                    )
                }
                .scaleEffect(1.0)
                .transition(.opacity)
            }
            
            NavigationLink(
                destination: WorkoutLevelView(),
                isActive: $navigateToNextView
            ) {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(
                destination: BMIView(viewModel: BMIViewModel()),
                isActive: $navigateToPreviousView
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.hasValidSelection)
    }
    
    private func startInitialAnimations() {
        // Staggered entrance animations
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            viewModel.animationPhase = .header
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            viewModel.animationPhase = .cards
        }
    }

    private func startCascadeAnimations() {
        // Cascade effect - simple delay based on index
        for (index, _) in (0..<viewModel.imageCount).enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    // No specific animation needed here, just the cascade effect
                }
            }
        }
    }
}

// MARK: - Enhanced Diet Card with Simplified Animations
struct EnhancedDietCard: View {
    let diet: DietTypeDetails
    let index: Int
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    cardContent
                        .background(cardBackground)
                    
                    // Recommendation badge
                    if isRecommended {
                        VStack {
                            HStack {
                                Spacer()
                                RecommendationBadge()
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                    }
                }
                
                if isSelected {
                    expandedContent
                        .transition(.opacity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? Color.yellow : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.25) : Color.black.opacity(0.1),
                radius: isSelected ? 15 : 5,
                x: 0,
                y: isSelected ? 8 : 2
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        Color.yellow,
                        Color.yellow.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 4)
            )
    }
    
    private var cardContent: some View {
        HStack(spacing: 16) {
            EnhancedIconSection()
            
            VStack(alignment: .leading, spacing: 10) {
                titleSection
                highlightsPills
                if isSelected {
                    quickStats
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func EnhancedIconSection() -> some View {
        ZStack {
            // Simple background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.7)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 55, height: 55)
            
            // Icon with simple styling
            Image(systemName: diet.icon)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(isSelected ? .black : Color.black.opacity(0.8))
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(diet.title)
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(diet.subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    private var highlightsPills: some View {
        HStack(spacing: 6) {
            ForEach(Array(diet.highlights.prefix(2).enumerated()), id: \.offset) { index, highlight in
                Text(highlight)
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
            }
        }
    }
    
    private var quickStats: some View {
        HStack(spacing: 10) {
            QuickStat(title: diet.difficulty, icon: "speedometer")
            QuickStat(title: diet.timeToResults, icon: "clock")
        }
        .transition(.opacity)
    }
    
    private var expandedContent: some View {
        VStack(spacing: 20) {
            Divider()
                .background(Color.black.opacity(0.3))
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                descriptionSection
                AnimatedMacroBreakdown(diet: diet)
                benefitsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private var descriptionSection: some View {
        Text(diet.description)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.black.opacity(0.8))
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
    }
    
    private var benefitsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Key Benefits")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                ForEach(Array(diet.benefits.prefix(3).enumerated()), id: \.offset) { index, benefit in
                    HStack {
                        Text(benefit)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.black.opacity(0.8))
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct RecommendationBadge: View {
    var body: some View {
        Text("RECOMMENDED")
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black)
                    .overlay(
                        Capsule()
                            .stroke(Color.yellow, lineWidth: 2)
                    )
            )
            .foregroundColor(.white)
    }
}

struct QuickStat: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.7))
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct AnimatedMacroBreakdown: View {
    let diet: DietTypeDetails
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Macro Breakdown")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text(diet.successRate)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 20) {
                AnimatedMacroCircle(percentage: diet.macroBreakdown.fat, color: .orange, label: "Fat")
                AnimatedMacroCircle(percentage: diet.macroBreakdown.protein, color: .green, label: "Protein")
                AnimatedMacroCircle(percentage: diet.macroBreakdown.carbs, color: .blue, label: "Carbs")
            }
        }
    }
}

struct AnimatedMacroCircle: View {
    let percentage: Double
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: percentage / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

// MARK: - Comparison Modal
struct ComparisonModal: View {
    let diets: [DietTypeDetails]
    let selectedIndex: Int
    let onClose: () -> Void
    let onSelect: (Int) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onClose() }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Compare Diets")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color.yellow)
                
                // Comparison content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(diets.enumerated()), id: \.offset) { index, diet in
                            ComparisonRow(
                                diet: diet,
                                isSelected: index == selectedIndex,
                                onSelect: { onSelect(index) }
                            )
                        }
                    }
                    .padding(20)
                }
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .frame(maxWidth: .infinity, maxHeight: 600)
            .padding(.horizontal, 20)
        }
    }
}

struct ComparisonRow: View {
    let diet: DietTypeDetails
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: diet.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .yellow : .black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(diet.title)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Text(diet.subtitle)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                    }
                }
                
                // Mini stats
                HStack(spacing: 20) {
                    StatPill(title: diet.difficulty, subtitle: "Difficulty")
                    StatPill(title: diet.timeToResults, subtitle: "Results")
                    StatPill(title: diet.successRate, subtitle: "Success")
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatPill: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white)
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

