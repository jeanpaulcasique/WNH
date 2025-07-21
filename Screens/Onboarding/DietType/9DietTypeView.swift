import SwiftUI
import Combine

// MARK: - Enhanced DietTypeView with Visual Improvements
struct DietTypeView: View {
    @StateObject private var viewModel = DietTypeViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var navigateToNextView = false
    @State private var showComparisonView = false
    @State private var dragOffset: CGSize = .zero
    @State private var selectedCardScale: CGFloat = 1.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Dynamic background with gradient animation
            DynamicBackground()
            
            VStack(spacing: 0) {
                // Enhanced header with animated elements
                EnhancedHeader()
                
                // Main content with improved animations
                ScrollView {
                    LazyVStack(spacing: 16) {
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
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
            startInitialAnimations()
        }
    }
    
    // MARK: - Enhanced Header
    @ViewBuilder
    private func EnhancedHeader() -> some View {
        VStack(spacing: 12) {
            // Animated logo with particles
            ZStack {
                // Particle effect behind logo
                ParticleSystem()
                    .frame(height: 100)
                
                OnboardingLogo()
                    .scaleEffect(1.1)
                    .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Enhanced title card
            VStack(spacing: 8) {
                Text("WHICH DIET SUITS YOU BEST?")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("Choose your transformation path")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                // Add comparison button
                Button(action: { showComparisonView = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                        Text("Compare All")
                    }
                    .font(.system(size: 14, weight: .semibold))
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
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Enhanced Action Buttons
    @ViewBuilder
    private func EnhancedActionButtons() -> some View {
        HStack(spacing: 16) {
            // Back button igual que en WhichPlaceView
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                withAnimation(.easeInOut(duration: 0.3)) {
                    progressViewModel.decreaseProgress()
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .overlay(
                            Capsule()
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                )
            }

            if viewModel.hasValidSelection {
                // Next button igual que en WhichPlaceView
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    viewModel.disableNextButtonTemporarily()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        progressViewModel.advanceProgress()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigateToNextView = true
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            Text("Continue")
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.yellow)
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    )
                    .scaleEffect(viewModel.isLoading ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isLoading)
                }
                .disabled(viewModel.isNextButtonDisabled)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .padding(.bottom, 24)
        // NavigationLink a WhichPlaceView
        NavigationLink(
            destination: WhichPlaceView(progressViewModel: progressViewModel),
            isActive: $navigateToNextView
        ) {
            EmptyView()
        }
        .hidden()
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
    
    private func proceedToNext() {
        viewModel.disableNextButtonTemporarily()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            navigateToNextView = true
        }
    }
}

// MARK: - Enhanced Diet Card with Advanced Animations
struct EnhancedDietCard: View {
    let diet: DietTypeDetails
    let index: Int
    let isSelected: Bool
    let isRecommended: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var hoverOffset: CGSize = .zero
    @State private var sparkleAnimation = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    cardContent
                        .background(cardBackground)
                    
                    // Sparkle effect for recommended
                    if isRecommended {
                        SparkleEffect(isAnimating: $sparkleAnimation)
                    }
                    
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
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? Color.yellow : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 3 : 1
                    )
                    .shadow(color: isSelected ? Color.yellow.opacity(0.5) : Color.clear, radius: 8)
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
        .onAppear {
            if isRecommended {
                sparkleAnimation = true
            }
        }
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
        HStack(spacing: 20) {
            EnhancedIconSection()
            
            VStack(alignment: .leading, spacing: 12) {
                titleSection
                highlightsPills
                if isSelected {
                    quickStats
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    @ViewBuilder
    private func EnhancedIconSection() -> some View {
        ZStack {
            // Animated background
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
                .frame(width: 70, height: 70)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
            
            // Icon with enhanced styling
            Image(systemName: diet.icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isSelected ? .black : Color.black.opacity(0.8))
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isSelected)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(diet.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(diet.subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    private var highlightsPills: some View {
        HStack(spacing: 8) {
            ForEach(Array(diet.highlights.prefix(2).enumerated()), id: \.offset) { index, highlight in
                Text(highlight)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.1), value: isSelected)
            }
        }
    }
    
    private var quickStats: some View {
        HStack(spacing: 12) {
            QuickStat(title: diet.difficulty, icon: "speedometer")
            QuickStat(title: diet.timeToResults, icon: "clock")
        }
        .transition(.opacity.combined(with: .move(edge: .leading)))
    }
    
    private var expandedContent: some View {
        VStack(spacing: 20) {
            Divider()
                .background(Color.black.opacity(0.3))
                .padding(.horizontal, 24)
            
            VStack(spacing: 20) {
                descriptionSection
                AnimatedMacroBreakdown(diet: diet)
                benefitsSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                ForEach(Array(diet.benefits.prefix(3).enumerated()), id: \.offset) { index, benefit in
                    HStack {
                        Text(benefit)
                            .font(.system(size: 14))
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
    @State private var pulse = false
    
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
            .scaleEffect(pulse ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            .onAppear {
                pulse = true
            }
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
                .font(.system(size: 12, weight: .medium))
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
    @State private var animateChart = false
    
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
                AnimatedMacroCircle(percentage: diet.macroBreakdown.fat, color: .orange, label: "Fat", animate: animateChart)
                AnimatedMacroCircle(percentage: diet.macroBreakdown.protein, color: .green, label: "Protein", animate: animateChart)
                AnimatedMacroCircle(percentage: diet.macroBreakdown.carbs, color: .blue, label: "Carbs", animate: animateChart)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animateChart = true
            }
        }
    }
}

struct AnimatedMacroCircle: View {
    let percentage: Double
    let color: Color
    let label: String
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: animate ? percentage / 100 : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5), value: animate)
                
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

struct SparkleEffect: View {
    @Binding var isAnimating: Bool
    @State private var sparkles: [SparkleData] = []
    
    struct SparkleData: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let delay: Double
        let duration: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                    .position(x: sparkle.x, y: sparkle.y)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .scaleEffect(isAnimating ? 1.2 : 0.5)
                    .animation(
                        .easeInOut(duration: sparkle.duration)
                            .repeatForever(autoreverses: true)
                            .delay(sparkle.delay),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            generateSparkles()
        }
    }
    
    private func generateSparkles() {
        sparkles = (0..<6).map { i in
            SparkleData(
                x: CGFloat.random(in: 20...300),
                y: CGFloat.random(in: 20...100),
                delay: Double(i) * 0.2,
                duration: Double.random(in: 1.5...2.5)
            )
        }
    }
}

struct DynamicBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.white,
                Color.yellow.opacity(0.1),
                Color.white
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct ParticleSystem: View {
    @State private var particles: [ParticleData] = []
    
    struct ParticleData: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let opacity: Double
    }
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x,
                    y: particle.y,
                    width: particle.size,
                    height: particle.size
                )
                
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.yellow.opacity(particle.opacity))
                )
            }
        }
        .onAppear {
            generateParticles()
            startAnimation()
        }
    }
    
    private func generateParticles() {
        particles = (0..<20).map { _ in
            ParticleData(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...100),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.5...2.0),
                opacity: Double.random(in: 0.3...0.7)
            )
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for i in particles.indices {
                particles[i].x += particles[i].speed
                particles[i].y += sin(particles[i].x * 0.01) * 0.5
                
                if particles[i].x > UIScreen.main.bounds.width + 10 {
                    particles[i].x = -10
                    particles[i].y = CGFloat.random(in: 0...100)
                }
            }
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
                        .font(.system(size: 24, weight: .bold))
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
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(diet.subtitle)
                            .font(.system(size: 14))
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
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.system(size: 10))
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

// MARK: - Preview
struct DietTypeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DietTypeView(progressViewModel: ProgressViewModel())
        }
    }
}
