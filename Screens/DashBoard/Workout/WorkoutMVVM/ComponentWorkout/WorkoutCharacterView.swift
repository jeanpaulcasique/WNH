import SwiftUI

/// Componente del personaje 3D simplificado: solo imagen frontal o trasera, sin efectos
struct WorkoutCharacterView: View {
    let isShowingBack: Bool // true = trasera, false = delantera
    let onToggle: () -> Void // Acción para girar
    
    // Estado para la animación de respiración
    @State private var breathingScale: CGFloat = 1.0
    @State private var breathingOpacity: Double = 1.0
    @State private var breathingOffset: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Imagen del personaje con efecto de respiración localizado
                Group {
                    if isShowingBack {
                        Image("human_back")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            // ===== EDITA AQUÍ EL TAMAÑO DE LA IMAGEN =====
                            // Cambia estos valores para hacer la imagen más grande o más pequeña
                            // width: ancho de la imagen
                            // height: alto de la imagen
                            .frame(maxWidth: 540, maxHeight: 540) // ← Mantenido igual
                            .scaleEffect(1.60) // ← Reducido para hacer la imagen trasera más pequeña
                            // ===== EDITA AQUÍ LA POSICIÓN DE LA IMAGEN =====
                            // offset(x, y) - x: horizontal, y: vertical
                            // x: negativo = izquierda, positivo = derecha
                            // y: negativo = arriba, positivo = abajo
                            // .offset(x: 9, y: 110) // ← EDITA ESTOS VALORES
                            .scaleEffect(breathingScale, anchor: UnitPoint(x: 0.5, y: 0.3)) // Anclaje en el pecho (30% desde arriba)
                            .opacity(breathingOpacity)
                    } else {
                        Image("human_front")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            // ===== EDITA AQUÍ EL TAMAÑO DE LA IMAGEN =====
                            // Cambia estos valores para hacer la imagen más grande o más pequeña
                            // width: ancho de la imagen
                            // height: alto de la imagen
                            .frame(maxWidth: 540, maxHeight: 540) // ← Aumentado para dar más espacio
                            .scaleEffect(1.07) // ← Hace la imagen 20% más grande
                            // ===== EDITA AQUÍ LA POSICIÓN DE LA IMAGEN =====
                            // offset(x, y) - x: horizontal, y: vertical
                            // x: negativo = izquierda, positivo = derecha
                            // y: negativo = arriba, positivo = abajo
                            // .offset(x: 9, y: 110) // ← EDITA ESTOS VALORES
                            .scaleEffect(breathingScale, anchor: UnitPoint(x: 0.5, y: 0.3)) // Anclaje en el pecho (30% desde arriba)
                            .opacity(breathingOpacity)
                    }
                }
            }
        }
        .clipped() // ← Limita el tamaño para no expandir el contenedor
        // (No hay gesto de tap)
        .onAppear {
            startBreathingAnimation()
        }
        .onChange(of: isShowingBack) { _, _ in
            // Reiniciar animación cuando cambie la vista
            startBreathingAnimation()
        }
    }
    
    // MARK: - Animación de Respiración
    
    /// Inicia la animación de respiración
    private func startBreathingAnimation() {
        // Animación de respiración enfocada en el pecho
        withAnimation(
            .easeInOut(duration: 2.8)
            .repeatForever(autoreverses: true)
        ) {
            breathingScale = 1.008 // Expansión muy sutil del 0.8% enfocada en el pecho
            breathingOpacity = 0.99 // Variación de opacidad mínima
        }
    }
}

#Preview {
    WorkoutCharacterView(
        isShowingBack: false,
        onToggle: {}
    )
    .frame(height: 450)
} 


