import Foundation
import UIKit

class ClarifaiService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    
    // Clarifai API Configuration
    private let apiKey = "YOUR_CLARIFAI_API_KEY" // TODO: Replace with actual API key
    private let baseURL = "https://api.clarifai.com/v2/models/food-item-recognition/outputs"
    private let modelID = "bd367be194cf45149e75f01d59f77ba7" // Food recognition model
    
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<[DetectedFood], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(ClarifaiError.invalidImage))
            return
        }
        
        DispatchQueue.main.async {
            self.isAnalyzing = true
            self.errorMessage = nil
        }
        
        let request = ClarifaiRequest(imageData: imageData)
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(ClarifaiError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(ClarifaiError.encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(.failure(ClarifaiError.noData))
                    return
                }
                
                do {
                    let clarifaiResponse = try JSONDecoder().decode(ClarifaiResponse.self, from: data)
                    let detectedFoods = self?.processClarifaiResponse(clarifaiResponse) ?? []
                    completion(.success(detectedFoods))
                } catch {
                    self?.errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    completion(.failure(ClarifaiError.parsingError))
                }
            }
        }.resume()
    }
    
    private func processClarifaiResponse(_ response: ClarifaiResponse) -> [DetectedFood] {
        guard let output = response.outputs.first else {
            return []
        }
        
        let concepts = output.data.concepts
        
        // Filter food items with confidence > 0.7 and convert to DetectedFood
        return concepts
            .filter { $0.value > 0.7 } // Only high confidence detections
            .prefix(5) // Limit to top 5 detections
            .map { concept in
                DetectedFood(
                    name: concept.name.capitalized,
                    confidence: concept.value,
                    calories: estimateCalories(for: concept.name),
                    category: "food"
                )
            }
    }
    
    private func estimateCalories(for foodName: String) -> Int {
        // Simple calorie estimation based on common foods
        // In a real app, you'd use a comprehensive food database
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

// MARK: - Clarifai Errors
enum ClarifaiError: Error, LocalizedError {
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