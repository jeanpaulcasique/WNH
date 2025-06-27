import SwiftUI
import Foundation
import Combine

// MARK: - Enhanced DietTypeDetails Model (Unified)
struct DietTypeDetails: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let howItWorks: String
    let benefits: [String]
    let considerations: [String]
    let color: Color
    let gradientColors: [Color]
    let icon: String
    let difficulty: String
    let timeToResults: String
    let macroSplit: String
    let badge: String?
    let badgeColor: Color?
    
    // New properties for enhanced design
    let macroBreakdown: MacroBreakdown
    let highlights: [String]
    let successRate: String
}

struct MacroBreakdown {
    let fat: Double
    let protein: Double
    let carbs: Double
}

enum AnimationPhase: Int, CaseIterable {
    case initial = 0
    case header = 1
    case icon = 2
    case title = 3
    case cards = 4
}

// MARK: - DietTypeViewModel
@MainActor
final class DietTypeViewModel: ObservableObject {
    @Published var currentIndex: Int {
        didSet {
            // ✅ Solo guardar en UserDefaults si hay una selección válida
            if currentIndex >= 0 {
                UserDefaults.standard.set(currentIndex, forKey: "dietTypeIndex")
                UserDefaults.standard.set(titles[currentIndex], forKey: "selectedDietType")
            }
        }
    }
    
    @Published var isLoading = false
    @Published var isNextButtonDisabled = false
    @Published var animationPhase: AnimationPhase = .initial
    @Published var userGoal: String = ""
    
    let imageNames = ["flame.fill", "leaf.fill", "scalemass.fill"]
    let titles = ["Keto", "Low‑Carb", "Calorie Deficit"]
    let shortDescriptions = [
        "High fat, very low carbs",
        "Balanced with reduced carbs",
        "Flexible calorie-focused"
    ]
    let detailedDescriptions = [
        "Transform your body into a fat-burning machine with high-fat, ultra-low carb nutrition",
        "Steady energy and sustainable weight loss with smart carbohydrate management",
        "Complete flexibility while maintaining a caloric deficit for consistent results"
    ]

    var imageCount: Int { imageNames.count }
    
    // ✅ Computed property para saber si hay una selección válida
    var hasValidSelection: Bool { currentIndex >= 0 }

    init() {
        // ✅ CAMBIO: Inicializar sin selección (-1 = no seleccionado)
        self.currentIndex = -1
        self.userGoal = UserDefaults.standard.string(forKey: "selectedGoal") ?? "Lose Weight"
    }

