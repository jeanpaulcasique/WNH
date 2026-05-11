// MARK: - Modern ShowInfoView - Completely Redesigned
import SwiftUI

struct ShowInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: UserSessionManager
    @StateObject private var viewModel = ShowInfoViewModel()
    @State private var navigateToDashboard = false
    @State private var showContent = false
    @State private var selectedPlan: MembershipPlan? = nil
    @State private var showMembershipSheet = false
    
    var body: some View {
        ZStack {
            // Fondo negro con gradiente (estilo de la app)
            Color.black.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header con logo
                    headerSection
                        .padding(.top, 20)
                    
                    // Contenido principal
                    if viewModel.isGeneratingPlan {
                        loadingSection
                    } else {
                        contentSection
                    }
                }
            }
            
            // Botones de navegación flotantes
            VStack {
                Spacer()
                navigationButtonsSection
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMembershipSheet) {
            MembershipSelectionView(
                selectedPlan: $selectedPlan,
                onPlanSelected: { plan in
                    selectedPlan = plan
                    showMembershipSheet = false
                }
            )
        }
        .onAppear {
            startAnimations()
            viewModel.calculateResults()
        }
    }
}

// MARK: - Header Section
private extension ShowInfoView {
    var headerSection: some View {
        VStack(spacing: 16) {
            // Logo
            Image("samsonWhite")
                .resizable()
                .scaledToFit()
                .frame(width: 140)
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
            
            // Título principal
            VStack(spacing: 8) {
                Text("TU PLAN ESTÁ LISTO")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                Text("Hemos creado un plan personalizado basado en tus datos")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Loading Section
private extension ShowInfoView {
    var loadingSection: some View {
        VStack(spacing: 24) {
            // Animación de carga
            ZStack {
                // Círculos animados
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.6), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120 + CGFloat(index * 30), height: 120 + CGFloat(index * 30))
                        .rotationEffect(.degrees(viewModel.isPulsing ? 360 : 0))
                        .animation(
                            .linear(duration: 2.0 + Double(index) * 0.5)
                                .repeatForever(autoreverses: false),
                            value: viewModel.isPulsing
                        )
                }
                
                // Icono central
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.appYellow)
            }
            .frame(height: 200)
            
            // Texto de progreso
            VStack(spacing: 8) {
                Text(viewModel.currentStep)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appWhite)
                    .multilineTextAlignment(.center)
                
                // Barra de progreso
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appWhite.opacity(0.1))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appYellow, Color.appYellow.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.progress, height: 8)
                            .animation(.easeInOut, value: viewModel.progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Content Section
private extension ShowInfoView {
    var contentSection: some View {
        VStack(spacing: 24) {
            // Sección: Resumen de Peso (NUEVO - Datos exactos)
            weightSummarySection
                .cascadingAppear(index: 0)
            
            // Sección: Análisis de Agua Personalizado
            waterAnalysisSection
                .cascadingAppear(index: 1)
            
            // Sección: Pronóstico y Métricas
            forecastSection
                .cascadingAppear(index: 2)
            
            // Sección: Plan de Acción
            actionPlanSection
                .cascadingAppear(index: 3)
            
            // Sección: Membresía Premium (NUEVO)
            membershipSection
                .cascadingAppear(index: 4)
            
            // Espacio para botones
            Spacer()
                .frame(height: 120)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Weight Summary Section (NUEVO - Datos exactos)
private extension ShowInfoView {
    var weightSummarySection: some View {
        ModernCard(
            title: "TU OBJETIVO DE PESO",
            icon: "target",
            color: .appYellow
        ) {
            VStack(spacing: 20) {
                if let results = viewModel.scientificResults {
                    let currentWeight = viewModel.currentUserProfile?.weightKg ?? 70.0
                    let targetWeight = results.targetWeight
                    let weightDifference = targetWeight - currentWeight
                    let goal = viewModel.currentUserProfile?.goal.lowercased() ?? ""
                    
                    // Peso actual vs objetivo
                    HStack(spacing: 30) {
                        VStack(spacing: 8) {
                            Text("PESO ACTUAL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.appWhite.opacity(0.6))
                            
                            Text(String(format: "%.1f", currentWeight))
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.appWhite)
                            
                            Text("kg")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.7))
                        }
                        
                        // Flecha
                        Image(systemName: weightDifference > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appYellow)
                        
                        VStack(spacing: 8) {
                            Text("PESO OBJETIVO")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.appWhite.opacity(0.6))
                            
                            Text(String(format: "%.1f", targetWeight))
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.appYellow)
                            
                            Text("kg")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 16)
                    
                    Divider()
                        .background(Color.appWhite.opacity(0.2))
                    
                    // Diferencia exacta
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: weightDifference > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(weightDifference > 0 ? .green : .orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(weightDifference > 0 ? "NECESITAS SUBIR" : "NECESITAS BAJAR")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.appWhite.opacity(0.9))
                                
                                Text(String(format: "%.1f kg", abs(weightDifference)))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(weightDifference > 0 ? .green : .orange)
                            }
                            
                            Spacer()
                        }
                        
                        // Tiempo estimado
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundColor(.appYellow)
                            
                            Text("Tiempo estimado: \(results.adjustedTimeToTarget) días")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.8))
                            
                            Spacer()
                        }
                        
                        // Cambio semanal
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("Cambio semanal: \(String(format: "%.2f", abs(results.weeklyWeightChange))) kg/semana")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.8))
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Water Analysis Section
private extension ShowInfoView {
    var waterAnalysisSection: some View {
        ModernCard(
            title: "ANÁLISIS DE AGUA PERSONALIZADO",
            icon: "drop.fill",
            color: .blue
        ) {
            VStack(spacing: 20) {
                // Cantidad recomendada principal
                VStack(spacing: 8) {
                    Text(viewModel.waterAnalysis.recommendedAmount)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("litros diarios")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.7))
                }
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.appWhite.opacity(0.2))
                
