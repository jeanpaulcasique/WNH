// MARK: - Results-Focused ShowInfoView
import SwiftUI

struct ShowInfoView: View {
    @StateObject private var viewModel = ShowInfoViewModel()
    @State private var navigateToDashboard = false

    var body: some View {
        ZStack {
            enhancedBackground
            
            if viewModel.isGeneratingPlan {
                loadingView
            } else {
                resultsView
            }
        }
        .onAppear {
            viewModel.loadUserData()
            viewModel.startAnalysis()
        }
    }
}

// MARK: - Background
private extension ShowInfoView {
    var enhancedBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                    .position(
                        x: CGFloat.random(in: 100...UIScreen.main.bounds.width - 100),
                        y: CGFloat.random(in: 200...UIScreen.main.bounds.height - 200)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 2),
                        value: UUID()
                    )
            }
        }
    }
}

// MARK: - Enhanced Loading View
private extension ShowInfoView {
    var loadingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Premium AI Analysis Hub
            premiumAIHub
            
            Spacer()
            
            // Enhanced Progress Section
            enhancedProgressSection
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    var premiumAIHub: some View {
        VStack(spacing: 30) {
            // Multi-layer animated AI core
            ZStack {
                // Outer rotating rings (4 layers)
                ForEach(0..<4) { index in
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.clear,
                                    Color.appYellow.opacity(0.8 - Double(index) * 0.15),
                                    Color.clear,
                                    Color.appYellow.opacity(0.4 - Double(index) * 0.1),
                                    Color.clear
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 140 + CGFloat(index * 30))
                        .rotationEffect(.degrees(viewModel.isPulsing ? Double(index * 90) : Double(-index * 45)))
                        .animation(
                            .linear(duration: 4 - Double(index) * 0.5)
                                .repeatForever(autoreverses: false),
                            value: viewModel.isPulsing
                        )
                        .opacity(0.7 - Double(index) * 0.1)
                }
                
                // Pulsing data nodes around the core
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.appYellow.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .position(
                            x: 70 + 50 * cos(Double(index) * .pi / 4),
                            y: 70 + 50 * sin(Double(index) * .pi / 4)
                        )
                        .scaleEffect(viewModel.isPulsing ? 1.5 : 0.3)
                        .opacity(viewModel.isPulsing ? 0.9 : 0.3)
                        .animation(
                            .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: viewModel.isPulsing
                        )
                }
                
                // Central core with multiple layers
                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.appYellow.opacity(0.6),
                                    Color.appYellow.opacity(0.3),
                                    Color.appYellow.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(viewModel.isPulsing ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                    
                    // Main core circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appYellow.opacity(0.4),
                                    Color.appYellow.opacity(0.2),
                                    Color.appYellow.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.appYellow.opacity(0.8), Color.appYellow.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .scaleEffect(viewModel.isPulsing ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                    
                    // Animated brain icon with multiple effects
                    ZStack {
                        // Icon shadow/glow
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.appYellow.opacity(0.3))
                            .offset(x: 2, y: 2)
                            .scaleEffect(viewModel.isPulsing ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                        
                        // Main brain icon
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.appYellow)
                            .rotationEffect(.degrees(viewModel.isPulsing ? 5 : -5))
                            .scaleEffect(viewModel.isPulsing ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                        
                        // Sparkling effect around brain
                        ForEach(0..<6, id: \.self) { index in
                            Image(systemName: "sparkle")
                                .font(.system(size: 8))
                                .foregroundColor(.appYellow.opacity(0.8))
                                .position(
                                    x: 21 + 25 * cos(Double(index) * .pi / 3),
                                    y: 21 + 25 * sin(Double(index) * .pi / 3)
                                )
                                .scaleEffect(viewModel.isPulsing ? 1.5 : 0.5)
                                .opacity(viewModel.isPulsing ? 1 : 0.3)
                                .animation(
                                    .easeInOut(duration: 1.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: viewModel.isPulsing
                                )
                        }
                    }
                }
                
                // Binary data stream effect
                ForEach(0..<12, id: \.self) { index in
                    Text(["1", "0"].randomElement() ?? "1")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.appYellow.opacity(0.6))
                        .position(
                            x: CGFloat.random(in: 20...120),
                            y: CGFloat.random(in: 20...120)
                        )
                        .opacity(viewModel.isPulsing ? 0.8 : 0.2)
                        .animation(
                            .easeInOut(duration: Double.random(in: 0.8...1.5))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: viewModel.isPulsing
                        )
                }
            }
            .frame(width: 240, height: 240)
            
            // Enhanced title section
            VStack(spacing: 16) {
                // Animated title
                HStack(spacing: 0) {
                    ForEach(Array("Analyzing Your Body".enumerated()), id: \.offset) { index, character in
                        Text(String(character))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.appYellow)
                            .scaleEffect(viewModel.isPulsing ? 1.05 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.03),
                                value: viewModel.isPulsing
                            )
                    }
                }
                
