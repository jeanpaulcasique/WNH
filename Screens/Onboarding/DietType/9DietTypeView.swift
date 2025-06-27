// MARK: - DietTypeView.swift - ARCHIVO COMPLETO
import SwiftUI
import Combine

// MARK: - DietTypeView
struct DietTypeView: View {
    @StateObject private var viewModel = DietTypeViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            backgroundWithParticles
            mainContent
            // ✅ CAMBIO: Botón next solo aparece cuando hay selección válida
            if viewModel.hasValidSelection {
                nextButtonOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.startStaggeredAnimations()
        }
    }
}

// MARK: - Background & Particles
private extension DietTypeView {
    var backgroundWithParticles: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Gradient overlay
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles
            FloatingParticles()
        }
    }
}

// MARK: - Main Content
private extension DietTypeView {
    var mainContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                progressSection
                headerSection
                dietCardsSection
                Spacer(minLength: 80)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
        .opacity(viewModel.animationPhase.rawValue >= AnimationPhase.header.rawValue ? 1 : 0)
        .offset(y: viewModel.animationPhase.rawValue >= AnimationPhase.header.rawValue ? 0 : -20)
        .animation(.spring(response: 0.7, dampingFraction: 0.8), value: viewModel.animationPhase)
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            enhancedIcon
            headerText
        }
        .padding(.top, 15)
    }
    
    var enhancedIcon: some View {
        ZStack {
            // Animated rings
            if viewModel.animationPhase.rawValue >= AnimationPhase.icon.rawValue {
                Circle()
                    .stroke(Color.appYellow.opacity(0.2), lineWidth: 1)
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.2)
                    .opacity(0.6)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: UUID())
                
                Circle()
                    .stroke(Color.appYellow.opacity(0.1), lineWidth: 1)
                    .frame(width: 140, height: 140)
                    .scaleEffect(1.4)
                    .opacity(0.4)
                    .animation(.easeInOut(duration: 3).repeatForever().delay(1), value: UUID())
            }
            
            // Main icon container
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.4), Color.appYellow.opacity(0.05)],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(Color.appYellow.opacity(0.2), lineWidth: 1)
                    )
                
                // Rotating gradient
                if viewModel.animationPhase.rawValue >= AnimationPhase.icon.rawValue {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [Color.clear, Color.appYellow.opacity(0.3), Color.clear],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(Date().timeIntervalSince1970 * 60))
                        .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: UUID())
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(.appYellow)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.appYellow)
                }
            }
        }
        .scaleEffect(viewModel.animationPhase.rawValue >= AnimationPhase.icon.rawValue ? 1 : 0.5)
        .opacity(viewModel.animationPhase.rawValue >= AnimationPhase.icon.rawValue ? 1 : 0)
        .animation(.spring(response: 1.0, dampingFraction: 0.6), value: viewModel.animationPhase)
    }
    
    var headerText: some View {
        VStack(spacing: 12) {
            Text("Which diet suits your goal?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Choose your transformation path")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .offset(y: viewModel.animationPhase.rawValue >= AnimationPhase.title.rawValue ? 0 : 20)
        .opacity(viewModel.animationPhase.rawValue >= AnimationPhase.title.rawValue ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: viewModel.animationPhase)
    }
    
    var dietCardsSection: some View {
        VStack(spacing: 20) {
            ForEach(0..<viewModel.imageCount, id: \.self) { index in
                DietCard(
                    diet: viewModel.getDietDetails(for: index),
                    index: index,
                    isSelected: index == viewModel.currentIndex,
                    isRecommended: index == viewModel.getRecommendedDietIndex(),
                    animationPhase: viewModel.animationPhase,
                    onTap: {
                        viewModel.selectDiet(index)
                    }
                )
                .offset(y: viewModel.animationPhase.rawValue >= AnimationPhase.cards.rawValue ? 0 : 40)
                .opacity(viewModel.animationPhase.rawValue >= AnimationPhase.cards.rawValue ? 1 : 0)
                .animation(
                    .spring(response: 0.7, dampingFraction: 0.8)
                        .delay(Double(index) * 0.15),
                    value: viewModel.animationPhase
                )
            }
        }
        // ✅ Padding horizontal de las cards
        .padding(.horizontal, 20)
    }
}

