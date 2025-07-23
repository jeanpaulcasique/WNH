import SwiftUI

/// Componente del personaje 3D simplificado: solo imagen frontal o trasera, sin efectos
struct WorkoutCharacterView: View {
    let isShowingBack: Bool // true = trasera, false = delantera
    let onToggle: () -> Void // Acción para girar

    var body: some View {
        ZStack {
            // Imagen del personaje
            Group {
                if isShowingBack {
                    Image("human_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // ===== EDITA AQUÍ EL TAMAÑO DE LA IMAGEN =====
                        // Cambia estos valores para hacer la imagen más grande o más pequeña
                        // width: ancho de la imagen
                        // height: alto de la imagen
                        .frame(maxWidth: 780, maxHeight: 780) // ← Aumentado para compensar personaje más pequeño
                        .scaleEffect(1.45) // ← Hace la imagen 40% más grande para compensar
                        // ===== EDITA AQUÍ LA POSICIÓN DE LA IMAGEN =====
                        // offset(x, y) - x: horizontal, y: vertical
                        // x: negativo = izquierda, positivo = derecha
                        // y: negativo = arriba, positivo = abajo
                        // .offset(x: 9, y: 110) // ← EDITA ESTOS VALORES
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
                }
            }
        }
        .clipped() // ← Limita el tamaño para no expandir el contenedor
        // (No hay gesto de tap)
    }
}

#Preview {
    WorkoutCharacterView(
        isShowingBack: false,
        onToggle: {}
    )
    .frame(height: 450)
} 


