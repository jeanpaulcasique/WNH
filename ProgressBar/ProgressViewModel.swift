import SwiftUI
import SwiftUI

// MARK: - Phase Model
struct OnboardingPhase {
    let id: Int
    let title: String
    let color: Color
    let icon: String
}

// MARK: - ProgressViewModel
class ProgressViewModel: ObservableObject {
    @Published var currentPhase: Int = 0  // 0-3 (4 fases)
    @Published var phaseProgress: Double = 0.0  // 0.0-1.0 progreso dentro de la fase actual
    @Published var totalProgress: Double = 0.0  // 0.0-1.0 progreso total
    
    // COMPATIBILIDAD: Para que funcionen las pantallas existentes con bindings
    @Published var progress: Double = 0.0
    
    let phases = [
        OnboardingPhase(id: 0, title: "Physical Profile", color: .blue, icon: "person.fill"),
        OnboardingPhase(id: 1, title: "Fitness Goals", color: .red, icon: "target"),
        OnboardingPhase(id: 2, title: "Workout Preferences", color: .orange, icon: "dumbbell.fill"),
        OnboardingPhase(id: 3, title: "Nutrition Plan", color: .green, icon: "leaf.fill")
    ]
    
    // Configuración de pantallas por fase
    private let screensPerPhase = [
        3,  // Phase 0: Physical Profile (Gender, Height, Weight)
        4,  // Phase 1: Fitness Goals (Goal, Body Current, Target Weight, Age)
        4,  // Phase 2: Workout Preferences (Activity Level, Workout Level, Location, Equipment)
        2   // Phase 3: Nutrition Plan (Diet Type, Summary)
    ]
    
    private var currentScreenInPhase: Int = 0
    
    // COMPATIBILIDAD: Init que funciona con o sin totalScreens
    init(totalScreens: Int = 14) {
        // Nota: totalScreens se ignora porque ahora usamos sistema de fases
        updateTotalProgress()
    }
    
    func advanceProgress() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentScreenInPhase += 1
            
            // Calcular progreso dentro de la fase actual
            let totalScreensInCurrentPhase = screensPerPhase[currentPhase]
            phaseProgress = Double(currentScreenInPhase) / Double(totalScreensInCurrentPhase)
            
            // Si completamos la fase actual
            if currentScreenInPhase >= totalScreensInCurrentPhase {
                // Completar la fase actual
                phaseProgress = 1.0
                
                // Avanzar a la siguiente fase si no es la última
                if currentPhase < phases.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.currentPhase += 1
                            self.currentScreenInPhase = 0
                            self.phaseProgress = 0.0
                            self.updateTotalProgress()
                        }
                    }
                }
            }
            
            updateTotalProgress()
        }
    }
    
    func decreaseProgress() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if currentScreenInPhase > 0 {
                currentScreenInPhase -= 1
            } else if currentPhase > 0 {
                currentPhase -= 1
                currentScreenInPhase = screensPerPhase[currentPhase] - 1
            }
            
            // Recalcular progreso de la fase
            let totalScreensInCurrentPhase = screensPerPhase[currentPhase]
            phaseProgress = Double(currentScreenInPhase) / Double(totalScreensInCurrentPhase)
            
            updateTotalProgress()
        }
    }
    
    private func updateTotalProgress() {
        // Calcular progreso total: fases completadas + progreso de fase actual
        let completedPhases = Double(currentPhase) / Double(phases.count)
        let currentPhaseContribution = phaseProgress / Double(phases.count)
        totalProgress = completedPhases + currentPhaseContribution
        
        // Asegurar que no exceda 1.0
        totalProgress = min(totalProgress, 1.0)
        
        // COMPATIBILIDAD: Actualizar la propiedad progress para pantallas existentes
        progress = totalProgress
    }
    
    func resetProgress() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPhase = 0
            currentScreenInPhase = 0
            phaseProgress = 0.0
            totalProgress = 0.0
            progress = 0.0  // COMPATIBILIDAD
        }
    }
    
    // Getters para usar en la UI
    var currentPhaseInfo: OnboardingPhase {
        return phases[currentPhase]
    }
    
    var progressPercentage: Int {
        return Int(totalProgress * 100)
    }
}
