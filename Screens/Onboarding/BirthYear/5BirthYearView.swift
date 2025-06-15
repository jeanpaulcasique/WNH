import SwiftUI
import UIKit
import Combine

struct BirthYearView: View {
    @StateObject var viewModel: BirthYearViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isNavigatingToNextScreen = false
    @State private var isLoading = false
    @State private var isDisabled = false
    @State private var showSelectionAnimation = false
    @State private var selectedDecade: Int = 1990
    @State private var showDecadeSelector = false
    @State private var showCategorySheet = false
    
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
                    ageDisplaySection
                    yearSelectionSection
                    motivationalSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Next button overlay
            VStack {
                Spacer()
                nextButtonSection
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)
            }
        }
    
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.selectedYear = UserDefaults.standard.integer(forKey: "selectedBirthYear")
            selectedDecade = (viewModel.selectedYear / 10) * 10
        }
        .sheet(isPresented: $showCategorySheet) {
            CategoryExplanationSheet(
                userCategory: viewModel.fitnessCategory,
                userAge: viewModel.calculatedAge
            )
        }
        .overlay(
            // Success animation overlay
            Group {
                if showSelectionAnimation {
                    BirthYearSelectionSuccessView(age: viewModel.calculatedAge)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension BirthYearView {
    
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
            // Animated calendar icon
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
                
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedYear)
            }
            
            VStack(spacing: 12) {
                Text("What's your birth year?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                Text("We'll customize your fitness plan based on your age and experience level")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.top, 10)
    }
    
    var ageDisplaySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Information")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            HStack(spacing: 20) {
                AgeInfoCard(
                    title: "Birth Year",
                    value: "\(viewModel.selectedYear)",
                    subtitle: "Selected",
                    color: .blue
                )
                
                AgeInfoCard(
                    title: "Current Age",
                    value: "\(viewModel.calculatedAge)",
                    subtitle: "years old",
                    color: .green
                )
                
                TappableAgeInfoCard(
                    title: "Fitness Level",
                    value: viewModel.fitnessCategory,
                    subtitle: "category",
                    color: .purple
                ) {
                    showCategorySheet = true
                }
            }
        }
    }
    
    var yearSelectionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Select Your Birth Year")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDecadeSelector.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.minus")
                            .font(.system(size: 14))
                        Text("Jump to decade")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.appYellow.opacity(0.8))
                }
            }
            
            VStack(spacing: 16) {
                if showDecadeSelector {
                    DecadeSelectorView(selectedDecade: $selectedDecade) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDecadeSelector = false
                            viewModel.selectedYear = selectedDecade
                        }
                    }
                    .transition(.opacity.combined(with: .slide))
                }
                
                // Enhanced year picker
                yearPickerSection
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    var yearPickerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Fine-tune your year")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.8))
                Spacer()
                Text("\(viewModel.selectedYear)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.appYellow)
            }
            
            Picker("Birth Year", selection: $viewModel.selectedYear) {
                ForEach(viewModel.birthYearRange, id: \.self) { year in
                    Text(String(year))
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundColor(.appWhite)
                        .tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            .onChange(of: viewModel.selectedYear) { _ in
                generateHapticFeedback()
                showSelectionFeedback()
            }
        }
    }
    
    var motivationalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Age-Specific Benefits")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                AgeBenefitCard(
                    icon: "heart.fill",
                    title: "Personalized Intensity",
                    description: "Workouts adapted to your age and recovery needs",
                    color: .red
                )
                
                AgeBenefitCard(
                    icon: "figure.strengthtraining.traditional",
                    title: "Safe Progression",
                    description: "Exercise recommendations based on your life stage",
                    color: .blue
                )
                
                AgeBenefitCard(
                    icon: "brain.head.profile",
                    title: "Experience Matching",
                    description: "Training complexity suited to your fitness journey",
                    color: .purple
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
                isDisabled: $isDisabled
            )
            
            NavigationLink(
                destination: HeightView(viewModel: HeightViewModel(), progressViewModel: progressViewModel),
                isActive: $isNavigatingToNextScreen
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
    
    // MARK: - Actions
    func proceedToNext() {
        withAnimation {
            progressViewModel.advanceProgress()
        }
        generateHapticFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isNavigatingToNextScreen = true
        }
    }
    
    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func showSelectionFeedback() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSelectionAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSelectionAnimation = false
            }
        }
    }
}