// MARK: - Diet Card Component
struct DietCard: View {
    let diet: DietTypeDetails
    let index: Int
    let isSelected: Bool
    let isRecommended: Bool
    let animationPhase: AnimationPhase
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    cardContent
                    if isRecommended {
                        Text("RECOMMENDED")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.appYellow)
                                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
                            )
                            .foregroundColor(.black)
                            .offset(x: -2, y: 6)
                            .scaleEffect(0.95)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .speed(0.7),
                                value: UUID()
                            )
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 12)
                if isSelected {
                    expandedContent
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
                }
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? Color.appYellow : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.appYellow.opacity(0.15) : Color.clear,
                radius: isSelected ? 20 : 0,
                x: 0,
                y: isSelected ? 8 : 0
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: isSelected
                ? [Color.appSurface.opacity(0.8), Color.appSurface.opacity(0.6)]
                : [Color.appSurface.opacity(0.4), Color.appSurface.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardContent: some View {
        HStack(spacing: 20) {
            iconSection
            
            VStack(alignment: .leading, spacing: 8) {
                titleSection
                highlightsPills
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var iconSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.appYellow : Color.appSurface.opacity(0.6))
                .frame(width: 60, height: 60)
                .shadow(
                    color: isSelected ? Color.appYellow.opacity(0.3) : Color.clear,
                    radius: isSelected ? 8 : 0
                )
            
            if isSelected {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
            }
            
            Image(systemName: diet.icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(isSelected ? .black : .appYellow)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // ✅ Título ahora tiene todo el espacio horizontal
            Text(diet.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(isSelected ? .appYellow : .appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(diet.subtitle)
                .font(.system(size: 14))
                .foregroundColor(isSelected ? .appWhite.opacity(0.8) : .appWhite.opacity(0.7))
        }
    }
    
    private var highlightsPills: some View {
        HStack(spacing: 6) {
            ForEach(Array(diet.highlights.prefix(2).enumerated()), id: \.offset) { index, highlight in
                Text(highlight)
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                isSelected
                                    ? Color.appYellow.opacity(0.2)
                                    : Color.appSurface.opacity(0.5)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected
                                            ? Color.appYellow.opacity(0.3)
                                            : Color.appWhite.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .foregroundColor(isSelected ? .appYellow : .appWhite.opacity(0.8))
                    .scaleEffect(isSelected ? 1.0 : 0.95)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8).delay(Double(index) * 0.05), value: isSelected)
            }
        }
    }
    
    private var expandedContent: some View {
        VStack(spacing: 20) {
            Divider()
                .background(Color.appWhite.opacity(0.2))
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                descriptionSection
                successRateSection
                macroVisualization
                statsGrid
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
    
    private var descriptionSection: some View {
        Text(diet.description)
            .font(.system(size: 14))
            .foregroundColor(.appWhite.opacity(0.8))
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
    }
    
    private var successRateSection: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: UUID())
                
                Text("Success Rate")
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.8))
            }
            
            Spacer()
            
            Text(diet.successRate)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.green)
        }
    }
    
    private var macroVisualization: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Macro Breakdown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack(spacing: 24) {
                MacroCircle(percentage: diet.macroBreakdown.fat, color: .orange, label: "Fat")
                MacroCircle(percentage: diet.macroBreakdown.protein, color: .green, label: "Protein")
                MacroCircle(percentage: diet.macroBreakdown.carbs, color: .blue, label: "Carbs")
            }
        }
    }
    
    private var statsGrid: some View {
        HStack(spacing: 12) {
            StatCardDietType(title: diet.difficulty, subtitle: "Difficulty")
            StatCardDietType(title: diet.timeToResults, subtitle: "Results")
        }
    }
}

// MARK: - Macro Circle Component
struct MacroCircle: View {
    let percentage: Double
    let color: Color
    let label: String
    @State private var animatedPercentage: Double = 0
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.appWhite.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appWhite)
            }
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.7))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1).delay(0.2)) {
                animatedPercentage = percentage
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCardDietType: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(subtitle.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.6))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.appWhite.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Floating Particles Component
struct FloatingParticles: View {
    @State private var particles: [ParticleData] = []
    
    struct ParticleData: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let duration: Double
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.appYellow.opacity(0.3))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(0.6)
                    .animation(
                        .easeInOut(duration: particle.duration)
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<8).map { _ in
            ParticleData(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 2...4),
                duration: Double.random(in: 2...4)
            )
        }
    }
}

// MARK: - Navigation & Actions
private extension DietTypeView {
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
                    destination: LevelActivityView(progressViewModel: progressViewModel),
                    isActive: $navigateToNextView
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding(.horizontal, 0)
            .padding(.bottom, 0)
        }
        .opacity(viewModel.animationPhase.rawValue >= AnimationPhase.cards.rawValue ? 1 : 0)
        .offset(y: viewModel.animationPhase.rawValue >= AnimationPhase.cards.rawValue ? 0 : 30)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: viewModel.animationPhase)
        // ✅ Animación suave cuando aparece el botón
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity
        ))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.hasValidSelection)
    }
    
    func proceedToNext() {
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

// MARK: - Preview
struct DietTypeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DietTypeView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
