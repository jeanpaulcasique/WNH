import SwiftUI
import StoreKit

struct RateAppView: View {
    @StateObject private var viewModel = RateAppViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedRating: Int = 0
    @State private var showThankYou = false
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showThankYou {
                ThankYouView {
                    presentationMode.wrappedValue.dismiss()
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                ScrollView {
                    VStack(spacing: 40) {
                        headerSection
                        appIconSection
                        ratingSection
                        benefitsSection
                        actionButtonsSection
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
            }
        }
        .navigationTitle("Rate Our App")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.trackRateAppOpened()
            animateStarsEntrance()
        }
    }
}

// MARK: - Subviews
private extension RateAppView {
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            Text("Love Our App? 💛")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
            Text("Your feedback means the world to us! Help other fitness enthusiasts discover our app by leaving a review.")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    var appIconSection: some View {
        VStack(spacing: 20) {
            // App icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow, Color.yellow.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.appYellow.opacity(0.5), radius: 20, x: 0, y: 10)
                    .overlay(
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.black)
                    )
            }
            .scaleEffect(animateStars ? 1.0 : 0.8)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateStars)
            
            VStack(spacing: 8) {
                Text("FitnessApp")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text("Transform Your Body & Mind")
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
        }
    }
    
    var ratingSection: some View {
        VStack(spacing: 24) {
            Text("Rate Your Experience")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.appYellow)
            
            // Interactive star rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedRating = index
                        }
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        // Auto-submit if 5 stars
                        if index == 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                openAppStore()
                            }
                        }
                    }) {
                        Image(systemName: index <= selectedRating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(index <= selectedRating ? .appYellow : .gray.opacity(0.5))
                            .scaleEffect(index <= selectedRating ? 1.1 : 1.0)
                            .rotation3DEffect(
                                .degrees(index <= selectedRating && animateStars ? 360 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                    }
                    .scaleEffect(index == selectedRating ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedRating)
                }
            }
            
            // Rating feedback text
            if selectedRating > 0 {
                Text(ratingFeedbackText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ratingFeedbackColor)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.3), value: selectedRating)
            }
        }
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
    
    var benefitsSection: some View {
        VStack(spacing: 16) {
            Text("Why Your Review Matters")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            
            VStack(spacing: 12) {
                BenefitRow(
                    icon: "heart.fill",
                    text: "Helps us improve and add new features",
                    color: .red
                )
                
                BenefitRow(
                    icon: "person.3.fill",
                    text: "Helps others discover our fitness community",
                    color: .blue
                )
                
                BenefitRow(
                    icon: "star.fill",
                    text: "Takes less than 30 seconds to complete",
                    color: .appYellow
                )
            }
        }
    }
    
    var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary action button
            if selectedRating >= 4 {
                Button(action: openAppStore) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                        
                        Text("Rate on App Store")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.appYellow)
                    .cornerRadius(27)
                    .shadow(color: Color.appYellow.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(selectedRating >= 4 ? 1.0 : 0.95)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedRating)
            } else if selectedRating > 0 && selectedRating < 4 {
                Button(action: {
                    viewModel.showFeedbackForm()
                }) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 18))
                        
                        Text("Send Us Feedback")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.orange)
                    .cornerRadius(27)
                    .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
            
            // Secondary actions
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.remindLater()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Remind Me Later")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                }
                
                Button(action: {
                    viewModel.neverAskAgainR()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("No Thanks")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    var ratingFeedbackText: String {
        switch selectedRating {
        case 1:
            return "We're sorry to hear that. Help us improve!"
        case 2:
            return "We'd love to know how we can do better."
        case 3:
            return "Thanks! What would make it better?"
        case 4:
            return "Great! We'd love a review on the App Store."
        case 5:
            return "Awesome! You're the best! ⭐️"
        default:
            return ""
        }
    }
    
    var ratingFeedbackColor: Color {
        switch selectedRating {
        case 1, 2:
            return .red
        case 3:
            return .orange
        case 4, 5:
            return .green
        default:
            return .appWhite
        }
    }
    
    // MARK: - Actions
    func openAppStore() {
        viewModel.trackRatingGiven(selectedRating)
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            showThankYou = true
        }
        
        // Open App Store after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewModel.openAppStoreReview()
        }
    }
    
    func animateStarsEntrance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateStars = true
            }
        }
    }
}

// MARK: - Supporting Views
struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.appWhite.opacity(0.8))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ThankYouView: View {
    let onComplete: () -> Void
    @State private var animateCheckmark = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(animateCheckmark ? 1.0 : 0.3)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateCheckmark)
            }
            
            VStack(spacing: 16) {
                Text("Thank You! 🙏")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.appYellow)
                    .opacity(animateText ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateText)
                
                Text("Your feedback helps us create an even better fitness experience for everyone!")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateText ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateText)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            animateCheckmark = true
            animateText = true
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
        }
    }
}

// MARK: - Preview
struct RateAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RateAppView()
        }
        .preferredColorScheme(.dark)
    }
}
