import SwiftUI
import Combine

// MARK: - DietTypeView
struct DietTypeView: View {
    @StateObject private var viewModel = DietTypeViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDietForInfo: DietDetails? = nil
    @State private var showCardsAnimation = false
    @State private var showHeaderAnimation = false

    var body: some View {
        ZStack {
            backgroundGradient
            mainContent
            nextButtonOverlay
        }
       
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear { setupAnimations() }
        .sheet(item: $selectedDietForInfo) { dietDetails in
            EpicDietInfoView(dietDetails: dietDetails)
        }
    }
}

// MARK: - Main Content
private extension DietTypeView {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var mainContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                progressSection
                headerSection
                dietCardsSection
                quickComparisonSection
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
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            if showHeaderAnimation {
                dietIcon
                headerText
            }
        }
        .padding(.top, 15)
    }
    
    var dietIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.appYellow.opacity(0.4), Color.appYellow.opacity(0.1)],
                        center: .center,
                        startRadius: 30,
                        endRadius: 70
                    )
                )
                .frame(width: 120, height: 120)
            
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.appYellow)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    var headerText: some View {
        VStack(spacing: 12) {
            Text("Which diet suits your goal?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
        
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    var dietCardsSection: some View {
        VStack(spacing: 20) {
            if showCardsAnimation {
                sectionHeader
                dietCardsScrollView
            }
        }
    }
    
    var sectionHeader: some View {
        HStack {
            Text("Select Your Diet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appYellow)
            
            Spacer()
            
            Text("Tap for details")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
    }
    
    var dietCardsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<viewModel.imageCount, id: \.self) { index in
                    EpicDietCard(
                        imageName: viewModel.imageNames[index],
                        title: viewModel.titles[index],
                        shortDescription: viewModel.shortDescriptions[index],
                        detailedDescription: viewModel.detailedDescriptions[index],
                        isSelected: index == viewModel.currentIndex,
                        dietDetails: viewModel.getDietDetails(for: index),
                        onTap: { handleDietSelection(index) },
                        onLearnMore: {
                            selectedDietForInfo = viewModel.getDietDetails(for: index)
                        }
                    )
                    .frame(width: 260, height: 340)
                }
            }
            .padding(.horizontal, 20)
        }
        .transition(.move(edge: .leading).combined(with: .opacity))
    }
    
    var quickComparisonSection: some View {
        VStack(spacing: 16) {
            if showCardsAnimation {
                VStack(spacing: 12) {
                    HStack {
                        Text("Quick Comparison")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appYellow)
                        Spacer()
                    }
                    
                    QuickComparisonCard(viewModel: viewModel)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
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
    }
}

// MARK: - Helper Functions
private extension DietTypeView {
    func setupAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showHeaderAnimation = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showCardsAnimation = true
            }
        }
    }
    
    func handleDietSelection(_ index: Int) {
        print("🔥 Tocaste la dieta índice: \(index)")
        // Solo actualizar selección, no abrir sheet
        viewModel.selectDiet(index)
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