// MARK: - Supporting Views
struct AgeInfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TappableAgeInfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.6))
                
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(color.opacity(0.8))
                    Text("Tap to learn")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(color.opacity(0.8))
                }
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DecadeSelectorView: View {
    @Binding var selectedDecade: Int
    let onSelect: () -> Void
    
    let decades = [1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020]
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Jump to decade")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(decades, id: \.self) { decade in
                    Button(action: {
                        selectedDecade = decade
                        onSelect()
                    }) {
                        VStack(spacing: 4) {
                            Text("\(decade)s")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedDecade >= decade && selectedDecade < decade + 10 ? .appBlack : .appWhite)
                            
                            Text("\(decade)-\(decade + 9)")
                                .font(.system(size: 10))
                                .foregroundColor(selectedDecade >= decade && selectedDecade < decade + 10 ? .appBlack.opacity(0.7) : .appWhite.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedDecade >= decade && selectedDecade < decade + 10 ?
                            Color.appYellow : Color.gray.opacity(0.2)
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct AgeBenefitCard: View {
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
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BirthYearSelectionSuccessView: View {
    let age: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Age \(age) - Perfect!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite)
                }
                
                Text("Fitness plan optimized for your age group")
                    .font(.system(size: 11))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Category Sheet
struct CategoryExplanationSheet: View {
    let userCategory: String
    let userAge: Int
    
    @Environment(\.presentationMode) var presentationMode
    
    private var categoryColor: Color {
        switch userCategory {
        case "Youth": return .green
        case "Peak": return .red
        case "Prime": return .purple
        case "Mature": return .blue
        default: return .orange
        }
    }
    
    private var categoryIcon: String {
        switch userCategory {
        case "Youth": return "figure.run"
        case "Peak": return "flame.fill"
        case "Prime": return "star.fill"
        case "Mature": return "brain.head.profile"
        default: return "crown.fill"
        }
    }
    
    private var categoryExplanation: String {
        switch userCategory {
        case "Youth":
            return "Your body is incredibly adaptable and recovers quickly. Perfect time to build healthy habits and develop a strong foundation for lifelong fitness."
        case "Peak":
            return "You're at peak physical potential with maximum strength, endurance, and recovery. Ideal for high-intensity training and serious muscle building."
        case "Prime":
            return "You have the perfect balance of experience, discipline, and physical capability. Your body is still highly responsive to smart training."
        case "Mature":
            return "Your experience and consistency are valuable assets. Focus on strategic training emphasizing mobility, strength maintenance, and injury prevention."
        default:
            return "Your dedication to fitness is inspiring. Workouts focus on maintaining independence, mobility, and quality of life with sustainable strength."
        }
    }
    
    private var categoryAdvantages: [String] {
        switch userCategory {
        case "Youth":
            return ["Lightning-fast recovery", "Peak adaptability", "Habit formation", "Natural growth hormones"]
        case "Peak":
            return ["Maximum muscle potential", "Peak cardiovascular power", "Optimal hormone levels", "Superior recovery"]
        case "Prime":
            return ["Experience + strength", "Mental discipline", "Body awareness", "Strategic training"]
        case "Mature":
            return ["Life experience wisdom", "Quality over quantity", "Stress management", "Injury prevention focus"]
        default:
            return ["Inspiring dedication", "Functional focus", "Mobility emphasis", "Age ≠ limits"]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                                            center: .center,
                                            startRadius: 40,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: categoryIcon)
                                    .font(.system(size: 50))
                                    .foregroundColor(categoryColor)
                            }
                            
                            VStack(spacing: 12) {
                                Text("\(userCategory) Category")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.appYellow)
                                
                                Text("Age \(userAge) - Your Fitness Journey")
                                    .font(.system(size: 16))
                                    .foregroundColor(.appWhite.opacity(0.8))
                            }
                        }
                        
                        // Explanation
                        VStack(spacing: 16) {
                            HStack {
                                Text("What This Means")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.appYellow)
                                Spacer()
                            }
                            
                            Text(categoryExplanation)
                                .font(.system(size: 16))
                                .foregroundColor(.appWhite.opacity(0.9))
                                .lineSpacing(6)
                                .padding(20)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                        }
                        
                        // Advantages
                        VStack(spacing: 16) {
                            HStack {
                                Text("Your Superpowers")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.appYellow)
                                Spacer()
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(categoryAdvantages, id: \.self) { advantage in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(categoryColor.opacity(0.2))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(categoryColor)
                                        }
                                        
                                        Text(advantage)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.appWhite)
                                        
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Action
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                
                                Text("Ready to Continue!")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [categoryColor, categoryColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Your Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.appYellow)
            )
        }
    }
}

// MARK: - Preview
struct BirthYearView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BirthYearView(
                viewModel: BirthYearViewModel(),
                progressViewModel: ProgressViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
