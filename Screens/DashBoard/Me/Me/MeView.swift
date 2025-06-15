import SwiftUI


struct MeView: View {
    @StateObject private var viewModel = MeViewModel()
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var showLoginView = false
    @State private var profileImageScale: CGFloat = 1.0
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background matching app style
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        profileHeaderSection
                        statsSection
                        accountSection
                        supportSection
                        logoutSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .accentColor(.appYellow)
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// MARK: - Sections
private extension MeView {
    
    var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Profile Image with animated ring
            ZStack {
                // Animated ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.appYellow, Color.orange, Color.appYellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(viewModel.ringRotation))
                
                // Profile image placeholder
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.appYellow)
                }
                .scaleEffect(profileImageScale)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        profileImageScale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            profileImageScale = 1.0
                        }
                    }
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            
            VStack(spacing: 8) {
                Text("Welcome back!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("Ready to crush your fitness goals?")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCardMe(
                    title: "Workouts",
                    value: "\(viewModel.workoutCount)",
                    subtitle: "completed",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCardMe(
                    title: "Streak",
                    value: "\(viewModel.streakDays)",
                    subtitle: "days",
                    icon: "calendar.badge.checkmark",
                    color: .green
                )
                
                StatCardMe(
                    title: "Level",
                    value: "\(viewModel.userLevel)",
                    subtitle: "fitness",
                    icon: "star.fill",
                    color: .appYellow
                )
            }
        }
    }
    
    var accountSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Account")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.accountSection) { item in
                    navLink(item)
                }
            }
        }
    }
    
    var supportSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Support & More")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.supportSection) { item in
                    navLink(item)
                }
            }
        }
    }
    
    var logoutSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showLogoutConfirmation = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appWhite)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.4))
                }
                .padding(16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Navigation Function
    private func navLink(_ item: MeViewModel.MeMenuItem) -> some View {
        NavigationLink(destination: destination(for: item.title)) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundColor(item.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite)
                    
                    if item.title == "Subscription" && !viewModel.isPremium {
                        Text("Upgrade for premium features")
                            .font(.system(size: 12))
                            .foregroundColor(.appYellow.opacity(0.8))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if item.title == "Subscription" && !viewModel.isPremium {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.4))
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func destination(for title: String) -> some View {
        switch title {
        case "Subscription":
            SubscriptionView()
        case "Coaches":
            PlaceholderView(title: title) // Solo esta porque Coaches no existe aún
        case "Analytics":
            AnalyticsView()
        case "Write to support":
            WriteTSView()
        case "Tell a friend":
            TellAFView()
        case "Rate the app":
            RateAppView()
        case "Settings":
            SettingsView()
        default:
            PlaceholderView(title: title)
        }
    }
    
    // MARK: - Actions
    func performLogout() {
        showLoginView = true
        sessionManager.logout()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Supporting Views
struct StatCardMe: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appWhite)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.8))
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - PlaceholderView (solo para Coaches que no existe)
struct PlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            // Gradient background matching app style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Icon
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
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appYellow)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appYellow)
                    
                    Text("Coming Soon")
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("This feature is under development and will be available in a future update.")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
// MARK: - Preview
struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
            .environmentObject(UserSessionManager()) // Asegúrate de inyectar el sessionManager
            .preferredColorScheme(.dark)
    }
}