                // Desglose del cálculo
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cálculo personalizado:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appWhite.opacity(0.9))
                    
                    ForEach(viewModel.waterAnalysis.breakdown, id: \.id) { item in
                        WaterBreakdownRow(item: item)
                    }
                }
                
                // Beneficios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beneficios para ti:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appWhite.opacity(0.9))
                    
                    ForEach(viewModel.waterAnalysis.benefits, id: \.self) { benefit in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text(benefit)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.8))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Forecast Section
private extension ShowInfoView {
    var forecastSection: some View {
        VStack(spacing: 16) {
            // Título de sección
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("PRONÓSTICO Y PROGRESO")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.appWhite)
                
                Spacer()
            }
            
            // Grid de métricas
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForecastMetricCard(
                    title: "Peso Objetivo",
                    value: String(format: "%.1f", viewModel.forecastData.targetWeight),
                    unit: "kg",
                    icon: "target",
                    color: .appYellow
                )
                
                ForecastMetricCard(
                    title: "Tiempo Estimado",
                    value: "\(viewModel.forecastData.estimatedDays)",
                    unit: "días",
                    icon: "calendar",
                    color: .blue
                )
                
                ForecastMetricCard(
                    title: "Cambio Semanal",
                    value: String(format: "%.2f", abs(viewModel.forecastData.weeklyChange)),
                    unit: "kg/sem",
                    icon: "arrow.trending.down",
                    color: .green
                )
                
                ForecastMetricCard(
                    title: "Probabilidad Éxito",
                    value: "\(Int(viewModel.forecastData.successRate * 100))",
                    unit: "%",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
            }
            
            // Card de calorías diarias
            ModernCard(
                title: "CALORÍAS DIARIAS",
                icon: "flame.fill",
                color: .orange
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(viewModel.forecastData.dailyCalories))")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        
                        Text("kcal por día")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appWhite.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        MacroInfo(label: "Proteína", value: "\(Int(viewModel.forecastData.protein))g", color: .blue)
                        MacroInfo(label: "Carbohidratos", value: "\(Int(viewModel.forecastData.carbs))g", color: .orange)
                        MacroInfo(label: "Grasas", value: "\(Int(viewModel.forecastData.fat))g", color: .yellow)
                    }
                }
            }
        }
    }
}

// MARK: - Action Plan Section
private extension ShowInfoView {
    var actionPlanSection: some View {
        ModernCard(
            title: "TU PLAN DE ACCIÓN",
            icon: "list.bullet.clipboard.fill",
            color: .purple
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.actionPlanItems, id: \.id) { item in
                    ActionPlanRow(item: item)
                }
            }
        }
    }
}

// MARK: - Membership Section (NUEVO)
private extension ShowInfoView {
    var membershipSection: some View {
        ModernCard(
            title: "DESBLOQUEA TODO EL POTENCIAL",
            icon: "crown.fill",
            color: .appYellow
        ) {
            VStack(spacing: 20) {
                // Descripción
                Text("Con una membresía Premium tendrás acceso a:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                    .multilineTextAlignment(.center)
                
                // Beneficios
                VStack(spacing: 16) {
                    MembershipBenefitRow(
                        icon: "dumbbell.fill",
                        title: "Planes de Ejercicios Completos",
                        description: "Rutinas personalizadas según tu nivel y objetivos"
                    )
                    
                    MembershipBenefitRow(
                        icon: "fork.knife",
                        title: "Dietas Personalizadas",
                        description: "Planes nutricionales adaptados a tu peso y preferencias"
                    )
                    
                    MembershipBenefitRow(
                        icon: "person.2.fill",
                        title: "Red de Entrenadores",
                        description: "Encuentra y conecta con entrenadores cercanos"
                    )
                    
                    MembershipBenefitRow(
                        icon: "cart.fill",
                        title: "Shopping de Suplementos",
                        description: "Accede a productos especializados con descuentos"
                    )
                    
                    MembershipBenefitRow(
                        icon: "heart.fill",
                        title: "Hábitos Especializados",
                        description: "Programas de hábitos para maximizar tus resultados"
                    )
                }
                
                // Botón para ver planes
                Button(action: {
                    showMembershipSheet = true
                }) {
                    HStack {
                        Text("VER PLANES Y PRECIOS")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appYellow)
                            .shadow(color: Color.appYellow.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                }
            }
        }
    }
}

// MARK: - Navigation Buttons
private extension ShowInfoView {
    var navigationButtonsSection: some View {
        VStack(spacing: 16) {
            // Botón principal: Empezar
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                sessionManager.completeOnboarding()
                navigateToDashboard = true
            }) {
                HStack(spacing: 12) {
                    Text("EMPEZAR MI JORNADA")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appYellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .shadow(color: Color.appYellow.opacity(0.4), radius: 12, x: 0, y: 4)
                )
            }
            
            // Botón secundario: Volver
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Volver")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.appWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.appWhite.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.appWhite.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            
            NavigationLink(
                destination: DashboardView(),
                isActive: $navigateToDashboard
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .offset(y: -100)
        )
    }
}

// MARK: - Helper Functions
private extension ShowInfoView {
    func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
}

// MARK: - Supporting Views

// Card moderno reutilizable
struct ModernCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header del card
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Text(title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.appWhite)
                
