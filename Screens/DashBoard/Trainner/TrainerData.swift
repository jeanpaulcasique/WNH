import Foundation
import SwiftUI
import UIKit

// MARK: - Trainer Model
struct Trainer: Identifiable, Hashable {
    // Puede ser extendida para integración con backend/Firebase
    let id = UUID()
    let name: String
    let specialty: String
    let rating: Double
    let reviews: Int
    let experience: Int
    let pricePerSession: Int
    let isOnline: Bool
    let isVerified: Bool
    let bio: String
    let tags: [String]
    let certifications: [String]
    let totalClients: Int
    let languages: [String]
    let availability: [String]
    let responseTime: String
    let location: TrainerLocation
    let nextAvailable: String
    let isActive: Bool // Este campo será gestionado por backend/Firebase
    
    static func == (lhs: Trainer, rhs: Trainer) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - TrainerLocation
struct TrainerLocation: Codable, Hashable {
    // Puede ser extendida para integración con backend/Firebase
    let latitude: Double
    let longitude: Double
    let address: String
    let city: String
    let state: String
    
    init(lat: Double, lng: Double, address: String) {
        self.latitude = lat
        self.longitude = lng
        self.address = address
        
        // Extract city and state from address
        let components = address.components(separatedBy: ", ")
        self.city = components.first ?? ""
        self.state = components.last ?? ""
    }
}

// MARK: - TrainerSpecialty
enum TrainerSpecialty: String, CaseIterable {
    // Puede ser extendida para integración con backend/Firebase
    case weightLoss = "weightLoss"
    case muscleBuilding = "muscleBuilding"
    case strength = "strength"
    case cardio = "cardio"
    case yoga = "yoga"
    case crossfit = "crossfit"
    case nutrition = "nutrition"
    case rehabilitation = "rehabilitation"
    case pilates = "pilates"
    case boxing = "boxing"
    case swimming = "swimming"
    case running = "running"
    
    var displayName: String {
        switch self {
        case .weightLoss: return LanguageManager.localizedString("Weight Loss")
        case .muscleBuilding: return LanguageManager.localizedString("Muscle Building")
        case .strength: return LanguageManager.localizedString("Strength Training")
        case .cardio: return LanguageManager.localizedString("Cardio Expert")
        case .yoga: return LanguageManager.localizedString("Yoga Instructor")
        case .crossfit: return LanguageManager.localizedString("CrossFit Coach")
        case .nutrition: return LanguageManager.localizedString("Nutrition Expert")
        case .rehabilitation: return LanguageManager.localizedString("Rehabilitation")
        case .pilates: return LanguageManager.localizedString("Pilates")
        case .boxing: return LanguageManager.localizedString("Boxing")
        case .swimming: return LanguageManager.localizedString("Swimming")
        case .running: return LanguageManager.localizedString("Running Coach")
        }
    }
    
    var color: Color {
        switch self {
        case .weightLoss: return .red
        case .muscleBuilding: return .orange
        case .strength: return .purple
        case .cardio: return .blue
        case .yoga: return .green
        case .crossfit: return .yellow
        case .nutrition: return .mint
        case .rehabilitation: return .cyan
        case .pilates: return .pink
        case .boxing: return Color.red.opacity(0.8)
        case .swimming: return Color.blue.opacity(0.8)
        case .running: return .indigo
        }
    }
    
    var icon: String {
        switch self {
        case .weightLoss: return "flame.fill"
        case .muscleBuilding: return "dumbbell.fill"
        case .strength: return "figure.strengthtraining.traditional"
        case .cardio: return "heart.fill"
        case .yoga: return "figure.mind.and.body"
        case .crossfit: return "figure.highintensity.intervaltraining"
        case .nutrition: return "leaf.fill"
        case .rehabilitation: return "cross.fill"
        case .pilates: return "figure.pilates"
        case .boxing: return "figure.boxing"
        case .swimming: return "figure.pool.swim"
        case .running: return "figure.run"
        }
    }
}

// MARK: - TrainerCategory
enum TrainerCategory: String, CaseIterable {
    // Puede ser extendida para integración con backend/Firebase
    case all = "all"
    case weightLoss = "weightLoss"
    case muscleBuilding = "muscleBuilding"
    case strength = "strength"
    case cardio = "cardio"
    case yoga = "yoga"
    case crossfit = "crossfit"
    case nutrition = "nutrition"
    case rehabilitation = "rehabilitation"
    case pilates = "pilates"
    case boxing = "boxing"
    case swimming = "swimming"
    case running = "running"
    
