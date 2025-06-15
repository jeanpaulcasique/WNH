import SwiftUI

// MARK: - ShowInfoView
struct ShowInfoView: View {
    @StateObject private var viewModel = ShowInfoViewModel()
    @State private var navigateToDashboard = false

    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.isGeneratingPlan {
                generatingPlanView
            } else {
                profileSummaryView
            }
        }
        .onAppear {
            viewModel.loadData()
            viewModel.startProfileAnalysis()
        }
    }
}

// MARK: - Subviews
private extension ShowInfoView {
    var generatingPlanView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // AI Coach Working Animation
            VStack(spacing: 30) {
                ZStack {
                    // Pulsing circles
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                            .frame(width: 120 + CGFloat(index * 40), height: 120 + CGFloat(index * 40))
                            .scaleEffect(viewModel.isPulsing ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 1.5 + Double(index) * 0.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                value: viewModel.isPulsing
                            )
                    }
                    
                    // Central AI icon
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.1)],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(viewModel.isPulsing ? 5 : -5))
                            .animation(
                                Animation.easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true),
                                value: viewModel.isPulsing
                            )
                    }
                }
                
                Text("Your AI Coach is Working")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
                    .scaleEffect(viewModel.isPulsing ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: viewModel.isPulsing
                    )
                
                Text("Analyzing your data to create the perfect plan")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Generation Progress
            VStack(spacing: 20) {
                // Progress bar
                VStack(spacing: 12) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.planGenerationProgress * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.planGenerationProgress, height: 12)
                                .animation(.easeInOut(duration: 0.5), value: viewModel.planGenerationProgress)
                        }
                    }
                    .frame(height: 12)
                }
                
                // Current step
                Text(viewModel.currentGenerationStep)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentGenerationStep)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    var profileSummaryView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                headerSection
                profileSectionsView
                
                if viewModel.showDashboardButton {
                    dashboardButtonSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            // Success icon
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
            }
            
            VStack(spacing: 12) {
                Text("Your Profile is Ready!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                
                Text("Here's your personalized fitness profile")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    var profileSectionsView: some View {
        VStack(spacing: 20) {
            ForEach(0..<viewModel.visibleSections, id: \.self) { index in
                if index < viewModel.profileSections.count {
                    ProfileSectionCard(section: viewModel.profileSections[index])
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
    }
    
    var dashboardButtonSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Ready to start your journey?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("Your personalized workouts and nutrition plan await!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                navigateToDashboard = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Enter Your Dashboard")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.yellow.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .scaleEffect(viewModel.showDashboardButton ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: viewModel.showDashboardButton)
            
            NavigationLink(
                destination: DashboardView(),
                isActive: $navigateToDashboard
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.top, 20)
    }
}

// MARK: - ProfileSectionCard
struct ProfileSectionCard: View {
    let section: ProfileSection
    
    var body: some View {
        VStack(spacing: 0) {
            // Section header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(section.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: section.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(section.color)
                }
                
                Text(section.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            .padding(20)
            
            // Section items
            VStack(spacing: 12) {
                ForEach(section.items.indices, id: \.self) { index in
                    HStack {
                        Text(section.items[index].key)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(section.items[index].value)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(section.color)
                    }
                    .padding(.vertical, 4)
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(section.color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: section.color.opacity(0.2), radius: 8, x: 0, y: 4)
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