                Spacer()
            }
            
            // Contenido
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appWhite.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }
}

// Row para desglose de agua
struct WaterBreakdownRow: View {
    let item: WaterBreakdownItem
    
    var body: some View {
        HStack {
            Text(item.label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
            
            Spacer()
            
            Text(item.value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.blue)
        }
    }
}

// Card de métrica de pronóstico
struct ForecastMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.appWhite)
                    
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appWhite.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                )
        )
    }
}

// Info de macro
struct MacroInfo: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text("\(label): \(value)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appWhite.opacity(0.9))
        }
    }
}

// Row de plan de acción
struct ActionPlanRow: View {
    let item: ActionPlanItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Número/Icono
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Text("\(item.stepNumber)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(item.color)
            }
            
            // Texto
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(item.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// Row de beneficio de membresía (NUEVO)
struct MembershipBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.appYellow)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.appYellow.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Membership Plan Models
struct MembershipPlan: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let period: String
    let savings: String?
    let isPopular: Bool
    let features: [String]
}

// MARK: - Membership Selection View
struct MembershipSelectionView: View {
    @Binding var selectedPlan: MembershipPlan?
    let onPlanSelected: (MembershipPlan) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    let plans: [MembershipPlan] = [
        MembershipPlan(
            name: "Prueba Gratis",
            price: "GRATIS",
            period: "3 días",
            savings: nil,
            isPopular: false,
            features: [
                "Acceso completo por 3 días",
                "Todos los planes de ejercicios",
                "Dietas personalizadas",
                "Red de entrenadores"
            ]
        ),
        MembershipPlan(
            name: "Mensual",
            price: "$9.99",
            period: "por mes",
            savings: nil,
            isPopular: false,
            features: [
                "Acceso ilimitado",
                "Planes de ejercicios completos",
                "Dietas personalizadas",
                "Red de entrenadores",
                "Shopping de suplementos",
                "Hábitos especializados"
            ]
        ),
        MembershipPlan(
            name: "Trimestral",
            price: "$24.99",
            period: "cada 3 meses",
            savings: "Ahorra 17%",
            isPopular: true,
            features: [
                "Acceso ilimitado",
                "Planes de ejercicios completos",
                "Dietas personalizadas",
                "Red de entrenadores",
                "Shopping de suplementos",
                "Hábitos especializados",
                "Soporte prioritario"
            ]
        ),
        MembershipPlan(
            name: "Anual",
            price: "$79.99",
            period: "por año",
            savings: "Ahorra 33%",
            isPopular: false,
            features: [
                "Acceso ilimitado",
                "Planes de ejercicios completos",
                "Dietas personalizadas",
                "Red de entrenadores",
                "Shopping de suplementos",
                "Hábitos especializados",
                "Soporte prioritario",
                "Actualizaciones exclusivas"
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("ELIGE TU PLAN")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.appYellow)
                            
                            Text("Desbloquea todo el potencial de tu transformación")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Planes
                        VStack(spacing: 16) {
                            ForEach(plans) { plan in
                                MembershipPlanCard(
                                    plan: plan,
                                    isSelected: selectedPlan?.id == plan.id,
                                    onSelect: {
                                        selectedPlan = plan
                                        onPlanSelected(plan)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
    }
}

// Card de plan de membresía
struct MembershipPlanCard: View {
    let plan: MembershipPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Header del plan
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(plan.name)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.appWhite)
                            
                            if plan.isPopular {
                                Text("POPULAR")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.appYellow)
                                    )
                            }
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(plan.price)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.appYellow)
                            
                            if plan.price != "GRATIS" {
                                Text(plan.period)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appWhite.opacity(0.7))
                            }
                        }
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Checkmark si está seleccionado
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appYellow)
                    }
                }
                
                Divider()
                    .background(Color.appWhite.opacity(0.2))
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Text(feature)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.9))
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appWhite.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.appYellow : Color.appWhite.opacity(0.2),
                                lineWidth: isSelected ? 3 : 1.5
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Extension for Cascading Animation
extension View {
    func cascadingAppear(index: Int) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                    // This will be handled by the parent view
                }
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
