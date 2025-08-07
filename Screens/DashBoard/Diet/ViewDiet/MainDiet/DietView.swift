import SwiftUI

// MARK: - Tips de dieta animados (ESPAÑOL)
private let dietTips: [String] = [
    "¡Mantén tu cuerpo hidratado! Bebe agua antes de cada comida.",
    "Come proteínas magras en cada comida para mantener la masa muscular.",
    "Incluye vegetales de colores en tu plato para obtener más nutrientes.",
    "Planifica tus comidas con anticipación para evitar decisiones impulsivas.",
    "Mastica lentamente y disfruta cada bocado para mejor digestión.",
    "¡No te saltes el desayuno! Es la comida más importante del día.",
    "Incluye grasas saludables como aguacate y nueces en tu dieta.",
    "Controla las porciones usando platos más pequeños.",
    "Cocina en casa más seguido para controlar ingredientes y calorías.",
    "¡Escucha a tu cuerpo! Come cuando tengas hambre, para cuando estés satisfecho."
]

// MARK: - Botón animado al presionar
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - DietView con estilo MeView
struct DietView: View {
    @StateObject private var vm = DietViewModel()
    @StateObject private var daySelectorVM = DaySelectorViewModel()
    @StateObject private var todaysMealsVM = TodaysMealsViewModel()
    @State private var showGrocerySheet = false
    @State private var showFoodScanner = false
    @State private var showWaterAlert = false
    @State private var headerScale: CGFloat = 1.0
    @State private var showCalorieAlert = false
    @State private var currentTipIndex = 0
    @State private var animateTip = false
    @State private var userName: String? = nil

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
                    VStack(spacing: 10) {
                        // Header title section
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.appYellow)
                                
                                Text("Samson's Diet")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        
                        headerSection
                        nutritionOverviewSection
                        
                        DaySelectorView(viewModel: daySelectorVM)
                            .opacity(vm.showSelectors ? 1 : 0)
                            .offset(y: vm.showSelectors ? 0 : 20)

                        TodaysMealsView(viewModel: todaysMealsVM)
                            .opacity(vm.showSelectors ? 1 : 0)
                            .offset(y: vm.showSelectors ? 0 : 20)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Floating buttons
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Spacer()
                        // Food scanner button
                        Button(action: {
                            showFoodScanner = true
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
        .sheet(isPresented: $showGrocerySheet) {
            GroceryListSheetView2(groceryListViewModel: vm.groceryListViewModel)
        }
        .sheet(isPresented: $showFoodScanner) {
            FoodScannerView()
        }
        .sheet(isPresented: $showWaterAlert) {
            WaterInfoSheet()
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
        
        // Iniciar animación de tips
        animateTip = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animateTip = true
        }
        startTipTimer()
    }
    
    private func startTipTimer() {
        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                animateTip = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let isLast = currentTipIndex == dietTips.count - 1
                if isLast {
                    Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                        currentTipIndex = 0
                        animateTip = true
                        startTipTimer()
                    }
                } else {
                    currentTipIndex = (currentTipIndex + 1)
                    animateTip = true
                    startTipTimer()
                }
            }
        }
    }
}

// MARK: - Sections
private extension DietView {
    
    var headerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<dietTips.count, id: \.self) { index in
                    dietTipCard(tip: dietTips[index])
                }
            }
            .padding(.horizontal, 3)
        }
        .padding(.top, 10)
        .padding(.bottom, 0)
    }
    
    private func dietTipCard(tip: String) -> some View {
        Text(tip)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.appWhite.opacity(0.85))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: 280, height: 80)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .shadow(color: Color.appYellow.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    var nutritionOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Overview")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
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
                    action: { showWaterAlert = true }
                )
            }
            .opacity(vm.showNutritionCards ? 1 : 0)
            .offset(y: vm.showNutritionCards ? 0 : 20)
        }
    }
    
    var groceryFloatingButton: some View {
        Button(action: {
            showGrocerySheet = true
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

