import SwiftUI

// MARK: - Botón animado al presionar
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - DietView
struct DietView: View {
    @StateObject private var vm = DietViewModel()
    @StateObject private var daySelectorVM = DaySelectorViewModel()
    @StateObject private var todaysMealsVM = TodaysMealsViewModel()
    enum ActiveSheet: Identifiable {
        case grocery, scanner, water
        var id: Int {
            hashValue
        }
    }
    @State private var activeSheet: ActiveSheet?
    @State private var headerScale: CGFloat = 1.0
    @State private var showCalorieAlert = false
    @State private var userName: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
            
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header title section - Aligned with other screens
                    VStack(spacing: 5) { // Reduced spacing from 16 to 5
                        HStack(spacing: 12) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.yellow)
                            
                            Text("Samson's Diet")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)
                  
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            headerSection
                            
                            nutritionOverviewSection
                                .padding(.top, -10) // Increased negative padding to reduce more space
                            
                            DaySelectorView(viewModel: daySelectorVM)
                                .padding(.top, 10)
                                .opacity(vm.showSelectors ? 1 : 0)
                                .offset(y: vm.showSelectors ? 0 : 20)

                            TodaysMealsView(viewModel: todaysMealsVM)
                                .padding(.top, 10)
                                .opacity(vm.showSelectors ? 1 : 0)
                                .offset(y: vm.showSelectors ? 0 : 20)
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Floating buttons
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Spacer()
                        // Food scanner button
                        Button(action: {
                            activeSheet = .scanner
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 24))
                                .foregroundColor(.appBlack)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Color.appYellow)
                                .cornerRadius(18)
                                .shadow(color: Color.appYellow.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        
                        groceryFloatingButton
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .accentColor(.appYellow)
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { item in
            switch item {
            case .grocery:
                GroceryListSheetView2(groceryListViewModel: vm.groceryListViewModel)
            case .scanner:
                FoodScannerView()
            case .water:
                WaterInfoSheet()
            }
        }
        .alert("Calorie Target", isPresented: $showCalorieAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your daily target is \(Int(vm.getDailyCaloriesTarget())) calories")
        }
        .onAppear {
            Task {
                await vm.loadRecipesForSelectedDiet()
            }
            setupViewModels()
            animateViewIn()
        }
    }
    
    private func setupViewModels() {
        // Obtener nombre del usuario
        userName = UserDefaults.standard.string(forKey: "userName")
        
        // Sincronizar el día seleccionado entre los ViewModels
        daySelectorVM.$selectedDay
            .sink { [weak todaysMealsVM] day in
                todaysMealsVM?.updateSelectedDay(day)
            }
            .store(in: &vm.cancellables)
        
        // Sincronizar las recetas semanales
        vm.$weeklyRecipes
            .sink { [weak todaysMealsVM] recipes in
                todaysMealsVM?.updateWeeklyRecipes(recipes)
            }
            .store(in: &vm.cancellables)
    }
}

// MARK: - Animated States
extension DietView {
    private func animateViewIn() {
        // Staggered animation for cards
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0).delay(0.2)) {
            vm.showNutritionCards = true
        }
        
        // Staggered animation for selectors
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0).delay(0.3)) {
            vm.showSelectors = true
        }
    }
}

// MARK: - Sections
private extension DietView {
    
    var headerSection: some View {
        DietInfoCardView()
            .padding(.top, -25) // Negative padding to move cards up to desired distance
    }
    
    var nutritionOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Overview")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            .padding(.top, 2)
            
            VStack(spacing: 12) {
                // Calories card
                nutritionCard(
                    icon: "flame.fill",
                    title: "Daily Target",
                    value: "\(Int(vm.getDailyCaloriesTarget()))",
                    subtitle: "kcal",
                    color: .orange,
                    action: { showCalorieAlert = true }
                )
                
                // Water card
                nutritionCard(
                    icon: "drop.fill",
                    title: "Water Goal",
                    value: vm.calculateRecommendedWaterIntake(),
                    subtitle: "recommended",
                    color: .cyan,
                    action: { activeSheet = .water }
                )
            }
            .opacity(vm.showNutritionCards ? 1 : 0)
            .offset(y: vm.showNutritionCards ? 0 : 20)
        }
    }
    
    var groceryFloatingButton: some View {
        Button(action: {
            activeSheet = .grocery
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 1) {
                ZStack {
                    Circle()
                        .fill(Color.appYellow)
                        .frame(width: 50, height: 35)
                        .shadow(color: Color.appYellow.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.appBlack)
                    
                    if !vm.isGroceryListEmpty {
                        withAnimation {
                            Circle()
                                .fill(vm.isGroceryListCompleted ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.appBlack, lineWidth: 1)
                                )
                                .offset(x: 12, y: -6)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 9)
            .background(Color.appYellow)
            .cornerRadius(18)
            .shadow(color: Color.appYellow.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Reusable Components
    @ViewBuilder
    private func nutritionCard(icon: String, title: String, value: String, subtitle: String, color: Color, action: (() -> Void)?) -> some View {
        let cardContent = HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .frame(width: 45, height: 45)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                (Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color) +
                 Text(" \(subtitle)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7)))
            }
            
            Spacer()
            
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.6), color.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
        
        if let action = action {
            Button(action: action) {
                cardContent
            }
            .buttonStyle(PressableButtonStyle())
        } else {
            cardContent
        }
    }
}

// MARK: - Preview
struct DietView_Previews: PreviewProvider {
    static var previews: some View {
        DietView()
            .preferredColorScheme(.dark)
    }
}
