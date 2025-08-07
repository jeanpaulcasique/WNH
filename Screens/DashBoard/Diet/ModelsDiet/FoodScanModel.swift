import Foundation

// MARK: - Food Scan Models
struct FoodScan: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let imageData: Data?
    let detectedFoods: [DetectedFood]
    let totalCalories: Int
    let confidence: Double
    
    init(detectedFoods: [DetectedFood], imageData: Data? = nil) {
        self.date = Date()
        self.imageData = imageData
        self.detectedFoods = detectedFoods
        self.totalCalories = detectedFoods.reduce(0) { $0 + $1.calories }
        self.confidence = detectedFoods.isEmpty ? 0 : detectedFoods.map { $0.confidence }.reduce(0, +) / Double(detectedFoods.count)
    }
}

struct DetectedFood: Identifiable, Codable {
    let id = UUID()
    let name: String
    let confidence: Double
    let calories: Int
    let category: String
    
    init(name: String, confidence: Double, calories: Int = 0, category: String = "food") {
        self.name = name
        self.confidence = confidence
        self.calories = calories
        self.category = category
    }
}

// MARK: - Clarifai API Models
struct ClarifaiRequest: Codable {
    let inputs: [ClarifaiInput]
    
    init(imageData: Data) {
        self.inputs = [ClarifaiInput(data: ClarifaiImageData(base64: imageData.base64EncodedString()))]
    }
}

struct ClarifaiInput: Codable {
    let data: ClarifaiImageData
}

struct ClarifaiImageData: Codable {
    let base64: String
}

struct ClarifaiResponse: Codable {
    let outputs: [ClarifaiOutput]
}

struct ClarifaiOutput: Codable {
    let data: ClarifaiData
}

struct ClarifaiData: Codable {
    let concepts: [ClarifaiConcept]
}

struct ClarifaiConcept: Codable {
    let name: String
    let value: Double
} 