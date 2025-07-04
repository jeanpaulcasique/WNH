# 🥗 Sistema Nutricional Perfeccionado - WNH

## 📋 Descripción General

El sistema nutricional perfeccionado de WNH es una solución completa y avanzada para calcular planes nutricionales personalizados, predecir resultados a corto y largo plazo, y proporcionar recomendaciones específicas basadas en el perfil único de cada usuario.

## 🏗️ Arquitectura del Sistema

### Archivos Principales

1. **`NutritionCalculator.swift`** - Calculadora principal de nutrición
2. **`ResultSoon.swift`** - Predicción de resultados a corto y largo plazo
3. **`NutritionExample.swift`** - Ejemplos de uso y casos de prueba
4. **`README.md`** - Documentación completa

## 🎯 Características Principales

### ✅ Cálculos Nutricionales Avanzados
- **BMR (Metabolismo Basal)**: Fórmula Mifflin-St Jeor mejorada
- **TDEE (Gasto Energético Total)**: Ajustado por nivel de actividad e intensidad de entrenamiento
- **Macronutrientes**: Optimizados según tipo de dieta y objetivo
- **Distribución de Comidas**: Personalizada por tipo de dieta

### ✅ Tipos de Dieta Soportados
- **Keto**: 70% grasas, 25% proteína, 5% carbohidratos
- **Déficit Calórico**: 45% carbohidratos, 30% proteína, 25% grasas
- **Low-Carb**: 35% carbohidratos, 30% proteína, 35% grasas

### ✅ Análisis de Tipo de Cuerpo
- **Flaco** (BMI < 18.5): Metabolismo ligeramente más bajo
- **Regular** (BMI 18.5-24.9): Metabolismo estándar
- **Musculoso** (BMI 25.0-29.9): Metabolismo más alto
- **Gordo** (BMI > 30.0): Metabolismo ligeramente más alto

### ✅ Predicción de Resultados
- **Corto Plazo**: 4 semanas con progresión semanal
- **Largo Plazo**: 3, 6 y 12 meses
- **Factores Considerados**: Tipo de cuerpo, intensidad de entrenamiento, tipo de dieta, nivel de actividad

## 🚀 Uso del Sistema

### Inicialización Básica

```swift
// Crear calculadora con perfil del usuario
let userProfile = UserProfile.loadFromUserDefaults()
let calculator = NutritionCalculator(userProfile: userProfile)
let resultSoon = ResultSoon(userProfile: userProfile)

// Calcular plan nutricional completo
let nutritionPlan = calculator.generateCompleteNutritionPlan()
```

### Cálculo de Calorías Diarias

```swift
let dailyCalories = calculator.calculateDailyCalories()
print("Calorías diarias: \(dailyCalories) cal")
```

### Cálculo de Macronutrientes

```swift
let macros = calculator.calculateMacros()
print("Proteína: \(macros.protein)g")
print("Grasa: \(macros.fat)g")
print("Carbohidratos: \(macros.carbs)g")
```

### Predicción de Resultados

```swift
// Resultados a corto plazo (4 semanas)
let shortTermResults = resultSoon.calculateShortTermResults()
print("Cambio de peso en 4 semanas: \(shortTermResults.totalWeightChange) kg")

// Resultados a largo plazo (3, 6, 12 meses)
let longTermResults = resultSoon.calculateLongTermResults()
print("Cambio de peso en 12 meses: \(longTermResults.totalWeightChange) kg")
```

## 📊 Estructuras de Datos

### NutritionCalculator

```swift
struct CompleteNutritionPlan {
    let dailyCalories: Double
    let macros: MacroTargets
    let mealDistribution: [MealType: Double]
    let shortTermResults: ResultSoon.ShortTermResults
    let longTermResults: ResultSoon.LongTermResults
    let userProfile: UserProfile
    let recommendations: [String]
}
```

### ResultSoon

```swift
struct ShortTermResults {
    let week1: WeekResults
    let week2: WeekResults
    let week3: WeekResults
    let week4: WeekResults
}

struct WeekResults {
    let weekNumber: Int
    let weightChange: Double
    let muscleGain: Double
    let fatLoss: Double
    let energyLevel: String
    let motivation: String
    let tips: [String]
}
```

## 🎯 Algoritmos y Fórmulas

### Cálculo de BMR (Mifflin-St Jeor)

```swift
// Hombres
BMR = (10 × peso) + (6.25 × altura) - (5 × edad) + 5

// Mujeres
BMR = (10 × peso) + (6.25 × altura) - (5 × edad) - 161
```

### Factores de Actividad

- **Sedentario**: 1.2
- **Ligeramente activo**: 1.375
- **Moderadamente activo**: 1.55
- **Activo**: 1.725
- **Muy activo**: 1.9

### Factores de Intensidad de Entrenamiento

- **Suave**: 1.05
- **Intermedio**: 1.1
- **Intensivo**: 1.15

### Déficit/Superávit Calórico

- **Pérdida agresiva**: -750 cal
- **Pérdida moderada**: -500 cal
- **Pérdida suave**: -300 cal
- **Mantenimiento**: ±100 cal
- **Ganancia suave**: +300 cal
- **Ganancia moderada**: +500 cal
- **Ganancia agresiva**: +750 cal

