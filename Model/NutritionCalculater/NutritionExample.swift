import Foundation
import SwiftUI

// MARK: - NutritionExample - Ejemplos Corregidos para el Sistema Mejorado

class NutritionExample {
    
    // MARK: - Ejemplos de Casos de Uso
    
    /// Ejemplo 1: Usuario que quiere perder peso con dieta keto
    static func exampleWeightLossKeto() async {
        print("🏃‍♀️ EJEMPLO 1: PÉRDIDA DE PESO CON DIETA KETO")
        print(String(repeating: "=", count: 50))
        
        let userProfile = createSampleUserProfile(
            gender: "Female",
            age: 28,
            weight: 75.0,
            height: 165,
            goal: "Perder peso",
            dietType: "Keto",
            activityLevel: "Moderadamente activo",
            workoutIntensity: "Intermedio"
        )
        
        let calculator = NutritionCalculator()
        let resultSoon = ResultSoon(userProfile: userProfile)
        
        do {
            // Usar métodos async del calculator mejorado
            let calories = try await calculator.calculateDailyCalories(for: userProfile)
            let macros = try await calculator.calculateMacros(for: userProfile)
            let water = try await calculator.calculateWaterNeeds(for: userProfile)
            let scientificResults = resultSoon.calculateScientificResults()
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            print("   • Agua diaria: \(String(format: "%.1f", water))L")
            
            print("\n🎯 RESULTADOS CIENTÍFICOS:")
            print("   • Peso objetivo: \(String(format: "%.1f", scientificResults.targetWeight)) kg")
            print("   • Tiempo al objetivo: \(scientificResults.adjustedTimeToTarget) días")
            print("   • Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", scientificResults.muscleGain)) kg/mes")
            print("   • Probabilidad éxito: \(Int(scientificResults.successProbability * 100))%")
            
            // Generar recomendaciones usando ResultSoon
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in scientificResults.recommendations.enumerated() {
                print("   \(index + 1). \(recommendation)")
            }
            
        } catch {
            print("❌ Error en ejemplo 1: \(error.localizedDescription)")
        }
    }
    
    /// Ejemplo 2: Usuario que quiere ganar músculo
    static func exampleMuscleGainCaloricDeficit() async {
        print("\n💪 EJEMPLO 2: GANANCIA DE MÚSCULO")
        print(String(repeating: "=", count: 50))
        
        let userProfile = createSampleUserProfile(
            gender: "Male",
            age: 25,
            weight: 65.0,
            height: 175,
            goal: "Ganar músculo",
            dietType: "Balanceada",
            activityLevel: "Muy activo",
            workoutIntensity: "Intensivo"
        )
        
        let calculator = NutritionCalculator()
        let resultSoon = ResultSoon(userProfile: userProfile)
        
        do {
            let calories = try await calculator.calculateDailyCalories(for: userProfile)
            let macros = try await calculator.calculateMacros(for: userProfile)
            let scientificResults = resultSoon.calculateScientificResults()
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            
            print("\n🎯 RESULTADOS CIENTÍFICOS:")
            print("   • Peso objetivo: \(String(format: "%.1f", scientificResults.targetWeight)) kg")
            print("   • Tiempo al objetivo: \(scientificResults.adjustedTimeToTarget) días")
            print("   • Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", scientificResults.muscleGain)) kg/mes")
            print("   • Probabilidad éxito: \(Int(scientificResults.successProbability * 100))%")
            
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in scientificResults.recommendations.enumerated() {
                print("   \(index + 1). \(recommendation)")
            }
            
        } catch {
            print("❌ Error en ejemplo 2: \(error.localizedDescription)")
        }
    }
    
    /// Ejemplo 3: Usuario que quiere mantenerse en forma con low-carb
    static func exampleMaintenanceLowCarb() async {
        print("\n⚖️ EJEMPLO 3: MANTENIMIENTO CON DIETA LOW-CARB")
        print(String(repeating: "=", count: 50))
        
        let userProfile = createSampleUserProfile(
            gender: "Female",
            age: 32,
            weight: 60.0,
            height: 160,
            goal: "Mantenerse en forma",
            dietType: "Bajo en Carbohidratos",
            activityLevel: "Activo",
            workoutIntensity: "Moderado"
        )
        
        let calculator = NutritionCalculator()
        let resultSoon = ResultSoon(userProfile: userProfile)
        
        do {
            let calories = try await calculator.calculateDailyCalories(for: userProfile)
            let macros = try await calculator.calculateMacros(for: userProfile)
            let scientificResults = resultSoon.calculateScientificResults()
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            
            print("\n🎯 RESULTADOS CIENTÍFICOS:")
            print("   • Peso objetivo: \(String(format: "%.1f", scientificResults.targetWeight)) kg")
            print("   • Tiempo al objetivo: \(scientificResults.adjustedTimeToTarget) días")
            print("   • Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", scientificResults.muscleGain)) kg/mes")
            print("   • Probabilidad éxito: \(Int(scientificResults.successProbability * 100))%")
            
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in scientificResults.recommendations.enumerated() {
                print("   \(index + 1). \(recommendation)")
            }
            
        } catch {
            print("❌ Error en ejemplo 3: \(error.localizedDescription)")
        }
    }
    
    /// Ejemplo 4: Comparación de diferentes tipos de cuerpo
    static func exampleBodyTypeComparison() async {
        print("\n🔍 EJEMPLO 4: COMPARACIÓN POR TIPO DE CUERPO")
        print(String(repeating: "=", count: 50))
        
        let bodyTypes = ["Flaco", "Regular", "Musculoso", "Gordo"]
        let goals = ["Perder peso", "Ganar músculo"]
        
        for goal in goals {
            print("\n🎯 OBJETIVO: \(goal)")
            print(String(repeating: "-", count: 30))
            
            for bodyType in bodyTypes {
                let userProfile = createSampleUserProfile(
                    gender: "Male",
                    age: 30,
                    weight: getWeightForBodyType(bodyType),
                    height: 175,
                    goal: goal,
                    dietType: "Balanceada",
                    activityLevel: "Moderadamente activo",
                    workoutIntensity: "Intermedio"
                )
                
                let calculator = NutritionCalculator()
                
                do {
                    let calories = try await calculator.calculateDailyCalories(for: userProfile)
                    let macros = try await calculator.calculateMacros(for: userProfile)
                    
                    print("   \(bodyType): \(Int(calories)) cal, \(Int(macros.protein))g proteína")
                } catch {
                    print("   \(bodyType): Error al calcular")
                }
            }
        }
    }
    
    /// Ejemplo 5: Análisis de resultados a largo plazo
    static func exampleLongTermAnalysis() {
        print("\n📈 EJEMPLO 5: ANÁLISIS DE RESULTADOS A LARGO PLAZO")
        print(String(repeating: "=", count: 50))
        
        let userProfile = createSampleUserProfile(
            gender: "Female",
            age: 26,
            weight: 70.0,
            height: 165,
            goal: "Perder peso",
            dietType: "Keto",
            activityLevel: "Activo",
            workoutIntensity: "Intensivo"
        )
        
        let resultSoon = ResultSoon(userProfile: userProfile)
        let scientificResults = resultSoon.calculateScientificResults()
        
        print("🎯 RESULTADOS CIENTÍFICOS:")
        print("   • Peso objetivo: \(String(format: "%.1f", scientificResults.targetWeight)) kg")
        print("   • Tiempo al objetivo: \(scientificResults.adjustedTimeToTarget) días")
        print("   • Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange)) kg")
        print("   • Ganancia muscular: \(String(format: "%.1f", scientificResults.muscleGain)) kg/mes")
        print("   • Probabilidad éxito: \(Int(scientificResults.successProbability * 100))%")
        
        print("\n💡 RECOMENDACIONES:")
        for (index, recommendation) in scientificResults.recommendations.enumerated() {
            print("   \(index + 1). \(recommendation)")
        }
        
        print("\n🔄 MILESTONES:")
        for (index, milestone) in scientificResults.milestones.enumerated() {
            print("   • Día \(milestone.day): \(milestone.description)")
        }
    }
    
    // MARK: - Helpers
    
    private static func createSampleUserProfile(
        gender: String,
        age: Int,
        weight: Double,
        height: Int,
        goal: String,
        dietType: String,
        activityLevel: String,
        workoutIntensity: String
    ) -> UserProfile {
        
        // Crear perfil directamente sin usar UserDefaults
        let profile = UserProfile()
        
        // Usar reflection o propiedades públicas para configurar
        // Nota: Esto depende de cómo esté implementado tu UserProfile
        // Si UserProfile no tiene setters públicos, necesitarás ajustar la implementación
        
        return profile
    }
    
    private static func getWeightForBodyType(_ bodyType: String) -> Double {
        switch bodyType {
        case "Flaco": return 55.0
        case "Regular": return 70.0
        case "Musculoso": return 85.0
        case "Gordo": return 95.0
        default: return 70.0
        }
    }
    
    /// Ejecuta todos los ejemplos
    static func runAllExamples() async {
        print("🚀 EJECUTANDO TODOS LOS EJEMPLOS DEL SISTEMA NUTRICIONAL")
        print(String(repeating: "=", count: 60))
        
        await exampleWeightLossKeto()
        await exampleMuscleGainCaloricDeficit()
        await exampleMaintenanceLowCarb()
        await exampleBodyTypeComparison()
        exampleLongTermAnalysis()
        
        print("\n✅ TODOS LOS EJEMPLOS COMPLETADOS")
        print(String(repeating: "=", count: 60))
    }
}

// MARK: - Uso del Example
extension NutritionExample {
    
    /// Método de conveniencia para testing rápido
    static func quickTest() async {
        print("🧪 PRUEBA RÁPIDA DEL SISTEMA")
        
        // Crear perfil simple
        let profile = UserProfile.loadFromUserDefaults()
        let calculator = NutritionCalculator()
        let resultSoon = ResultSoon()
        
        do {
            let calories = try await calculator.calculateDailyCalories(for: profile)
            let scientificResults = resultSoon.calculateScientificResults()
            
            print("✅ Calorías: \(Int(calories))")
            print("✅ Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange))kg")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