    var displayName: String {
        switch self {
        case .all: return LanguageManager.localizedString("All")
        case .weightLoss: return LanguageManager.localizedString("Weight Loss")
        case .muscleBuilding: return LanguageManager.localizedString("Muscle")
        case .strength: return LanguageManager.localizedString("Strength")
        case .cardio: return LanguageManager.localizedString("Cardio")
        case .yoga: return LanguageManager.localizedString("Yoga")
        case .crossfit: return LanguageManager.localizedString("CrossFit")
        case .nutrition: return LanguageManager.localizedString("Nutrition")
        case .rehabilitation: return LanguageManager.localizedString("Rehab")
        case .pilates: return LanguageManager.localizedString("Pilates")
        case .boxing: return LanguageManager.localizedString("Boxing")
        case .swimming: return LanguageManager.localizedString("Swimming")
        case .running: return LanguageManager.localizedString("Running")
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "person.3.fill"
        case .weightLoss: return "flame.fill"
        case .muscleBuilding: return "dumbbell.fill"
        case .strength: return "figure.strengthtraining.traditional"
        case .cardio: return "heart.fill"
        case .yoga: return "figure.mind.and.body"
        case .crossfit: return "figure.highintensity.intervaltraining"
        case .nutrition: return "leaf.fill"
        case .rehabilitation: return "cross.fill"
        case .pilates: return "figure.pilates"
        case .boxing: return "figure.boxing"
        case .swimming: return "figure.pool.swim"
        case .running: return "figure.run"
        }
    }
}

// MARK: - ChatMessage
struct ChatMessage: Identifiable {
    // Puede ser extendida para integración con backend/Firebase
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let trainerId: UUID
    var image: UIImage? = nil
    var pdfURL: URL? = nil
    
    init(id: UUID = UUID(), text: String, isFromUser: Bool, timestamp: Date, trainerId: UUID, image: UIImage? = nil, pdfURL: URL? = nil) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.trainerId = trainerId
        self.image = image
        self.pdfURL = pdfURL
    }
}