                // Subtitle with icons
                HStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .font(.system(size: 14))
                        .foregroundColor(.appYellow)
                        .rotationEffect(.degrees(viewModel.isPulsing ? 180 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: viewModel.isPulsing)
                    
                    Text("AI-Powered Analysis in Progress")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 14))
                        .foregroundColor(.appYellow)
                        .scaleEffect(viewModel.isPulsing ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                }
                
                // Status indicators
                HStack(spacing: 12) {
                    StatusIndicator(text: "CALCULATING", color: .green, isActive: true)
                    StatusIndicator(text: "OPTIMIZING", color: .appYellow, isActive: viewModel.progress > 0.3)
                    StatusIndicator(text: "FINALIZING", color: .blue, isActive: viewModel.progress > 0.7)
                }
            }
        }
    }
    
    var enhancedProgressSection: some View {
        VStack(spacing: 24) {
            // Current step with enhanced styling
            HStack(spacing: 16) {
                ZStack {
                    // Glowing background
                    Circle()
                        .fill(Color.appYellow.opacity(0.3))
                        .frame(width: 55, height: 55)
                        .scaleEffect(viewModel.isPulsing ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                    
                    Circle()
                        .fill(Color.appYellow.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.appYellow.opacity(0.6), lineWidth: 2)
                        )
                    
                    Image(systemName: viewModel.getCurrentStepIcon())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appYellow)
                        .rotationEffect(.degrees(viewModel.isPulsing ? 360 : 0))
                        .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: viewModel.isPulsing)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("STEP \(viewModel.currentStepIndex + 1) OF \(viewModel.totalSteps)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.appYellow.opacity(0.8))
                        .tracking(1.5)
                    
                    Text(viewModel.currentStep)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
                }
                
                Spacer()
                
                // Animated percentage
                VStack(spacing: 2) {
                    Text("\(Int(viewModel.progress * 100))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appYellow)
                        .scaleEffect(viewModel.progress > 0 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                    
                    Text("%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appYellow.opacity(0.8))
                }
            }
            
            // Enhanced progress bar
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow, Color.orange, Color.red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: (UIScreen.main.bounds.width - 40) * viewModel.progress, height: 18)
                        .animation(.easeInOut(duration: 0.8), value: viewModel.progress)
                        .overlay(
                            // Shimmer effect
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.clear, Color.white.opacity(0.6), Color.clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 60)
                                .offset(x: viewModel.isPulsing ? 200 : -200)
                                .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: viewModel.isPulsing)
                        )
                }
                
                // Progress milestones
                HStack {
                    Text("Starting")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Optimizing")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(viewModel.progress > 0.5 ? .appYellow : .gray)
                    
                    Spacer()
                    
                    Text("Complete")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(viewModel.progress > 0.9 ? .green : .gray)
                }
            }
        }
    }
}

// MARK: - Status Indicator Component
struct StatusIndicator: View {
    let text: String
    let color: Color
    let isActive: Bool
    
    @State private var pulse = false
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? color : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
                .scaleEffect(pulse && isActive ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
            
            Text(text)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(isActive ? color : Color.gray.opacity(0.7))
                .tracking(0.5)
        }
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Results View
private extension ShowInfoView {
    var resultsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                successHeader
                personalizedResults
                motivationalStats
                actionButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    var successHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.4), Color.green.opacity(0.1)],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(viewModel.showResults ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: viewModel.showResults)
            }
            
            VStack(spacing: 12) {
                Text("Your Plan is Ready!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("Based on science and your personal data")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(viewModel.showResults ? 1 : 0.8)
            .opacity(viewModel.showResults ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: viewModel.showResults)
        }
        .padding(.top, 20)
    }
    
    var personalizedResults: some View {
        VStack(spacing: 20) {
            ForEach(Array(viewModel.personalizedResults.enumerated()), id: \.offset) { index, result in
                PersonalizedResultCard(
                    result: result,
                    animationDelay: Double(index) * 0.2 + 0.6
                )
            }
        }
    }
    
    var motivationalStats: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.appYellow)
                Text("Expected Timeline")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            TimelineCard(
                timeline: viewModel.expectedTimeline,
                animationDelay: 1.4
            )
        }
        .scaleEffect(viewModel.showResults ? 1 : 0.9)
        .opacity(viewModel.showResults ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.4), value: viewModel.showResults)
    }
    
    var actionButton: some View {
        VStack(spacing: 16) {
            Text("Ready to transform your body?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appYellow)
            
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                navigateToDashboard = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Start Your Journey")
                        .font(.system(size: 18, weight: .bold))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.appYellow, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.appYellow.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .scaleEffect(viewModel.showResults ? 1.0 : 0.8)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(2.0), value: viewModel.showResults)
            
            NavigationLink(
                destination: DashboardView(),
                isActive: $navigateToDashboard
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.top, 10)
    }
}

