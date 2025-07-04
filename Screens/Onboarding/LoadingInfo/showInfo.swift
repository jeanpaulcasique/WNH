// MARK: - Minimalist ShowInfoView
import SwiftUI

struct ShowInfoView: View {
    @StateObject private var viewModel = ShowInfoViewModel()
    @State private var navigateToDashboard = false

    var body: some View {
        ZStack {
            // Minimalist background
            minimalistBackground
            
            if viewModel.isGeneratingPlan {
                minimalistLoadingView
            } else {
                minimalistResultsView
            }
        }
        .onAppear {
            viewModel.loadUserData()
            viewModel.startAnalysis()
        }
    }
}

// MARK: - Minimalist Background
private extension ShowInfoView {
    var minimalistBackground: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [
                    Color.black,
                    Color.gray.opacity(0.1),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle animated dots
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.appYellow.opacity(0.1))
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                        value: UUID()
                    )
            }
        }
    }
}

// MARK: - Minimalist Loading View
private extension ShowInfoView {
    var minimalistLoadingView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Minimalist AI core
            minimalistAICore
            
            // Current step
            currentStepView
            
            Spacer()
            
            // Progress indicator
            minimalistProgressView
        }
        .padding(.horizontal, 30)
    }
    
    var minimalistAICore: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                .frame(width: 120, height: 120)
                .scaleEffect(viewModel.isPulsing ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.isPulsing)
            
            // Inner core
            Circle()
                .fill(Color.appYellow.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.appYellow)
                        .opacity(viewModel.isPulsing ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: viewModel.isPulsing)
                )
        }
    }
    
    var currentStepView: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentStep)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Step indicator
            HStack(spacing: 8) {
                ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.currentStepIndex ? Color.appYellow : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .scaleEffect(index == viewModel.currentStepIndex ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStepIndex)
                }
            }
        }
    }
    
    var minimalistProgressView: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 3)
                    
                    Rectangle()
                        .fill(Color.appYellow)
                        .frame(width: geometry.size.width * viewModel.progress, height: 3)
                        .animation(.easeInOut(duration: 0.6), value: viewModel.progress)
                }
            }
            .frame(height: 3)
            
            Text("\(Int(viewModel.progress * 100))% Complete")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Minimalist Results View
private extension ShowInfoView {
    var minimalistResultsView: some View {
        VStack(spacing: 0) {
            // Header
            minimalistHeader
            
            // Key metrics
            keyMetricsSection
            
            // Action button
            actionButton
        }
        .padding(.horizontal, 20)
    }
    
    var minimalistHeader: some View {
        VStack(spacing: 20) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(viewModel.showResults ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: viewModel.showResults)
            }
            
            VStack(spacing: 8) {
                Text("Plan Ready!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your personalized fitness journey begins now")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 40)
        .scaleEffect(viewModel.showResults ? 1 : 0.8)
        .opacity(viewModel.showResults ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: viewModel.showResults)
    }
    
    var keyMetricsSection: some View {
        VStack(spacing: 24) {
            // Daily calories - Main metric
            mainMetricCard
            
            // Quick stats
            quickStatsRow
        }
        .padding(.top, 40)
        .opacity(viewModel.showResults ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: viewModel.showResults)
    }
    
    var mainMetricCard: some View {
        VStack(spacing: 16) {
            Text("Daily Target")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text("\(Int(viewModel.dailyCalories))")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.appYellow)
            
            Text("calories")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    var quickStatsRow: some View {
        HStack(spacing: 20) {
            quickStatCard(
                title: "Water",
                value: viewModel.dailyWater,
                icon: "drop.fill",
                color: .blue
            )
            
            quickStatCard(
                title: "Timeline",
                value: viewModel.expectedTimeline.firstResults,
                icon: "clock.fill",
                color: .green
            )
        }
    }
    
    func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    var actionButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                navigateToDashboard = true
            }) {
                HStack(spacing: 12) {
                    Text("Start Journey")
                        .font(.system(size: 18, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appYellow)
                )
            }
            .scaleEffect(viewModel.showResults ? 1.0 : 0.8)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.0), value: viewModel.showResults)
            
            NavigationLink(
                destination: DashboardView(),
                isActive: $navigateToDashboard
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.top, 40)
        .padding(.bottom, 40)
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
