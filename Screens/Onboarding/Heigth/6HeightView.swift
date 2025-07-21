import SwiftUI

struct HeightView: View {
    @StateObject var viewModel: HeightViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isNavigatingToNextScreen = false
    @State private var isNavigatingToPreviousScreen = false
    @State private var selectedIndex: Int = 50 // Default a 150cm (150 - 100 = 50)
    @State private var scrollPickerDragOffset: CGFloat = 0
    
    // Configuración visual
    private let minHeight = 100 // 100cm
    private let maxHeight = 230 // 230cm (según tu viewModel)
    private let itemHeight: CGFloat = 8 // Altura más pequeña para la cinta métrica
    private var heightRange: [Int] { Array(minHeight...maxHeight) }
    
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
                    Text("WHAT'S YOUR HEIGHT?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 1)
                    Text("You can always change this later")
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
                .padding(.bottom, 20)

                Spacer()
                
                // Contenedor principal con valor y cinta métrica
                HStack(spacing: 0) {
                    // Lado izquierdo - Valor de altura
                    VStack {
                        Text("\(viewModel.selectedHeightCm)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.black)
                        Text("cm")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                            .offset(y: -10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Lado derecho - Cinta métrica vertical
                    VStack(spacing: 0) {
                        // Cinta métrica con picker personalizado
                        ZStack {
                            // Indicador central (línea amarilla)
                            HStack {
                                Rectangle()
                                    .fill(Color.appYellow)
                                    .frame(width: 60, height: 4)
                                    .cornerRadius(2)
                                Spacer()
                            }
                            .zIndex(1)
                            
                            // Cinta métrica
                            CustomTapeView(
                                items: heightRange,
                                selectedIndex: $selectedIndex,
                                itemHeight: itemHeight,
                                externalDragOffset: scrollPickerDragOffset
                            )
                            .frame(width: 100)
                        }
                        .frame(height: 400)
                    }
                    .frame(width: 100)
                }
                .padding(.horizontal, 20)
                .onChange(of: selectedIndex) { newIndex in
                    let height = heightRange[newIndex]
                    viewModel.updateHeightInCm(Double(height))
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                .onAppear {
                    // Cargar altura desde viewModel
                    viewModel.loadHeightFromUserDefaults()
                    
                    // Asegurar que estamos en modo cm
                    if !viewModel.isCmSelected {
                        viewModel.toggleUnit(toCm: true)
                    }
                    
                    // Calcular el índice basado en la altura guardada
                    let currentHeight = viewModel.selectedHeightCm
                    if currentHeight >= minHeight && currentHeight <= maxHeight {
                        selectedIndex = currentHeight - minHeight
                    } else {
                        selectedIndex = 50 // Default a 150cm
                        viewModel.updateHeightInCm(Double(heightRange[selectedIndex]))
                    }
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
                        withAnimation {
                            progressViewModel.advanceProgress()
                        }
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
                    .animation(.easeInOut(duration: 0.1), value: selectedIndex)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            
            NavigationLink(
                destination: BMIView(viewModel: BMIViewModel(), progressViewModel: progressViewModel),
                isActive: $isNavigatingToNextScreen
            ) {
                EmptyView()
            }
            .hidden()
            NavigationLink(
                destination: BirthYearView(viewModel: BirthYearViewModel(), progressViewModel: progressViewModel),
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
                    
                    // Calcular el nuevo índice en tiempo real solo para mostrar el número
                    let itemsToMove = -value.translation.height / itemHeight
                    let newIndex = selectedIndex + Int(round(itemsToMove))
                    let clampedIndex = max(0, min(newIndex, heightRange.count - 1))
                    
                    // Actualizar solo el número mostrado, sin cambiar selectedIndex
                    let height = heightRange[clampedIndex]
                    viewModel.updateHeightInCm(Double(height))
                }
                .onEnded { value in
                    // Calcular nuevo índice basado en el gesto
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    let adjustedOffset = value.translation.height + velocity * 0.1
                    
                    let itemsToMove = -adjustedOffset / itemHeight
                    let newIndex = selectedIndex + Int(round(itemsToMove))
                    let clampedIndex = max(0, min(newIndex, heightRange.count - 1))
                    
                    // Animar al nuevo índice
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedIndex = clampedIndex
                        scrollPickerDragOffset = 0
                    }
                    
                    // Guardar usando el método del viewModel
                    let height = heightRange[clampedIndex]
                    viewModel.updateHeightInCm(Double(height))
                }
        )
    }
}

// MARK: - Custom Tape View (Cinta métrica)
struct CustomTapeView: View {
    let items: [Int]
    @Binding var selectedIndex: Int
    let itemHeight: CGFloat
    let externalDragOffset: CGFloat
    
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let centerY = totalHeight / 2
            let padding = centerY - itemHeight / 2
            
            VStack(spacing: 0) {
                // Top padding
                Color.clear.frame(height: padding)
                
                // Items de la cinta métrica
                ForEach(Array(items.enumerated()), id: \.offset) { index, height in
                    let distance = abs(index - selectedIndex)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Línea de medición
                        Rectangle()
                            .fill(tapeLineColor(for: distance))
                            .frame(width: tapeLineWidth(for: height), height: 2)
                        
                        // Número cada 5cm
                        if height % 5 == 0 {
                            Text("\(height)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                                .frame(width: 30, alignment: .leading)
                                .padding(.leading, 4)
                        } else {
                            Spacer().frame(width: 30)
                        }
                    }
                    .frame(height: itemHeight)
                }
                
                // Bottom padding
                Color.clear.frame(height: padding)
            }
            .offset(y: currentOffset + externalDragOffset)
            .onAppear {
                // Posicionar inicialmente sin animación
                currentOffset = -CGFloat(selectedIndex) * itemHeight
            }
            .onChange(of: selectedIndex) { newIndex in
                // Sincronizar currentOffset cuando selectedIndex cambie externamente
                let targetOffset = -CGFloat(newIndex) * itemHeight
                let offsetDifference = abs(currentOffset - targetOffset)
                
                if offsetDifference > 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentOffset = targetOffset
                    }
                }
            }
        }
        .clipped()
    }
    
    // Función para determinar el ancho de la línea según la altura
    private func tapeLineWidth(for height: Int) -> CGFloat {
        if height % 10 == 0 {
            return 40 // Líneas más largas cada 10cm
        } else if height % 5 == 0 {
            return 30 // Líneas medianas cada 5cm
        } else {
            return 20 // Líneas cortas cada 1cm
        }
    }
    
    // Función para determinar el color de la línea según la distancia
    private func tapeLineColor(for distance: Int) -> Color {
        return .black
    }
}

// MARK: - Preview
struct HeightView_Previews: PreviewProvider {
    static var previews: some View {
        HeightView(
            viewModel: HeightViewModel(),
            progressViewModel: ProgressViewModel()
        )
        .previewDevice("iPhone 16 Pro")
        .previewDisplayName("iPhone 16 Pro")
    }
}
