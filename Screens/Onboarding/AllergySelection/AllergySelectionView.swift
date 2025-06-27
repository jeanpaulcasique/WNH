import SwiftUI

struct AllergySelectionView: View {
    @StateObject private var vm = AllergySelectionViewModel()
    @State private var showContent = false
    @State private var showCards = false
    @State private var headerPulse = false
    @State private var floatingIcons: [FloatingIcon] = []
    @State private var selectedCount = 0
    var onFinish: ([String]) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            backgroundWithParticles
            floatingIconsLayer
            mainContent
            bottomButtonOverlay
            selectedCountAnimation
        }
        .onAppear {
            startAnimations()
            generateFloatingIcons()
        }
        .onChange(of: vm.selectedAllergens.count) { newCount in
            animateCountChange(from: selectedCount, to: newCount)
            selectedCount = newCount
        }
    }
}

// MARK: - Background & Enhanced Particles
private extension AllergySelectionView {
    var backgroundWithParticles: some View {
        ZStack {
            // Base background
            Color.black
                .ignoresSafeArea()
            
            // Dynamic gradient overlay
            RadialGradient(
                colors: [
                    Color.appYellow.opacity(0.1),
                    Color.appBlack,
                    Color.gray.opacity(0.2),
                    Color.appBlack
                ],
                center: UnitPoint(x: 0.3, y: 0.2),
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: UUID())
            
            // Enhanced floating particles
            EnhancedAllergyParticles()
            
            // Glowing orbs
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 6...10))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 2),
                        value: UUID()
                    )
            }
        }
    }
    
    var floatingIconsLayer: some View {
        ZStack {
            ForEach(floatingIcons) { icon in
                Image(systemName: icon.symbol)
                    .font(.system(size: icon.size))
                    .foregroundColor(.appYellow.opacity(0.3))
                    .position(x: icon.x, y: icon.y)
                    .rotationEffect(.degrees(icon.rotation))
                    .scaleEffect(icon.scale)
                    .animation(
                        .easeInOut(duration: icon.duration)
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
    }
}

// MARK: - Main Content
private extension AllergySelectionView {
    var mainContent: some View {
        VStack(spacing: 0) {
            headerSection
            allergyCardsSection
            Spacer(minLength: 120)
        }
        .padding(.horizontal, 20)
    }
    
    var headerSection: some View {
        VStack(spacing: 25) {
            if showContent {
                enhancedAllergyIcon
                animatedHeaderText
                allergyStatsBar
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 35)
    }
    
    var enhancedAllergyIcon: some View {
        ZStack {
            // Multiple animated rings
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.appYellow.opacity(0.6 - Double(index) * 0.15),
                                Color.clear,
                                Color.appYellow.opacity(0.4 - Double(index) * 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 140 + CGFloat(index * 20), height: 140 + CGFloat(index * 20))
                    .scaleEffect(1.0 + Double(index) * 0.1)
                    .opacity(0.8 - Double(index) * 0.2)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .animation(
                        .linear(duration: 8 - Double(index) * 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.5),
                        value: UUID()
                    )
            }
            
            // Pulsing background circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appYellow.opacity(headerPulse ? 0.6 : 0.3),
                            Color.appYellow.opacity(headerPulse ? 0.2 : 0.05)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(headerPulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: headerPulse)
            
            // Rotating gradient ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.clear,
                            Color.appYellow.opacity(0.8),
                            Color.clear,
                            Color.appYellow.opacity(0.4),
                            Color.clear
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(Date().timeIntervalSince1970 * 30))
                .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: UUID())
            
            // Animated icon cluster
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.appYellow)
                    .rotationEffect(.degrees(showContent ? 0 : -180))
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.6, dampingFraction: 0.4).delay(0.2), value: showContent)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.appYellow)
                    .offset(y: showContent ? 0 : 20)
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.4), value: showContent)
                
                Image(systemName: "cross.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.appYellow)
                    .rotationEffect(.degrees(showContent ? 0 : 180))
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.7, dampingFraction: 0.3).delay(0.6), value: showContent)
            }
        }
        .scaleEffect(showContent ? 1 : 0.3)
        .opacity(showContent ? 1 : 0)
        .animation(.spring(response: 1.2, dampingFraction: 0.6), value: showContent)
        .onAppear {
            headerPulse = true
        }
    }
    
    var animatedHeaderText: some View {
        VStack(spacing: 16) {
            // Main title with letter animation
            HStack(spacing: 0) {
                ForEach(Array("¿Eres alérgico a algún alimento?".enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.appYellow)
                        .offset(y: showContent ? 0 : 30)
                        .opacity(showContent ? 1 : 0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(0.3 + Double(index) * 0.02),
                            value: showContent
                        )
                }
            }
            .multilineTextAlignment(.center)
            
            // Subtitle with icon animation
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(showContent ? 360 : 0))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: showContent)
                
                Text("Selecciona todos los que apliquen para ti")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .offset(x: showContent ? 0 : -20)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showContent)
                
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .scaleEffect(showContent ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.4).delay(0.7), value: showContent)
            }
        }
    }
    
    var allergyStatsBar: some View {
        HStack(spacing: 20) {
            StatBubble(
                icon: "list.bullet.circle.fill",
                value: "\(vm.totalAllergies)",
                label: "Total",
                color: .gray
            )
            
            StatBubble(
                icon: "checkmark.circle.fill",
                value: "\(vm.selectedAllergens.count)",
                label: "Seleccionados",
                color: .appYellow
            )
            
            StatBubble(
                icon: "percent",
                value: "\(vm.selectionPercentage)%",
                label: "Completado",
                color: .green
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appSurface.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(showContent ? 1 : 0.8)
        .opacity(showContent ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.8), value: showContent)
    }
    
    var allergyCardsSection: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                if showCards {
                    ForEach(Array(vm.categorizedAllergies.keys.sorted().enumerated()), id: \.element) { index, category in
                        EnhancedAllergyCategorySection(
                            category: category,
                            allergies: vm.categorizedAllergies[category] ?? [],
                            selectedAllergens: vm.selectedAllergens,
                            categoryIcon: vm.getCategoryIcon(category),
                            animationDelay: Double(index) * 0.1,
                            onToggle: { allergen in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    vm.toggleAllergen(allergen)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 30)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showCards)
    }
}

// MARK: - Enhanced Category Section
struct EnhancedAllergyCategorySection: View {
    let category: String
    let allergies: [String]
    let selectedAllergens: Set<String>
    let categoryIcon: String
    let animationDelay: Double
    let onToggle: (String) -> Void
    
    @State private var showSection = false
    @State private var expandedCards: Set<String> = []
    
    var body: some View {
        VStack(spacing: 16) {
            // Enhanced category header
            categoryHeader
            
            // Enhanced allergy grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                ForEach(Array(allergies.enumerated()), id: \.element) { index, allergy in
                    EnhancedAllergyCard(
                        allergy: allergy,
                        allergyIcon: getAllergyIcon(allergy),
                        isSelected: selectedAllergens.contains(allergy),
                        animationDelay: animationDelay + Double(index) * 0.05,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                onToggle(allergy)
                            }
                        }
                    )
                }
            }
        }
        .scaleEffect(showSection ? 1 : 0.9)
        .opacity(showSection ? 1 : 0)
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(animationDelay), value: showSection)
        .onAppear {
            showSection = true
        }
    }
    
    private var categoryHeader: some View {
        HStack(spacing: 12) {
            // Animated category icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            center: .center,
                            startRadius: 15,
                            endRadius: 30
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.appYellow)
                    .rotationEffect(.degrees(showSection ? 360 : 0))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(animationDelay + 0.2), value: showSection)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("\(selectedCount) de \(allergies.count) seleccionados")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.appWhite.opacity(0.2), lineWidth: 3)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(Color.appYellow, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1).delay(animationDelay + 0.5), value: progressPercentage)
                
                Text("\(Int(progressPercentage * 100))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.appYellow)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appYellow.opacity(0.4), lineWidth: 1)
                )
        )
    }
    
    private var selectedCount: Int {
        allergies.filter { selectedAllergens.contains($0) }.count
    }
    
    private var progressPercentage: Double {
        guard !allergies.isEmpty else { return 0 }
        return Double(selectedCount) / Double(allergies.count)
    }
    
    private func getAllergyIcon(_ allergy: String) -> String {
        switch allergy.lowercased() {
        case "leche", "queso", "yogurt", "mantequilla": return "drop.fill"
        case "huevo": return "oval.fill"
        case "maní", "nueces", "almendras", "avellanas": return "leaf.circle.fill"
        case "pescado": return "fish.fill"
        case "mariscos": return "crab.fill"
        case "trigo", "gluten", "avena": return "grain.fill"
        case "soja", "maíz": return "seedling.fill"
        case "fresas": return "heart.fill"
        case "tomate": return "circle.fill"
        case "chocolate": return "square.fill"
        case "coco": return "circle.hexagongrid.fill"
        default: return "exclamationmark.circle.fill"
        }
    }
}

