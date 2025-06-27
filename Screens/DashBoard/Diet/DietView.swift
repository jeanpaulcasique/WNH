import SwiftUI

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
    @State private var headerScale: CGFloat = 1.0
    @State private var showCalorieAlert = false

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
                
                // Floating grocery button
                VStack {
                    Spacer()
                    groceryFloatingButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .accentColor(.appYellow)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showGrocerySheet) {
            GroceryListSheetView(vm: vm)
        }
        .alert("Calorie Target", isPresented: $showCalorieAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your daily target is \(Int(vm.getDailyCaloriesTarget())) calories")
        }
        .onAppear {
            vm.loadRecipesForSelectedDiet()
            setupViewModels()
            animateViewIn()
        }
    }
    
    private func setupViewModels() {
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
        VStack(spacing: 20) {
            // Diet icon with animated ring (similar to profile section)
            ZStack {
                // Animated ring (reusing the animation pattern from MeView)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.appYellow, Color.orange, Color.appYellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(vm.ringRotation))
                
                // Diet icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appYellow)
                }
                .scaleEffect(headerScale)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        headerScale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            headerScale = 1.0
                        }
                    }
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            
            VStack(spacing: 8) {
                Text("\(vm.selectedDiet) Plan")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("Fuel your body right")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
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
                    action: nil
                )
            }
            .opacity(vm.showNutritionCards ? 1 : 0)
            .offset(y: vm.showNutritionCards ? 0 : 20)
        }
    }
    
    var groceryFloatingButton: some View {
        Button(action: {
            showGrocerySheet = true
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 10) {
                // Carrito de compras
                ZStack {
                    Circle()
                        .fill(Color.appYellow)
                        .frame(width: 65, height: 45)
                        .shadow(color: Color.appYellow.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.bottom, 3)
                    
                    // Icono del carrito
                    Image(systemName: "cart.fill")
                        .font(.system(size: 19))
                        .foregroundColor(.appBlack)
                    
                    // Indicador de progreso
                    if !vm.isGroceryListEmpty {
                        Circle()
                            .fill(vm.isGroceryListCompleted ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.appBlack, lineWidth: 1)
                            )
                            .offset(x: 15, y: -8)
                    }
                }
                
                // Texto y contador
                VStack(alignment: .leading, spacing: 0) {
                    Text("Grocery")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appBlack)
                    
                    if !vm.isGroceryListEmpty {
                        Text("\(vm.groceryListCheckedCount)/\(vm.groceryListTotalCount)")
                            .font(.system(size: 11))
                            .foregroundColor(.appBlack.opacity(0.7))
                    }
                }
                .padding(.leading, 0)
                
                // Flecha
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appBlack.opacity(0.7))
                    .padding(.leading, 3)
                }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.appYellow)
            .cornerRadius(22)
            .shadow(color: Color.appYellow.opacity(0.3), radius: 8, x: 0, y: 4)
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

