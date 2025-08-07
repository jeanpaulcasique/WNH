import Foundation
import UIKit

class LogMealService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    
    // LogMeal API Configuration
    private let apiKey = "YOUR_LOGMEAL_API_KEY" // Replace with your actual LogMeal API key
    private let baseURL = "https://api.logmeal.es/v2"
    private let endpoint = "/recognition/dish"
    
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<[DetectedFood], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(LogMealError.invalidImage))
            return
        }
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.errorMessage = nil
        }
        
        // Create multipart form data request
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: baseURL + endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"food.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add confidence parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"confidence\"\r\n\r\n".data(using: .utf8)!)
        body.append("0.8".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                }
                completion(.failure(LogMealError.noData))
                return
            }
            
            do {
                let logMealResponse = try JSONDecoder().decode(LogMealResponse.self, from: data)
                let detectedFoods = self?.processLogMealResponse(logMealResponse) ?? []
                completion(.success(detectedFoods))
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                }
                completion(.failure(LogMealError.parsingError))
            }
        }.resume()
    }
    
    private func processLogMealResponse(_ response: LogMealResponse) -> [DetectedFood] {
        var detectedFoods: [DetectedFood] = []
        
        // Process main dish recognition
        if let dish = response.recognition_results?.dish {
            detectedFoods.append(DetectedFood(
                name: dish.name,
                confidence: dish.confidence,
                calories: dish.calories ?? estimateCalories(for: dish.name),
                category: "main_dish"
            ))
        }
        
        // Process food items
        if let foodItems = response.recognition_results?.food_items {
            for item in foodItems {
                detectedFoods.append(DetectedFood(
                    name: item.name,
                    confidence: item.confidence,
                    calories: item.calories ?? estimateCalories(for: item.name),
                    category: "food_item"
                ))
            }
        }
        
        // Sort by confidence and limit to top 5
        return detectedFoods
            .sorted { $0.confidence > $1.confidence }
            .prefix(5)
            .map { $0 }
    }
    
    private func estimateCalories(for foodName: String) -> Int {
        // Fallback calorie estimation based on common foods
        let lowercasedName = foodName.lowercased()
        
        switch lowercasedName {
        case let name where name.contains("apple"): return 95
        case let name where name.contains("banana"): return 105
        case let name where name.contains("chicken"): return 165
        case let name where name.contains("rice"): return 130
        case let name where name.contains("bread"): return 80
        case let name where name.contains("pizza"): return 285
        case let name where name.contains("burger"): return 350
        case let name where name.contains("salad"): return 50
        case let name where name.contains("pasta"): return 200
        case let name where name.contains("fish"): return 120
        case let name where name.contains("beef"): return 250
        case let name where name.contains("pork"): return 200
        case let name where name.contains("egg"): return 70
        case let name where name.contains("milk"): return 120
        case let name where name.contains("cheese"): return 110
        case let name where name.contains("yogurt"): return 150
        case let name where name.contains("cake"): return 300
        case let name where name.contains("cookie"): return 150
        case let name where name.contains("ice cream"): return 250
        default: return 100 // Default estimation
        }
    }
}

// MARK: - LogMeal API Models
struct LogMealResponse: Codable {
    let recognition_results: LogMealRecognitionResults?
    let status: String?
    let message: String?
}

struct LogMealRecognitionResults: Codable {
    let dish: LogMealDish?
    let food_items: [LogMealFoodItem]?
}

struct LogMealDish: Codable {
    let name: String
    let confidence: Double
    let calories: Int?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
}

struct LogMealFoodItem: Codable {
    let name: String
    let confidence: Double
    let calories: Int?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
}

// MARK: - LogMeal Errors
enum LogMealError: Error, LocalizedError {
    case invalidImage
    case invalidURL
    case encodingError
    case noData
    case parsingError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .noData:
            return "No data received from API"
        case .parsingError:
            return "Failed to parse API response"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
} 