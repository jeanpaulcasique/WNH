import SwiftUI

struct BirthYearView: View {
    @StateObject var viewModel: BirthYearViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isNavigatingToNextScreen = false
    @State private var isNavigatingToPreviousScreen = false
    @State private var selectedIndex: Int = 17 // Default a edad 33 (33 - 16 = 17)
    @State private var scrollPickerDragOffset: CGFloat = 0
    
    // Configuración visual
    private let minAge = 16
    private let maxAge = 80
    private let itemHeight: CGFloat = 60
    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    private var ageRange: [Int] { Array(minAge...maxAge) }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Imagen de samson centrada arriba
                Image("samsonWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .padding(.top, 5)
                    .padding(.bottom, -10)
                    .opacity(1.0)

                // Card amarillo con borde negro, título y subtítulo
                VStack(spacing: 8) {
                    Text("HOW OLD ARE YOU?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 1)
                    Text("This helps us create your personalized plan")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .cascadingAppear(index: 1)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(Color.appYellow)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 3)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, -50)

                Spacer()
                
                // Picker visual con 5 elementos (2 arriba, 1 centro, 2 abajo)
                ZStack {
                    // Líneas amarillas de selección
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.appYellow)
                            .frame(width: 120, height: 4)
                        Spacer().frame(height: itemHeight - 6)
                        Rectangle()
                            .fill(Color.appYellow)
                            .frame(width: 120, height: 4)
                        Spacer()
                    }
                    .frame(height: itemHeight * 5)

                    // Custom Scroll Picker sin animaciones
                    CustomScrollPickerNoAnimation(
                        items: ageRange,
                        selectedIndex: $selectedIndex,
                        itemHeight: itemHeight,
                        externalDragOffset: scrollPickerDragOffset
                    ) { age, distance in
                        Text("\(age)")
                            .font(.system(size: fontSizeForDistance(distance) + 16, weight: fontWeightForDistance(distance)))
                            .foregroundColor(colorForDistance(distance))
                            .frame(maxWidth: .infinity)
                            .frame(height: itemHeight)
                            .scaleEffect(scaleForDistance(distance))
                            .opacity(opacityForDistance(distance))
                    }
                    .frame(height: itemHeight * 5)
                }
                .onChange(of: selectedIndex) { newIndex in
                    let age = ageRange[newIndex]
                    viewModel.selectedYear = currentYear - age
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                .onAppear {
                    // Cargar selección guardada o default
                    let savedAge = UserDefaults.standard.integer(forKey: "selectedAge")
                    if savedAge >= minAge && savedAge <= maxAge {
                        selectedIndex = savedAge - minAge
                    } else {
                        selectedIndex = 17 // Default a edad 33
                    }
                    
                    // Sincronizar con el ViewModel SIN animación
                    let age = ageRange[selectedIndex]
                    viewModel.selectedYear = currentYear - age
                }
                
                Spacer()
                
                // Botones abajo
                HStack {
                    // Botón Back
                    Button(action: {
                        progressViewModel.decreaseProgress()
                        isNavigatingToPreviousScreen = true
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Botón Next
                    Button(action: {
                        // Removido withAnimation para evitar animaciones
                        progressViewModel.advanceProgress()
                        isNavigatingToNextScreen = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(red: 1.0, green: 0.827, blue: 0.0))
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        )
                    }
                    .scaleEffect(1.0)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    
                    NavigationLink(
                        destination: HeightView(viewModel: HeightViewModel(), progressViewModel: progressViewModel),
                        isActive: $isNavigatingToNextScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(
                        destination: GoalView(viewModel: GoalViewModel(), progressViewModel: progressViewModel),
                        isActive: $isNavigatingToPreviousScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Aplicar el gesto al picker
                    scrollPickerDragOffset = value.translation.height
                }
                .onEnded { value in
                    // Calcular nuevo índice basado en el gesto
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    let adjustedOffset = value.translation.height + velocity * 0.1
                    
                    let itemsToMove = -adjustedOffset / itemHeight
                    let newIndex = selectedIndex + Int(round(itemsToMove))
                    let clampedIndex = max(0, min(newIndex, ageRange.count - 1))
                    
                    // Fijar el nuevo índice SIN animación
                    selectedIndex = clampedIndex
                    scrollPickerDragOffset = 0
                    
                    // Guardar en UserDefaults
                    let age = ageRange[clampedIndex]
                    UserDefaults.standard.set(age, forKey: "selectedAge")
                }
        )
    }
    
    // MARK: - Visual Effects Functions
    private func fontSizeForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 44      // Elemento central
        case 1: return 32      // Elementos adyacentes
        case 2: return 26      // Elementos extremos
        default: return 20     // Elementos fuera del rango visible
        }
    }
    
    private func fontWeightForDistance(_ distance: Int) -> Font.Weight {
        switch abs(distance) {
        case 0: return .bold
        case 1: return .semibold
        case 2: return .medium
        default: return .regular
        }
    }
    
    private func colorForDistance(_ distance: Int) -> Color {
        switch abs(distance) {
        case 0: return .black
        case 1: return Color.black.opacity(0.7)
        case 2: return Color.black.opacity(0.4)
        default: return Color.black.opacity(0.2)
        }
    }
    
    private func scaleForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.9
        case 2: return 0.8
        default: return 0.7
        }
    }
    
    private func opacityForDistance(_ distance: Int) -> Double {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.5
        default: return 0.3
        }
    }
}

// MARK: - Custom Scroll Picker SIN ANIMACIONES
struct CustomScrollPickerNoAnimation<Item: Hashable, Content: View>: View {
    let items: [Item]
    @Binding var selectedIndex: Int
    let itemHeight: CGFloat
    let externalDragOffset: CGFloat
    let content: (Item, Int) -> Content
    
    @State private var currentOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let centerY = totalHeight / 2
            let padding = centerY - itemHeight / 2
            
            VStack(spacing: 0) {
                // Top padding
                Color.clear.frame(height: padding)
                
                // Items
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let distance = index - selectedIndex
                    content(item, distance)
                        .frame(height: itemHeight)
                }
                
                // Bottom padding
                Color.clear.frame(height: padding)
            }
            .offset(y: currentOffset + externalDragOffset)
            .onAppear {
                // Posicionar inicialmente SIN animación usando Transaction
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    currentOffset = -CGFloat(selectedIndex) * itemHeight
                }
            }
            .onChange(of: selectedIndex) { newIndex in
                // Actualizar offset SIN animación usando Transaction
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    currentOffset = -CGFloat(newIndex) * itemHeight
                }
            }
        }
        .clipped()
    }
}

// MARK: - Preview
struct BirthYearView_Previews: PreviewProvider {
    static var previews: some View {
        BirthYearView(
            viewModel: BirthYearViewModel(),
            progressViewModel: ProgressViewModel()
        )
        .previewDevice("iPhone 16 Pro")
        .previewDisplayName("iPhone 16 Pro")
    }
}