// MARK: - Personalized Result Card
struct PersonalizedResultCard: View {
    let result: PersonalizedResult
    let animationDelay: Double
    
    @State private var showCard = false
    @State private var iconRotation = 0.0
    @State private var iconScale = 1.0
    @State private var glowOpacity = 0.3
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced animated icon section
            ZStack {
                // Glowing background
                Circle()
                    .fill(result.color.opacity(glowOpacity))
                    .frame(width: 70, height: 70)
                    .scaleEffect(iconScale)
                    .animation(
                        .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: glowOpacity
                    )
                
                // Main circle
                Circle()
                    .fill(result.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(result.color.opacity(0.5), lineWidth: 2)
                    )
                
                // Animated icon
                Image(systemName: result.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(result.color)
                    .rotationEffect(.degrees(iconRotation))
                    .scaleEffect(iconScale)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                            .repeatForever(autoreverses: true),
                        value: iconScale
                    )
            }
            
            // Content section with better spacing
            VStack(alignment: .leading, spacing: 8) {
                Text(result.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(result.value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(result.color)
                    .lineLimit(1)
                
                Text(result.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(nil) // Allow multiple lines
                    .fixedSize(horizontal: false, vertical: true) // Prevent text cutting
            }
            
            Spacer()
            
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 30, height: 30)
                    .scaleEffect(showCard ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(animationDelay + 0.5), value: showCard)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(showCard ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(animationDelay + 0.7), value: showCard)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(result.color.opacity(0.4), lineWidth: 1)
                )
        )
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(animationDelay), value: showCard)
        .onAppear {
            showCard = true
            startIconAnimations()
        }
    }
    
    private func startIconAnimations() {
        // Continuous glow animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
        }
        
        // Scale pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.3)) {
            iconScale = 1.1
        }
        
        // Subtle rotation for specific icons
        if result.icon.contains("flame") || result.icon.contains("drop") {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false).delay(1.0)) {
                iconRotation = 360
            }
        }
    }
}

// MARK: - Timeline Card
struct TimelineCard: View {
    let timeline: ExpectedTimeline
    let animationDelay: Double
    
    @State private var showCard = false
    @State private var progressAnimation = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced timeline with progress indicator
            HStack(spacing: 20) {
                // First Results
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(showCard ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(1.0), value: showCard)
                        
                        Text("First Results")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text(timeline.firstResults)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                }
                
                // Progress line
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.appYellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                        .scaleEffect(x: progressAnimation, y: 1.0, anchor: .leading)
                        .animation(.easeInOut(duration: 2).delay(animationDelay + 0.5), value: progressAnimation)
                }
                
                // Goal Achievement
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Goal Achievement")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Circle()
                            .fill(Color.appYellow)
                            .frame(width: 8, height: 8)
                            .scaleEffect(showCard ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(1.5), value: showCard)
                    }
                    
                    Text(timeline.goalAchievement)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appYellow)
                }
            }
            
            // Enhanced science note section
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "flask.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                            .scaleEffect(showCard ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(2.0), value: showCard)
                    }
                    
                    Text("Scientific Prediction")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("PROVEN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                }
                
                Text(timeline.scienceNote)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(nil) // Allow multiple lines
                    .fixedSize(horizontal: false, vertical: true) // Prevent text cutting
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appYellow.opacity(0.4), lineWidth: 1)
                )
        )
        .scaleEffect(showCard ? 1 : 0.9)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(animationDelay), value: showCard)
        .onAppear {
            showCard = true
            progressAnimation = 1.0
        }
    }
}

// MARK: - Preview
struct ShowInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowInfoView()
        }
        .preferredColorScheme(.dark)
    }
}
