import SwiftUI

/// Manager que maneja las posiciones de los músculos
class MusclePositionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var positionsLoaded: Bool = false
    
    // MARK: - Private Properties
    private var frontMuscleGroups: [MuscleGroup] = []
    private var backMuscleGroups: [MuscleGroup] = []
    
    // MARK: - Initialization
    
    init() {
        loadPositionsSynchronously()
    }
    
    // MARK: - Public Methods
    
    /// Carga las posiciones de forma síncrona
    private func loadPositionsSynchronously() {
        // Cargar músculos frontales y traseros de forma síncrona
        let frontGroups = MuscleButtonPositions.frontMuscles.map { musclePos in
            MuscleGroup(
                name: musclePos.name,
                exercises: [],
                position: musclePos.position,
                isLeftSide: musclePos.isLeftSide
            )
        }
        
        let backGroups = MuscleButtonPositions.backMuscles.map { musclePos in
            MuscleGroup(
                name: musclePos.name,
                exercises: [],
                position: musclePos.position,
                isLeftSide: musclePos.isLeftSide
            )
        }
        
        self.frontMuscleGroups = frontGroups
        self.backMuscleGroups = backGroups
        self.positionsLoaded = true
    }
    
    /// Carga músculos para una vista específica
    func loadMuscleGroupsForView(isBack: Bool) async throws -> [MuscleGroup] {
        if isBack {
            // Músculos traseros - usando el sistema de posiciones
            return MuscleButtonPositions.backMuscles.map { musclePos in
                MuscleGroup(
                    name: musclePos.name,
                    exercises: [],
                    position: musclePos.position,
                    isLeftSide: musclePos.isLeftSide
                )
            }
        } else {
            // Músculos delanteros - usando el sistema de posiciones
            return MuscleButtonPositions.frontMuscles.map { musclePos in
                MuscleGroup(
                    name: musclePos.name,
                    exercises: [],
                    position: musclePos.position,
                    isLeftSide: musclePos.isLeftSide
                )
            }
        }
    }
    
    /// Obtiene los músculos frontales
    func getFrontMuscleGroups() -> [MuscleGroup] {
        return frontMuscleGroups
    }
    
    /// Obtiene los músculos traseros
    func getBackMuscleGroups() -> [MuscleGroup] {
        return backMuscleGroups
    }
    
    /// Obtiene los músculos correctos según la vista actual
    func getCurrentMuscleGroups(isBack: Bool) -> [MuscleGroup] {
        return isBack ? backMuscleGroups : frontMuscleGroups
    }
    
    /// Actualiza los músculos según la vista actual
    func updateMuscleGroupsForCurrentView(isBack: Bool) -> [MuscleGroup] {
        if isBack {
            return backMuscleGroups
        } else {
            return frontMuscleGroups
        }
    }
} 