// MARK: - Enhanced Allergy Card
struct EnhancedAllergyCard: View {
    let allergy: String
    let allergyIcon: String
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @State private var showCard = false
    @State private var isPressed = false
    @State private var particlesVisible = false
    
    var body: some View {
        Button(action: {
            onTap()
            triggerSelectionEffect()
        }) {
            HStack(spacing: 12) {
                // Enhanced icon section
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.appYellow : Color.appSurface.opacity(0.4))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.appYellow : Color.appWhite.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                    
                    if isSelected {
                        // Success checkmark
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .scaleEffect(isSelected ? 1 : 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    } else {
                        // Allergy icon
                        Image(systemName: allergyIcon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appYellow)
                            .scaleEffect(showCard ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(animationDelay + 0.1), value: showCard)
                    }
                }
                
                // Enhanced text section
                VStack(alignment: .leading, spacing: 2) {
                    Text(allergy)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .appYellow : .appWhite)
                        .multilineTextAlignment(.leading)
                    
                    if isSelected {
                        Text("✓ Seleccionado")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.appYellow.opacity(0.8))
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                
                Spacer()
                
                // Visual feedback indicator
                if isSelected {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow.opacity(0.7))
                        .scaleEffect(isSelected ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ? Color.appYellow.opacity(0.6) : Color.appWhite.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            )
            .scaleEffect(isPressed ? 0.98 : (isSelected ? 1.02 : 1.0))
            .shadow(
                color: isSelected ? Color.appYellow.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            
            // Selection particles effect
            .overlay(
                Group {
                    if particlesVisible && isSelected {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(Color.appYellow.opacity(0.8))
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: CGFloat.random(in: -30...30),
                                    y: CGFloat.random(in: -30...30)
                                )
                                .scaleEffect(particlesVisible ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                                    value: particlesVisible
                                )
                        }
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(showCard ? 1 : 0.8)
        .opacity(showCard ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay), value: showCard)
        .onAppear {
            showCard = true
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: isSelected
                        ? [Color.appSurface.opacity(0.8), Color.appSurface.opacity(0.5), Color.appYellow.opacity(0.1)]
                        : [Color.appSurface.opacity(0.4), Color.appSurface.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private func triggerSelectionEffect() {
        if isSelected {
            withAnimation(.easeOut(duration: 0.6)) {
                particlesVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                particlesVisible = false
            }
        }
    }
}

// MARK: - Stat Bubble Component
struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: animate)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Enhanced Particles
struct EnhancedAllergyParticles: View {
    @State private var particles: [EnhancedParticle] = []
    
    struct EnhancedParticle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let duration: Double
        let symbol: String
        let color: Color
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: particle.symbol)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .position(x: particle.x, y: particle.y)
                    .opacity(0.3)
                    .animation(
                        .easeInOut(duration: particle.duration)
                            .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            }
        }
        .onAppear {
            generateEnhancedParticles()
        }
    }
    
    private func generateEnhancedParticles() {
        let symbols = ["leaf.fill", "drop.fill", "circle.fill", "triangle.fill", "diamond.fill"]
        let colors = [Color.appYellow, Color.green, Color.blue, Color.orange, Color.purple]
        
        particles = (0..<12).map { _ in
            EnhancedParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 8...16),
                duration: Double.random(in: 4...8),
                symbol: symbols.randomElement() ?? "circle.fill",
                color: colors.randomElement() ?? Color.appYellow
            )
        }
    }
}

