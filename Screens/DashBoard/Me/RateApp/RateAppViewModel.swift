import SwiftUI
import StoreKit
import Foundation

// MARK: - RateAppViewModel
final class RateAppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var hasUserRated: Bool = false
    @Published var lastRatingPromptDate: Date?
    @Published var neverAskAgain: Bool = false
    @Published var ratingCount: Int = 0
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let hasRatedKey = "user_has_rated_app"
    private let lastPromptDateKey = "last_rating_prompt_date"
    private let neverAskKey = "never_ask_rating_again"
    private let ratingCountKey = "rating_prompt_count"
    
    // App Store configuration
    private let appStoreID = "123456789" // Replace with your actual App Store ID
    private let appStoreURL = "https://apps.apple.com/app/id123456789?action=write-review"
    
    // MARK: - Initialization
    init() {
        loadSavedData()
    }
    
    // MARK: - Public Methods
    func trackRateAppOpened() {
        incrementRatingCount()
        updateLastPromptDate()
        
        // Track analytics event
        trackEvent(.rateAppOpened)
    }
    
    func trackRatingGiven(_ rating: Int) {
        hasUserRated = true
        saveHasRated()
        
        // Track analytics with rating value
        trackEvent(.ratingGiven, parameters: ["rating": rating])
        
        // If high rating, mark as positive experience
        if rating >= 4 {
            trackEvent(.positiveRating)
        } else {
            trackEvent(.negativeRating)
        }
    }
    
    func openAppStoreReview() {
        // Method 1: Using SKStoreReviewController (iOS 10.3+)
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
        
        // Method 2: Fallback to direct App Store URL
        // Uncomment if you prefer direct App Store navigation
        /*
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
        */
        
        trackEvent(.appStoreOpened)
    }
    
    func showFeedbackForm() {
        // Implementation for feedback form
        // This could open a support ticket, email composer, or feedback form
        trackEvent(.feedbackFormOpened)
        
        // Example: Open email composer or support chat
        print("Opening feedback form for user concerns...")
        
        // You could integrate with your support system here
        // or navigate to WriteTSView for support chat
    }
    
    func remindLater() {
        updateLastPromptDate()
        trackEvent(.remindLater)
        
        // Set reminder for 7 days from now
        let nextPromptDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        userDefaults.set(nextPromptDate, forKey: "next_rating_prompt_date")
    }
    
    func neverAskAgainR() {
        neverAskAgain = true
        userDefaults.set(true, forKey: neverAskKey)
        trackEvent(.neverAskAgain)
    }
    
    // MARK: - Utility Methods
    func shouldShowRatingPrompt() -> Bool {
        // Don't show if user has rated or said never ask again
        if hasUserRated || neverAskAgain {
            return false
        }
        
        // Don't show too frequently (at least 7 days between prompts)
        if let lastPrompt = lastRatingPromptDate {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0
            if daysSinceLastPrompt < 7 {
                return false
            }
        }
        
        // Don't show too many times (max 3 prompts total)
        if ratingCount >= 3 {
            return false
        }
        
        return true
    }
    
    func resetRatingData() {
        // For testing purposes - reset all rating data
        hasUserRated = false
        neverAskAgain = false
        ratingCount = 0
        lastRatingPromptDate = nil
        
        userDefaults.removeObject(forKey: hasRatedKey)
        userDefaults.removeObject(forKey: neverAskKey)
        userDefaults.removeObject(forKey: ratingCountKey)
        userDefaults.removeObject(forKey: lastPromptDateKey)
    }
    
    // MARK: - Private Methods
    private func loadSavedData() {
        hasUserRated = userDefaults.bool(forKey: hasRatedKey)
        neverAskAgain = userDefaults.bool(forKey: neverAskKey)
        ratingCount = userDefaults.integer(forKey: ratingCountKey)
        
        if let savedDate = userDefaults.object(forKey: lastPromptDateKey) as? Date {
            lastRatingPromptDate = savedDate
        }
    }
    
    private func saveHasRated() {
        userDefaults.set(true, forKey: hasRatedKey)
    }
    
    private func incrementRatingCount() {
        ratingCount += 1
        userDefaults.set(ratingCount, forKey: ratingCountKey)
    }
    
    private func updateLastPromptDate() {
        lastRatingPromptDate = Date()
        userDefaults.set(Date(), forKey: lastPromptDateKey)
    }
    
    private func trackEvent(_ event: RatingEvent, parameters: [String: Any]? = nil) {
        // Implementation for analytics tracking
        print("Rating Event: \(event.rawValue)")
        if let params = parameters {
            print("Parameters: \(params)")
        }
        
        // Here you would integrate with your analytics service
        // Examples: Firebase Analytics, Mixpanel, Amplitude, etc.
    }
}

// MARK: - Analytics Events
extension RateAppViewModel {
    
    enum RatingEvent: String {
        case rateAppOpened = "rate_app_opened"
        case ratingGiven = "rating_given"
        case positiveRating = "positive_rating"
        case negativeRating = "negative_rating"
        case appStoreOpened = "app_store_opened"
        case feedbackFormOpened = "feedback_form_opened"
        case remindLater = "remind_later"
        case neverAskAgain = "never_ask_again"
    }
}

// MARK: - Helper Extensions
extension RateAppViewModel {
    
    // Check if enough app usage to show rating prompt
    func hasUsedAppEnough() -> Bool {
        // Example criteria:
        // - App launched at least 5 times
        // - Used for at least 3 days
        // - Completed at least 2 workouts
        
        let launchCount = userDefaults.integer(forKey: "app_launch_count")
        let firstLaunchDate = userDefaults.object(forKey: "first_launch_date") as? Date ?? Date()
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        
        return launchCount >= 5 && daysSinceInstall >= 3
    }
    
    // Auto-prompt logic for showing rating at appropriate times
    func checkAndShowRatingPrompt() {
        guard shouldShowRatingPrompt() && hasUsedAppEnough() else { return }
        
        // Trigger rating prompt
        // This would typically be called from your main app coordinator
        print("Conditions met for showing rating prompt")
    }
}
