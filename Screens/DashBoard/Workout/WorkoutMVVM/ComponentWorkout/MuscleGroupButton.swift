import SwiftUI

struct MuscleGroupButton: View {
    let muscleGroup: MuscleGroup
    let action: () -> Void
    @State private var cardioBounce = false
    @State private var waveAnimation = false
    
    // Propiedades computadas para configuraciones específicas por músculo
    private var lineLengthForMuscle: CGFloat {
        switch muscleGroup.name {
        case "Abs":
            return 100 // Línea más larga para abs
        case "Obliques":
            return 95 // Línea más larga para obliques
        case "Glutes", "Lower Back":
            return 120 // Línea aún más larga para glúteos y lower back
        default:
            return MuscleButtonPositions.LineConfig.lineLength
        }
    }
    
    private var lineOffsetForMuscle: CGFloat {
        switch muscleGroup.name {
        case "Abs":
            return 50 // Offset más largo para abs
        case "Obliques":
            return 48 // Offset más largo para obliques
        case "Glutes", "Lower Back":
            return 60 // Offset aún más largo para glúteos y lower back
        default:
            return MuscleButtonPositions.LineConfig.lineOffset
        }
    }
    
    private var textOffsetForMuscle: CGFloat {
        switch muscleGroup.name {
        case "Abs":
            return 120 // Offset de texto más largo para abs
        case "Obliques":
            return 115 // Offset de texto más largo para obliques
        case "Glutes", "Lower Back":
            return 140 // Offset de texto aún más largo para glúteos y lower back
        default:
            return MuscleButtonPositions.LineConfig.textOffset
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Botón especial para Cardio con icono de correr
                if muscleGroup.name == "Cardio" {
                    Image(systemName: "figure.run")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.yellow)
                        .scaleEffect(cardioBounce ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: cardioBounce)
                } else {
                    // Efecto de onda expansiva para botones circulares
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            .frame(width: 8 + CGFloat(index * 8), height: 8 + CGFloat(index * 8))
                            .scaleEffect(waveAnimation ? 1.5 : 0.5)
                            .opacity(waveAnimation ? 0 : 0.6)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                                value: waveAnimation
                            )
                    }
                    
                    // Círculo amarillo del botón para otros músculos
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                    
                    // Línea punteada horizontal solo para músculos que no son cardio
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: lineLengthForMuscle, height: 1)
                        .mask(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white, .white, .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .offset(x: muscleGroup.isLeftSide ? 
                               -lineOffsetForMuscle : 
                               lineOffsetForMuscle, y: 0)
                    
                    // Texto del músculo solo para músculos que no son cardio
                    Text(muscleGroup.name)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .offset(x: muscleGroup.isLeftSide ? 
                               -textOffsetForMuscle : 
                               textOffsetForMuscle, y: 0)
                }
            }
        }
        .onAppear {
            if muscleGroup.name == "Cardio" {
                cardioBounce = true
            } else {
                waveAnimation = true
            }
        }
    }
}

// MARK: - Modifier para Posicionamiento
struct PositionIfGeometry: ViewModifier {
    let position: CGPoint
    let geometry: GeometryProxy
    
    func body(content: Content) -> some View {
        content
            .position(
                x: position.x * geometry.size.width,
                y: position.y * geometry.size.height
            )
    }
}

extension View {
    func positionIfGeometry(_ position: CGPoint, geometry: GeometryProxy) -> some View {
        self.modifier(PositionIfGeometry(position: position, geometry: geometry))
    }
}

#Preview {
    ZStack {
        Color.black
        MuscleGroupButton(
            muscleGroup: MuscleGroup(
                name: "Chest",
                exercises: [],
                position: CGPoint(x: 0.5, y: 0.5),
                isLeftSide: false
            )
        ) {
            print("Button tapped")
        }
    }
} 
