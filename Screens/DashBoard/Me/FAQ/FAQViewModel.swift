import SwiftUI
import Foundation

// MARK: - Models
struct FAQ: Identifiable, Codable {
    let id = UUID()
    let question: String
    let answer: String
    let category: FAQCategory
    let tags: [String]
    let lastUpdated: Date
    var viewCount: Int
    var helpfulCount: Int
    var isMarkedHelpful: Bool
    let priority: Int // Higher number = higher priority
    
    init(question: String, answer: String, category: FAQCategory, tags: [String] = [], priority: Int = 0) {
        self.question = question
        self.answer = answer
        self.category = category
        self.tags = tags
        self.lastUpdated = Date()
        self.viewCount = Int.random(in: 50...500) // Mock data
        self.helpfulCount = Int.random(in: 10...100) // Mock data
        self.isMarkedHelpful = false
        self.priority = priority
    }
}

enum FAQCategory: String, CaseIterable, Codable {
    case all = "all"
    case workouts = "workouts"
    case nutrition = "nutrition"
    case account = "account"
    case subscription = "subscription"
    case technical = "technical"
    case general = "general"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .workouts: return "Workouts"
        case .nutrition: return "Nutrition"
        case .account: return "Account"
        case .subscription: return "Subscription"
        case .technical: return "Technical"
        case .general: return "General"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .workouts: return "figure.strengthtraining.traditional"
        case .nutrition: return "fork.knife"
        case .account: return "person.circle"
        case .subscription: return "crown"
        case .technical: return "gear"
        case .general: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .appYellow
        case .workouts: return .red
        case .nutrition: return .green
        case .account: return .blue
        case .subscription: return .purple
        case .technical: return .orange
        case .general: return .gray
        }
    }
}

