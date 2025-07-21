import SwiftUI
import Combine

/// ViewModel especializado para manejar la lógica del personaje 3D
class WorkoutCharacterViewModel: ObservableObject {
    @Published var isShowingBack: Bool = false
    @Published var rotationAngle: Double = 0
    @Published var characterScale: CGFloat = 1.0
    @Published var isRotating: Bool = false
    @Published var cardioBounce: Bool = false
    @Published var selectedMuscleForLabel: MuscleGroup? = nil
    
    // MARK: - Public Methods
    
    /// Alterna entre vista frontal y trasera del personaje
    func toggleView() {
        isShowingBack.toggle()
    }
    
    /// Realiza la rotación del personaje
    func performCharacterRotation() {
        toggleView()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    /// Maneja el gesto de arrastre del personaje
    func handleDragGesture(_ value: DragGesture.Value) {
        if !isRotating {
            rotationAngle = value.translation.width * 0.3
        }
    }
    
    /// Maneja el final del gesto de arrastre
    func handleDragEnd(_ value: DragGesture.Value) {
        if abs(value.translation.width) > 80 {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                toggleView()
                rotationAngle = 0
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                rotationAngle = 0
            }
        }
    }
    
    /// Inicia la animación de rebote del cardio
    func startCardioBounce() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            cardioBounce = true
        }
    }
    
    /// Selecciona un músculo para mostrar su etiqueta
    func selectMuscleForLabel(_ muscle: MuscleGroup?) {
        selectedMuscleForLabel = muscle
    }
    
    /// Verifica si un músculo está seleccionado
    func isMuscleSelected(_ muscle: MuscleGroup) -> Bool {
        selectedMuscleForLabel?.id == muscle.id
    }
} 