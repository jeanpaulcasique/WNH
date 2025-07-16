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
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                OnboardingLogo()
                OnboardingCard(backgroundColor: Color.yellow) {
                    VStack(spacing: 6) {
                        Text("WHICH DIET SUITS YOU BEST?")
                            .font(.system(size: 26, weight: .black, design: .default))
                            .foregroundColor(.black)
                .multilineTextAlignment(.center)
                Text("Choose your transformation path")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
    }
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                ScrollView {
        VStack(spacing: 20) {
            ForEach(0..<viewModel.imageCount, id: \.self) { index in
                DietCard(
                    diet: viewModel.getDietDetails(for: index),
                    index: index,
                    isSelected: index == viewModel.currentIndex,
                    isRecommended: index == viewModel.getRecommendedDietIndex(),
                                animationPhase: .cards,
                    onTap: {
                        viewModel.selectDiet(index)
                    }
                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 80)
                }
                .overlay(
                    Group {
                        if viewModel.hasValidSelection {
                            HStack {
                                OnboardingBack {
                                    progressViewModel.decreaseProgress()
                                    presentationMode.wrappedValue.dismiss()
                                }
                                Spacer()
                                OnboardingNext {
                                    proceedToNext()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 0)
                        }
                    },
                    alignment: .bottom
                )
                Spacer(minLength: 0)
            }
            // NavigationLink oculto
            NavigationLink(
                destination: LevelActivityView(progressViewModel: progressViewModel),
                isActive: $navigateToNextView
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.black)
                                    .shadow(color: Color.yellow.opacity(0.4), radius: 6, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                            .offset(x: -3, y: 1)
                            .scaleEffect(0.95)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .speed(0.7),
                                value: UUID()
                            )
                    }
                }
                .padding(.top, 10)
                .padding(.trailing, 5)
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
        Color.yellow
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 5)
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
            Text(diet.title)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(diet.subtitle)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.8))
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
                            .fill(Color.black)
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
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
            .foregroundColor(.black.opacity(0.9))
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
                    .foregroundColor(.black.opacity(0.8))
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
                    .foregroundColor(.black)
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
            StatCardDietType(title: diet.difficulty, subtitle: "Difficulty", textColor: .white)
            StatCardDietType(title: diet.timeToResults, subtitle: "Results", textColor: .white)
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
                    .stroke(Color.appBlack.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: animatedPercentage / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appBlack)
            }
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.appBlack.opacity(0.7))
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
    var textColor: Color = .white
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(textColor)
            Text(subtitle.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow, lineWidth: 1)
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

// MARK: - Preview
struct DietTypeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DietTypeView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}