// MARK: - FAQViewModel
final class FAQViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var faqs: [FAQ] = []
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let faqDataKey = "saved_faq_data"
    
    // MARK: - Computed Properties
    var totalFAQs: Int {
        faqs.count
    }
    
    var totalViews: Int {
        faqs.reduce(0) { $0 + $1.viewCount }
    }
    
    var helpfulCount: Int {
        faqs.reduce(0) { $0 + $1.helpfulCount }
    }
    
    // MARK: - Initialization
    init() {
        loadSavedFAQs()
        if faqs.isEmpty {
            generateSampleFAQs()
        }
    }
    
    // MARK: - Public Methods
    func loadFAQs() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func getFilteredFAQs(category: FAQCategory, searchText: String) -> [FAQ] {
        var filtered = faqs
        
        // Filter by category
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { faq in
                faq.question.localizedCaseInsensitiveContains(searchText) ||
                faq.answer.localizedCaseInsensitiveContains(searchText) ||
                faq.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort by priority and helpful count
        return filtered.sorted { first, second in
            if first.priority != second.priority {
                return first.priority > second.priority
            }
            return first.helpfulCount > second.helpfulCount
        }
    }
    
    func getCountFor(category: FAQCategory) -> Int {
        if category == .all {
            return faqs.count
        }
        return faqs.filter { $0.category == category }.count
    }
    
    func incrementViews(for id: UUID) {
        if let index = faqs.firstIndex(where: { $0.id == id }) {
            faqs[index].viewCount += 1
            saveFAQs()
        }
    }
    
    func markAsHelpful(_ id: UUID) {
        if let index = faqs.firstIndex(where: { $0.id == id }) {
            faqs[index].isMarkedHelpful.toggle()
            if faqs[index].isMarkedHelpful {
                faqs[index].helpfulCount += 1
            } else {
                faqs[index].helpfulCount = max(0, faqs[index].helpfulCount - 1)
            }
            saveFAQs()
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func addFAQ(_ faq: FAQ) {
        faqs.append(faq)
        saveFAQs()
    }
    
    // MARK: - Private Methods
    private func generateSampleFAQs() {
        faqs = [
            // Workouts
            FAQ(
                question: "How do I start my first workout?",
                answer: "Getting started is easy! Navigate to the Workouts tab, choose 'Recommended for You' section, and select a beginner-friendly workout. Each workout includes step-by-step instructions, video demonstrations, and progress tracking. Start with shorter sessions (15-20 minutes) and gradually increase duration as you build stamina.",
                category: .workouts,
                tags: ["beginner", "start", "first"],
                priority: 10
            ),
            
            FAQ(
                question: "Can I modify workouts for my fitness level?",
                answer: "Absolutely! All our workouts include modifications for different fitness levels. Look for the 'Modify' button during exercises to see easier or harder variations. You can also adjust weights, repetitions, and rest periods. Our AI adapts recommendations based on your performance and feedback.",
                category: .workouts,
                tags: ["modify", "difficulty", "beginner", "advanced"],
                priority: 8
            ),
            
            FAQ(
                question: "How often should I work out?",
                answer: "For beginners, we recommend 3-4 workout sessions per week with rest days in between. More experienced users can work out 5-6 times per week. Listen to your body and ensure adequate recovery. Our app tracks your workout frequency and suggests optimal rest periods based on your activity level.",
                category: .workouts,
                tags: ["frequency", "schedule", "rest"],
                priority: 7
            ),
            
            // Nutrition
            FAQ(
                question: "How do I track my nutrition?",
                answer: "Use our built-in nutrition tracker to log meals and snacks. You can scan barcodes, search our extensive food database, or create custom meals. The app calculates calories, macronutrients, and provides insights about your eating patterns. Set goals based on your fitness objectives and track progress over time.",
                category: .nutrition,
                tags: ["tracking", "calories", "food", "macros"],
                priority: 9
            ),
            
            FAQ(
                question: "What diet plans do you support?",
                answer: "We support various diet approaches including Ketogenic, Low-Carb, Mediterranean, Intermittent Fasting, and general Calorie Deficit plans. Each plan includes meal suggestions, shopping lists, and macro targets. You can switch between plans anytime or create a custom approach that fits your lifestyle.",
                category: .nutrition,
                tags: ["diet", "keto", "low-carb", "plans"],
                priority: 6
            ),
            
            // Account
            FAQ(
                question: "How do I change my account settings?",
                answer: "Go to the Me tab and tap 'Settings'. Here you can update your profile information, change your password, modify notification preferences, and adjust privacy settings. Changes are automatically synced across all your devices. For email changes, you'll need to verify the new email address.",
                category: .account,
                tags: ["settings", "profile", "password"],
                priority: 5
            ),
            
            FAQ(
                question: "How do I sync data across devices?",
                answer: "Your data automatically syncs when you're logged into the same account on multiple devices. Ensure you have a stable internet connection and the latest app version. Workout history, progress photos, and nutrition logs are stored securely in the cloud and accessible from any device.",
                category: .account,
                tags: ["sync", "devices", "cloud", "data"],
                priority: 4
            ),
            
            // Subscription
            FAQ(
                question: "What's included in the Premium subscription?",
                answer: "Premium includes unlimited access to all workout programs, personalized meal plans, 1-on-1 coaching sessions, advanced analytics, ad-free experience, and priority customer support. You also get exclusive content, early access to new features, and detailed progress insights with custom reports.",
                category: .subscription,
                tags: ["premium", "features", "benefits"],
                priority: 8
            ),
            
            FAQ(
                question: "How do I cancel my subscription?",
                answer: "You can cancel anytime through your device's subscription settings (App Store or Google Play) or through our app in Me > Subscription > Manage. Cancellation takes effect at the end of your current billing period. You'll retain Premium access until then and can reactivate anytime without losing your data.",
                category: .subscription,
                tags: ["cancel", "billing", "refund"],
                priority: 7
            ),
            
            // Technical
            FAQ(
                question: "The app is running slowly. What should I do?",
                answer: "Try these steps: 1) Close and restart the app, 2) Restart your device, 3) Check for app updates in the App Store, 4) Ensure you have adequate storage space (at least 1GB free), 5) Check your internet connection. If issues persist, contact support with your device model and iOS version.",
                category: .technical,
                tags: ["slow", "performance", "lag", "bug"],
                priority: 6
            ),
            
            FAQ(
                question: "My workout videos won't play. Help!",
                answer: "Video playback issues are usually related to internet connectivity. Ensure you have a stable connection (WiFi recommended for HD videos). You can also download videos for offline viewing in Settings > Downloads. Clear the app cache if videos still won't load, or try switching between WiFi and cellular data.",
                category: .technical,
                tags: ["video", "streaming", "download", "offline"],
                priority: 5
            ),
            
            // General
            FAQ(
                question: "Is this app suitable for beginners?",
                answer: "Yes! Our app is designed for all fitness levels. We offer beginner-friendly workouts, detailed exercise instructions, form tips, and progressive programs that grow with you. The onboarding process assesses your current fitness level and creates a personalized starting point. You'll never feel overwhelmed or unsafe.",
                category: .general,
                tags: ["beginner", "suitable", "level"],
                priority: 9
            ),
            
            FAQ(
                question: "Can I use the app without equipment?",
                answer: "Absolutely! We have extensive bodyweight workout collections that require no equipment. Filter workouts by 'No Equipment' to find routines you can do anywhere. These include cardio, strength training, yoga, and flexibility exercises using just your body weight.",
                category: .general,
                tags: ["equipment", "bodyweight", "home"],
                priority: 7
            )
        ]
        
        saveFAQs()
    }
    
    private func saveFAQs() {
        if let encoded = try? JSONEncoder().encode(faqs) {
            userDefaults.set(encoded, forKey: faqDataKey)
        }
    }
    
    private func loadSavedFAQs() {
        if let data = userDefaults.data(forKey: faqDataKey),
           let decodedFAQs = try? JSONDecoder().decode([FAQ].self, from: data) {
            faqs = decodedFAQs
        }
    }
}
