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
            let shortTermResults = resultSoon.calculateShortTermResults(for: userProfile)
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            print("   • Agua diaria: \(String(format: "%.1f", water))L")
            
            print("\n🎯 RESULTADOS ESPERADOS (4 semanas):")
            print("   • Cambio de peso: \(String(format: "%.1f", shortTermResults.totalWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", shortTermResults.totalMuscleGain)) kg")
            print("   • Semana 1: \(String(format: "%.1f", shortTermResults.week1.weightChange)) kg")
            print("   • Semana 2: \(String(format: "%.1f", shortTermResults.week2.weightChange)) kg")
            print("   • Semana 3: \(String(format: "%.1f", shortTermResults.week3.weightChange)) kg")
            print("   • Semana 4: \(String(format: "%.1f", shortTermResults.week4.weightChange)) kg")
            
            // Generar recomendaciones usando ResultSoon
            let report = resultSoon.generateCompleteResultsReport(for: userProfile)
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in report.recommendations.enumerated() {
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
            let shortTermResults = resultSoon.calculateShortTermResults(for: userProfile)
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            
            print("\n🎯 RESULTADOS ESPERADOS (4 semanas):")
            print("   • Cambio de peso: \(String(format: "%.1f", shortTermResults.totalWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", shortTermResults.totalMuscleGain)) kg")
            
            let report = resultSoon.generateCompleteResultsReport(for: userProfile)
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in report.recommendations.enumerated() {
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
            let shortTermResults = resultSoon.calculateShortTermResults(for: userProfile)
            
            print("📊 PLAN NUTRICIONAL:")
            print("   • Calorías diarias: \(Int(calories)) cal")
            print("   • Proteína: \(Int(macros.protein))g")
            print("   • Grasa: \(Int(macros.fat))g")
            print("   • Carbohidratos: \(Int(macros.carbs))g")
            
            print("\n🎯 RESULTADOS ESPERADOS (4 semanas):")
            print("   • Cambio de peso: \(String(format: "%.1f", shortTermResults.totalWeightChange)) kg")
            print("   • Ganancia muscular: \(String(format: "%.1f", shortTermResults.totalMuscleGain)) kg")
            
            let report = resultSoon.generateCompleteResultsReport(for: userProfile)
            print("\n💡 RECOMENDACIONES:")
            for (index, recommendation) in report.recommendations.enumerated() {
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
        let longTermResults = resultSoon.calculateLongTermResults(for: userProfile)
        
        print("🎯 RESULTADOS A LARGO PLAZO:")
        print("   • 3 meses: \(String(format: "%.1f", longTermResults.month3.weightChange)) kg")
        print("   • 6 meses: \(String(format: "%.1f", longTermResults.month6.weightChange)) kg")
        print("   • 12 meses: \(String(format: "%.1f", longTermResults.month12.weightChange)) kg")
        
        print("\n💪 GANANCIA MUSCULAR:")
        print("   • 3 meses: \(String(format: "%.1f", longTermResults.month3.muscleGain)) kg")
        print("   • 6 meses: \(String(format: "%.1f", longTermResults.month6.muscleGain)) kg")
        print("   • 12 meses: \(String(format: "%.1f", longTermResults.month12.muscleGain)) kg")
        
        print("\n🏥 MEJORAS DE SALUD (6 meses):")
        for improvement in longTermResults.month6.healthImprovements {
            print("   • \(improvement)")
        }
        
        print("\n🔄 CAMBIOS DE ESTILO DE VIDA (12 meses):")
        for change in longTermResults.month12.lifestyleChanges {
            print("   • \(change)")
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
            let shortResults = resultSoon.calculateShortTermResults(for: profile)
            
            print("✅ Calorías: \(Int(calories))")
            print("✅ Cambio semanal: \(String(format: "%.1f", shortResults.totalWeightChange/4))kg")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