// MARK: - TrainerData
struct TrainerData {
    // Puede ser extendida para integración con backend/Firebase
    // sampleTrainers es solo mock, en el futuro vendrá del repositorio/backend
    static let sampleTrainers: [Trainer] = [
        Trainer(
            name: "Sarah Mitchell",
            specialty: "Yoga",
            rating: 4.9,
            reviews: 120,
            experience: 8,
            pricePerSession: 40,
            isOnline: true,
            isVerified: true,
            bio: "Certified yoga instructor with 8 years of experience.",
            tags: ["Yoga", "Flexibility"],
            certifications: ["RYT 500"],
            totalClients: 200,
            languages: ["English", "Spanish"],
            availability: ["Monday", "Wednesday"],
            responseTime: "1h",
            location: TrainerLocation(lat: 40.7128, lng: -74.0060, address: "New York, NY"),
            nextAvailable: "Tomorrow",
            isActive: true // Mock, en el futuro vendrá del backend
        ),
        
        Trainer(
            name: "Marcus Johnson",
            specialty: "muscleBuilding",
            rating: 4.8,
            reviews: 189,
            experience: 12,
            pricePerSession: 95,
            isOnline: false,
            isVerified: true,
            bio: "Former competitive bodybuilder with 12+ years of experience. Specializing in muscle hypertrophy, strength gains, and competition prep.",
            tags: ["Hypertrophy", "Powerlifting", "Competition Prep", "Advanced Training"],
            certifications: ["NSCA-CSCS", "ACSM-CPT", "Bodybuilding Specialist"],
            totalClients: 189,
            languages: ["English"],
            availability: ["Daily: 5AM-9PM"],
            responseTime: "< 1 hour",
            location: TrainerLocation(lat: 34.0522, lng: -118.2437, address: "Los Angeles, CA"),
            nextAvailable: "Tomorrow 9:00 AM",
            isActive: true
        ),
        
        Trainer(
            name: "Emma Rodriguez",
            specialty: "yoga",
            rating: 4.9,
            reviews: 156,
            experience: 6,
            pricePerSession: 65,
            isOnline: true,
            isVerified: true,
            bio: "Certified yoga instructor focused on mind-body connection. Specializing in Vinyasa, Hatha, and therapeutic yoga for stress relief and flexibility.",
            tags: ["Vinyasa", "Meditation", "Flexibility", "Stress Relief"],
            certifications: ["RYT-500", "Yin Yoga Certified", "Meditation Teacher"],
            totalClients: 156,
            languages: ["English", "Portuguese"],
            availability: ["Mon-Sat: 7AM-7PM"],
            responseTime: "< 3 hours",
            location: TrainerLocation(lat: 25.7617, lng: -80.1918, address: "Miami, FL"),
            nextAvailable: "Today 6:00 PM",
            isActive: true
        ),
        
        Trainer(
            name: "Alex Turner",
            specialty: "crossfit",
            rating: 4.7,
            reviews: 98,
            experience: 5,
            pricePerSession: 80,
            isOnline: true,
            isVerified: true,
            bio: "CrossFit Level 2 trainer passionate about functional fitness. High-intensity workouts that build strength, endurance, and mental toughness.",
            tags: ["CrossFit", "Functional Fitness", "High Intensity", "Group Training"],
            certifications: ["CrossFit L2", "USAW Sports Performance", "First Aid"],
            totalClients: 98,
            languages: ["English"],
            availability: ["Mon-Sat: 6AM-8PM"],
            responseTime: "< 1 hour",
            location: TrainerLocation(lat: 41.8781, lng: -87.6298, address: "Chicago, IL"),
            nextAvailable: "Today 4:00 PM",
            isActive: true
        ),
        
        Trainer(
            name: "Dr. Rachel Adams",
            specialty: "rehabilitation",
            rating: 4.9,
            reviews: 167,
            experience: 15,
            pricePerSession: 120,
            isOnline: true,
            isVerified: true,
            bio: "Physical therapist and corrective exercise specialist. Helping clients recover from injuries and prevent future problems through targeted exercise.",
            tags: ["Injury Recovery", "Corrective Exercise", "Physical Therapy", "Pain Relief"],
            certifications: ["DPT", "CSCS", "Corrective Exercise Specialist"],
            totalClients: 167,
            languages: ["English", "Spanish"],
            availability: ["Mon-Fri: 8AM-5PM"],
            responseTime: "< 3 hours",
            location: TrainerLocation(lat: 32.7767, lng: -96.7970, address: "Dallas, TX"),
            nextAvailable: "Tomorrow 10:00 AM",
            isActive: true
        ),
        
        Trainer(
            name: "Sofia Chen",
            specialty: "pilates",
            rating: 4.8,
            reviews: 134,
            experience: 7,
            pricePerSession: 75,
            isOnline: true,
            isVerified: true,
            bio: "Certified Pilates instructor specializing in core strength, flexibility, and mind-body connection. Perfect for all fitness levels.",
            tags: ["Core Strength", "Flexibility", "Mind-Body", "All Levels"],
            certifications: ["PMA-CPT", "Mat Pilates", "Reformer Certified"],
            totalClients: 134,
            languages: ["English", "Mandarin"],
            availability: ["Daily: 7AM-8PM"],
            responseTime: "< 2 hours",
            location: TrainerLocation(lat: 37.7749, lng: -122.4194, address: "San Francisco, CA"),
            nextAvailable: "Today 5:00 PM",
            isActive: true
        )
    ]
}

// MARK: - Sample Extensions
extension Trainer {
    static let sample = TrainerData.sampleTrainers.first!
}

// Este archivo debe ir en la nueva carpeta Repository/TrainerRepositoryProtocol.swift

import Foundation

protocol TrainerRepositoryProtocol {
    func fetchTrainers(completion: @escaping ([Trainer]) -> Void)
}
