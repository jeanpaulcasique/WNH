import SwiftUI

struct TargetWeightView: View {
    @StateObject var viewModel: TargetWeightViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isNavigatingToNextScreen = false
    @State private var isNavigatingToPreviousScreen = false
    @State private var selectedIndex: Int = 40 // Default a 50kg (50 - 30 = 20)
    
    // Configuración visual
    private let minWeight = 30 // 30kg
    private let maxWeight = 200 // 200kg
    private let itemWidth: CGFloat = 8 // Ancho de cada tick en la cinta
    private var weightRange: [Double] { stride(from: Double(minWeight), through: Double(maxWeight), by: 0.5).map { $0 } }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Logo arriba
                Image("samsonWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .padding(.top, 5)
                    .padding(.bottom, -10)
                    .opacity(1.0)
                
                // Card con título y subtítulo
                VStack(spacing: 8) {
                    Text("WHAT'S YOUR TARGET WEIGHT?")
                        .font(.system(size: 25, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                       
                    Text("Choose a realistic goal that motivates you to stay healthy")
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
                .background(Color.yellow)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 3)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Valor grande y cinta métrica horizontal
                VStack(spacing: 0) {
                    // Valor de peso
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Spacer()
                        Text(viewModel.isKgSelected ? "\(viewModel.selectedWeightKg, specifier: "%.1f")" : "\(viewModel.selectedWeightKg * 2.20462, specifier: "%.1f")")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.black)
                        Text(viewModel.isKgSelected ? "kg" : "lb")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .offset(y: -10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)

                    // Selector de unidad
                    HStack(spacing: 12) {
                        Button(action: { viewModel.selectKgUnit() }) {
                            Text("kg")
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.isKgSelected ? .black : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(viewModel.isKgSelected ? Color.yellow : Color.gray.opacity(0.15))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(viewModel.isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                )
                        }
                        Button(action: { viewModel.selectLbUnit() }) {
                            Text("lb")
                                .fontWeight(.bold)
                                .foregroundColor(!viewModel.isKgSelected ? .black : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(!viewModel.isKgSelected ? Color.yellow : Color.gray.opacity(0.15))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(!viewModel.isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 8)
                    
                    ZStack {
                        // Cinta métrica horizontal con DragGesture y snapping
                        TargetWeightTapePicker(
                            items: weightRange,
                            selectedIndex: $selectedIndex,
                            itemWidth: itemWidth,
                            viewModel: viewModel
                        )
                        .frame(height: 80)
                        .padding(.horizontal, 0)
                        
                        // Línea central destacada
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.yellow.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 4, height: 70)
                            .cornerRadius(2)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 8, x: 0, y: 0)
                    }
                }
                .padding(.horizontal, 20)
                .onChange(of: selectedIndex) { newIndex in
                    let weight = weightRange[newIndex]
                    viewModel.selectedWeightKg = weight
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .onAppear {
                    // Cargar peso desde viewModel
                    let currentWeight = Int(viewModel.selectedWeightKg)
                    if currentWeight >= minWeight && currentWeight <= maxWeight {
                        selectedIndex = Int((viewModel.selectedWeightKg - Double(minWeight)) * 2)
                    } else {
                        selectedIndex = 40 // Default a 50kg
                        viewModel.selectedWeightKg = weightRange[selectedIndex]
                    }
                }
                
                // Did You Know? Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.yellow)
                        Text("Did you know?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    Text("To gain weight healthily, focus on a balanced diet with protein-rich foods, healthy fats, and complex carbohydrates. Our personalized meal plans will help you achieve your target weight safely and sustainably.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Botones abajo
                HStack {
                    // Botón Back
                    Button(action: {
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
                                .fill(Color.yellow)
                                .shadow(color: Color.yellow.opacity(0.25), radius: 10, x: 0, y: 4)
                        )
                    }
                    .scaleEffect(1.0)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    
                    NavigationLink(
                        destination: BirthYearView(viewModel: BirthYearViewModel()),
                        isActive: $isNavigatingToNextScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(
                        destination: GoalView(viewModel: GoalViewModel()),
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
        // DragGesture en toda la pantalla
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Propaga el drag a la cinta
                    NotificationCenter.default.post(name: .targetWeightPickerDragChanged, object: value.translation.width)
                }
                .onEnded { value in
                    NotificationCenter.default.post(name: .targetWeightPickerDragEnded, object: value.translation.width)
                }
        )
    }
}

// MARK: - Preview
struct TargetWeightView_Previews: PreviewProvider {
    static var previews: some View {
        TargetWeightView(
            viewModel: TargetWeightViewModel()
        )
        .previewDevice("iPhone 16 Pro")
        .preferredColorScheme(.dark)
    }
}

// Nuevo componente TargetWeightTapePicker
struct TargetWeightTapePicker: View {
    let items: [Double]
    @Binding var selectedIndex: Int
    let itemWidth: CGFloat
    var viewModel: TargetWeightViewModel
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var dragStartIndex: Int? = nil
    @State private var visualIndex: Int = 40
    
    // Índice visual temporal para mostrar el valor en tiempo real
    private var currentIndex: Int {
        if isDragging {
            let baseIndex = dragStartIndex ?? selectedIndex
            let offset = -dragOffset / itemWidth
            let idx = Int(round(CGFloat(baseIndex) + offset))
            return max(0, min(idx, items.count - 1))
        } else {
            return selectedIndex
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = CGFloat(items.count) * itemWidth
            let centerX = geometry.size.width / 2
            
            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, weight in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(index == visualIndex ? Color.white : Color.black.opacity(0.4))
                            .frame(width: 2, height: index == visualIndex ? 50 : (weight.truncatingRemainder(dividingBy: 5) == 0 ? 30 : 20))
                        Spacer().frame(height: 12)
                    }
                    .frame(width: itemWidth, height: 60)
                }
            }
            .frame(width: totalWidth, alignment: .leading)
            .offset(x: centerX - CGFloat(visualIndex) * itemWidth + (isDragging ? dragOffset : 0))
            .onReceive(NotificationCenter.default.publisher(for: .targetWeightPickerDragChanged)) { notif in
                if let width = notif.object as? CGFloat {
                    if dragStartIndex == nil {
                        dragStartIndex = selectedIndex
                    }
                    dragOffset = width
                    isDragging = true

                    let baseIndex = dragStartIndex ?? selectedIndex
                    let offset = -dragOffset / itemWidth
                    let idx = Int(round(CGFloat(baseIndex) + offset))
                    let clampedIndex = max(0, min(idx, items.count - 1))

                    visualIndex = clampedIndex
                    viewModel.selectedWeightKg = items[clampedIndex]
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .targetWeightPickerDragEnded)) { notif in
                if let width = notif.object as? CGFloat {
                    let baseIndex = dragStartIndex ?? selectedIndex
                    let offset = -width / itemWidth
                    let newIndex = Int(round(CGFloat(baseIndex) + offset))
                    let clampedIndex = max(0, min(newIndex, items.count - 1))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedIndex = clampedIndex
                        visualIndex = clampedIndex
                    }
                    dragOffset = 0
                    dragStartIndex = nil
                    isDragging = false
                }
            }
        }
        .clipped()
    }
}

extension Notification.Name {
    static let targetWeightPickerDragChanged = Notification.Name("targetWeightPickerDragChanged")
    static let targetWeightPickerDragEnded = Notification.Name("targetWeightPickerDragEnded")
}