    func startStaggeredAnimations() {
        let animations: [(TimeInterval, AnimationPhase)] = [
            (0.2, .header),
            (0.4, .icon),
            (0.6, .title),
            (0.8, .cards)
        ]
        
        for (delay, phase) in animations {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    self.animationPhase = phase
                }
            }
        }
    }

    func disableNextButtonTemporarily() {
        isLoading = true
        isNextButtonDisabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoading = false
            self.isNextButtonDisabled = false
        }
    }
    
    func selectDiet(_ index: Int) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentIndex = index
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func getRecommendedDietIndex() -> Int {
        // ✅ Recomendación basada en el goal del usuario
        switch userGoal {
        case "Lose Weight": return 0  // Keto
        case "Keep Fit": return 1     // Low-Carb
        case "Build Muscle": return 2 // Calorie Deficit
        default: return 0
        }
    }
    
    func getDietDetails(for index: Int) -> DietTypeDetails {
        // ✅ Protección para índices negativos
        guard index >= 0 && index < imageCount else {
            return getDietDetails(for: 0) // Fallback
        }
        
        switch index {
        case 0: // Keto
            return DietTypeDetails(
                title: "Ketogenic Diet",
                subtitle: "Fat-Burning Powerhouse",
                description: "Transform your metabolism by entering ketosis - a state where your body burns fat for fuel instead of carbohydrates.",
                howItWorks: "By limiting carbs to under 20g daily and increasing fats to 70-80% of calories, your liver produces ketones that become your primary energy source.",
                benefits: [
                    "🔥 Rapid fat loss and appetite suppression",
                    "🧠 Enhanced mental clarity and focus",
                    "⚡ Stable energy without sugar crashes",
                    "🩺 Improved blood sugar and insulin sensitivity",
                    "💪 Preserved muscle mass during weight loss"
                ],
                considerations: [
                    "⚠️ Initial 'keto flu' adaptation period (1-2 weeks)",
                    "📊 Requires strict carb tracking and meal planning",
                    "🏃‍♂️ Athletic performance may decrease initially",
                    "💧 Need for increased water and electrolyte intake",
                    "👨‍⚕️ Consult healthcare provider before starting"
                ],
                color: .red,
                gradientColors: [.red, .orange],
                icon: "flame.fill",
                difficulty: "Advanced",
                timeToResults: "1-2 weeks",
                macroSplit: "75% Fat, 20% Protein, 5% Carbs",
                badge: nil,
                badgeColor: nil,
                macroBreakdown: MacroBreakdown(fat: 75, protein: 20, carbs: 5),
                highlights: ["Rapid ketosis", "Mental clarity", "Appetite control"],
                successRate: "97%"
            )
            
        case 1: // Low Carb
            return DietTypeDetails(
                title: "Low-Carb Diet",
                subtitle: "Balanced & Sustainable",
                description: "Enjoy steady weight loss with a moderate approach that maintains energy while promoting fat burning.",
                howItWorks: "Limit carbs to 50-150g daily while maintaining balanced protein and healthy fats for sustained energy and gradual fat loss.",
                benefits: [
                    "🎯 Sustainable long-term weight management",
                    "🍽️ Greater food variety and flexibility",
                    "📈 Steady, consistent weight loss",
                    "🏃‍♀️ Maintains workout performance",
                    "🌮 Easier to follow in social situations"
                ],
                considerations: [
                    "⏱️ Slower initial weight loss compared to keto",
                    "🔍 Still requires carb monitoring and quality choices",
                    "⚖️ Individual carb tolerance varies",
                    "🥬 Focus on nutrient-dense, whole food carbs",
                    "🎛️ May need adjustments to find optimal carb level"
                ],
                color: .green,
                gradientColors: [.green, .mint],
                icon: "leaf.fill",
                difficulty: "Moderate",
                timeToResults: "2-4 weeks",
                macroSplit: "40% Carbs, 30% Protein, 30% Fat",
                badge: nil,
                badgeColor: nil,
                macroBreakdown: MacroBreakdown(fat: 30, protein: 30, carbs: 40),
                highlights: ["Sustainable", "Food variety", "Workout friendly"],
                successRate: "94%"
            )
            
        case 2: // Calorie Deficit
            return DietTypeDetails(
                title: "Calorie Deficit",
                subtitle: "Science-Based Freedom",
                description: "The gold standard of weight loss - eat less than you burn while enjoying complete dietary freedom.",
                howItWorks: "Create a 300-500 calorie daily deficit through portion control, food choices, or increased activity. 3,500 calories = 1 pound of fat.",
                benefits: [
                    "🔓 Complete food freedom - no restrictions",
                    "🔬 Scientifically proven weight loss method",
                    "🎨 Fits any lifestyle or dietary preference",
                    "📚 Teaches valuable portion control skills",
                    "🏗️ Builds sustainable long-term habits"
                ],
                considerations: [
                    "📱 Requires calorie tracking and measurement",
                    "📖 Learning curve for calorie awareness",
                    "😋 Hunger management strategies needed",
                    "🐌 Slower but more sustainable progress",
                    "🥗 Must maintain nutrition within calorie limits"
                ],
                color: .blue,
                gradientColors: [.blue, .purple],
                icon: "scalemass.fill",
                difficulty: "Beginner",
                timeToResults: "2-3 weeks",
                macroSplit: "45% Carbs, 25% Protein, 30% Fat",
                badge: nil,
                badgeColor: nil,
                macroBreakdown: MacroBreakdown(fat: 30, protein: 25, carbs: 45),
                highlights: ["Complete freedom", "Science-based", "Build habits"],
                successRate: "96%"
            )
            
        default:
            return getDietDetails(for: 0)
        }
    }
}
