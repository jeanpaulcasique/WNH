import SwiftUI

/// Componente del personaje 3D simplificado: solo imagen frontal o trasera, sin efectos
struct WorkoutCharacterView: View {
    let isShowingBack: Bool // true = trasera, false = delantera
    let onToggle: () -> Void // Acción para girar

    var body: some View {
        ZStack {
            // Fondo negro-gris sólido para toda la pantalla
            Color(red: 0.10, green: 0.10, blue: 0.12)
                .ignoresSafeArea()

            // Imagen del personaje
            Group {
                if isShowingBack {
                    Image("human_back")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // EDITA AQUÍ: Cambia el tamaño de la imagen
                        .frame(width: 220, height: 320)
                        // EDITA AQUÍ: Cambia la posición de la imagen
                        .offset(x: 0, y: 0)
                } else {
                    Image("human_front")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // EDITA AQUÍ: Cambia el tamaño de la imagen
                        .frame(width: 220, height: 320)
                        // EDITA AQUÍ: Cambia la posición de la imagen
                        .offset(x: 0, y: 0)
                }
            }
        }
        .frame(height: 340)
        // (No hay gesto de tap)
    }
}

#Preview {
    WorkoutCharacterView(
        isShowingBack: false,
        onToggle: {}
    )
    .frame(height: 340)
} 