## 🔧 Configuración Avanzada

### Ajustes por Tipo de Cuerpo

```swift
enum BodyType {
    case skinny      // Multiplicador BMR: 0.95
    case regular     // Multiplicador BMR: 1.0
    case muscular    // Multiplicador BMR: 1.05
    case overweight  // Multiplicador BMR: 1.02
}
```

### Proteína por Objetivo

```swift
// Pérdida de peso: 2.0g/kg
// Ganancia muscular: 2.2g/kg
// Mantenimiento: 1.8g/kg
```

### Distribución de Comidas por Dieta

```swift
// Keto: 25% desayuno, 35% almuerzo, 30% cena, 10% snacks
// Low-Carb: 30% desayuno, 40% almuerzo, 25% cena, 5% snacks
// Déficit: 30% desayuno, 35% almuerzo, 25% cena, 10% snacks
```

## 📈 Predicción de Resultados

### Factores de Progresión Semanal

- **Semana 1**: 1.2x (Efecto inicial)
- **Semana 2**: 1.1x
- **Semana 3**: 1.0x
- **Semana 4**: 0.9x

### Efectividad por Tipo de Dieta

- **Keto**: 1.3x (30% más efectivo)
- **Low-Carb**: 1.15x (15% más efectivo)
- **Déficit Calórico**: 1.0x (Efectividad estándar)

### Cambios Base por Objetivo

```swift
// Pérdida de peso
baseWeightChange = -0.5 kg/semana
baseMuscleGain = 0.1 kg/semana

// Ganancia muscular
baseWeightChange = 0.3 kg/semana
baseMuscleGain = 0.2 kg/semana

// Mantenimiento
baseWeightChange = 0.0 kg/semana
baseMuscleGain = 0.15 kg/semana
```

## 🧪 Ejemplos de Uso

### Ejecutar Todos los Ejemplos

```swift
NutritionExample.runAllExamples()
```

### Ejemplo Específico

```swift
// Usuario que quiere perder peso con dieta keto
NutritionExample.exampleWeightLossKeto()
```

## 🔍 Debugging y Logging

El sistema incluye logging detallado para debugging:

```swift
print("🎯 CÁLCULO NUTRICIONAL AVANZADO")
print("   • BMR: \(Int(bmr)) cal")
print("   • TDEE: \(Int(tdee)) cal")
print("   • Objetivo: \(Int(finalCalories)) cal")
print("   • Tipo de dieta: \(determineDietType().rawValue)")
```

## ⚠️ Límites de Seguridad

- **Calorías mínimas**: 1200 (mujeres) / 1500 (hombres)
- **Calorías máximas**: 5000
- **Proteína mínima**: 1.8g/kg
- **Proteína máxima**: 2.2g/kg

## 🎯 Casos de Uso Típicos

### 1. Pérdida de Peso con Keto
- Usuario: Mujer, 28 años, 75kg, 165cm
- Objetivo: Perder peso
- Dieta: Keto
- Actividad: Moderadamente activo
- Resultado esperado: -2.5kg en 4 semanas

### 2. Ganancia Muscular con Déficit
- Usuario: Hombre, 25 años, 65kg, 175cm
- Objetivo: Ganar músculo
- Dieta: Déficit calórico
- Actividad: Muy activo
- Resultado esperado: +1.2kg en 4 semanas

### 3. Mantenimiento con Low-Carb
- Usuario: Mujer, 32 años, 60kg, 160cm
- Objetivo: Mantenerse en forma
- Dieta: Low-carb
- Actividad: Activo
- Resultado esperado: ±0.5kg en 4 semanas

## 🔄 Integración con la App

### En DietViewModel

```swift
class DietViewModel: ObservableObject {
    private let nutritionCalculator: NutritionCalculator
    private let resultSoon: ResultSoon
    
    init() {
        let userProfile = UserProfile.loadFromUserDefaults()
        self.nutritionCalculator = NutritionCalculator(userProfile: userProfile)
        self.resultSoon = ResultSoon(userProfile: userProfile)
    }
    
    func loadNutritionData() {
        let nutritionPlan = nutritionCalculator.generateCompleteNutritionPlan()
        // Actualizar UI con los datos
    }
}
```

## 📚 Referencias Científicas

- **Fórmula Mifflin-St Jeor**: Estándar para cálculo de BMR
- **Factores de Actividad**: Basados en estudios de gasto energético
- **Ratios de Macronutrientes**: Según recomendaciones de la OMS y ACSM
- **Progresión de Resultados**: Basada en estudios de pérdida/ganancia de peso

## 🚀 Próximas Mejoras

1. **Machine Learning**: Predicciones más precisas basadas en datos históricos
2. **Integración con Wearables**: Datos de actividad en tiempo real
3. **Personalización Avanzada**: Ajustes por genética y metabolismo
4. **Análisis de Composición Corporal**: DEXA, bioimpedancia
5. **Recomendaciones de Suplementos**: Basadas en deficiencias nutricionales

---

**Desarrollado para WNH - Tu compañero de fitness y nutrición personalizado** 🏃‍♀️💪 