// MARK: - Floating Icons Data
struct FloatingIcon: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let duration: Double
    let symbol: String
    let rotation: Double
    let scale: Double
}

// MARK: - Bottom Button Enhanced
private extension AllergySelectionView {
    var bottomButtonOverlay: some View {
        VStack {
            Spacer()
            
            if showCards {
                VStack(spacing: 20) {
                    // Enhanced selection summary
                    if !vm.selectedAllergens.isEmpty {
                        selectionSummaryCard
                    }
                    
                    // Enhanced continue button
                    enhancedContinueButton
                }
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.7), Color.black.opacity(0.95), Color.black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.2), value: showCards)
            }
        }
    }
    
    var selectionSummaryCard: some View {
        HStack(spacing: 16) {
            // Animated count circle
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Circle()
                    .stroke(Color.appYellow, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .scaleEffect(vm.selectedAllergens.isEmpty ? 0.8 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: vm.selectedAllergens.count)
                
                Text("\(vm.selectedAllergens.count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appYellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Alérgenos seleccionados")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text("Mantén tu perfil actualizado")
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            Button("Limpiar") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    vm.clearAllSelection()
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.appYellow)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .stroke(Color.appYellow.opacity(0.5), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    var enhancedContinueButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            onFinish(vm.getSelectedAllergens())
        }) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                
                Text("Continuar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                if !vm.selectedAllergens.isEmpty {
                    Text("(\(vm.selectedAllergens.count))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow, Color.appYellow.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.appYellow.opacity(0.4),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
        }
        .padding(.horizontal, 20)
        .scaleEffect(vm.selectedAllergens.isEmpty ? 0.95 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.selectedAllergens.isEmpty)
    }
    
    var selectedCountAnimation: some View {
        VStack {
            if selectedCount > 0 {
                Text("+\(selectedCount)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appYellow)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedCount)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

// MARK: - Animation Control Enhanced
private extension AllergySelectionView {
    func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showCards = true
            }
        }
    }
    
    func generateFloatingIcons() {
        let icons = ["leaf.fill", "drop.fill", "circle.fill", "triangle.fill", "heart.fill", "star.fill"]
        
        floatingIcons = (0..<8).map { _ in
            FloatingIcon(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200),
                size: CGFloat.random(in: 12...20),
                duration: Double.random(in: 5...10),
                symbol: icons.randomElement() ?? "circle.fill",
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.5...1.0)
            )
        }
    }
    
    func animateCountChange(from oldCount: Int, to newCount: Int) {
        if newCount > oldCount {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                // Trigger positive feedback
            }
        }
    }
}


// MARK: - Preview
struct AllergySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AllergySelectionView()
            .preferredColorScheme(.dark)
    }
}
