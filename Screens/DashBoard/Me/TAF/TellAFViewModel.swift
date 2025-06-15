import SwiftUI
import Foundation
import Combine

// MARK: - Models
struct ReferralData: Identifiable, Codable {
    let id = UUID()
    let friendName: String
    let friendEmail: String
    let inviteDate: Date
    let status: ReferralStatus
    let subscriptionDate: Date?
    let rewardGranted: Bool
    
    enum ReferralStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case registered = "registered"
        case subscribed = "subscribed"
        case expired = "expired"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .registered: return "Signed Up"
            case .subscribed: return "Subscribed"
            case .expired: return "Expired"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .registered: return .blue
            case .subscribed: return .green
            case .expired: return .red
            }
        }
    }
}

struct ReferralReward: Identifiable, Codable {
    let id = UUID()
    let referralId: UUID
    let rewardType: RewardType
    let grantedDate: Date
    let expirationDate: Date?
    let isActive: Bool
    
    enum RewardType: String, Codable {
        case oneMonthFree = "one_month_free"
        case threeMonthsFree = "three_months_free"
        case bonus = "bonus"
        
        var displayName: String {
            switch self {
            case .oneMonthFree: return "1 Month Free"
            case .threeMonthsFree: return "3 Months Free"
            case .bonus: return "Bonus Reward"
            }
        }
        
        var months: Int {
            switch self {
            case .oneMonthFree: return 1
            case .threeMonthsFree: return 3
            case .bonus: return 0
            }
        }
    }
}

// MARK: - TellAFViewModel
final class TellAFViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var referralCode: String = ""
    @Published var referrals: [ReferralData] = []
    @Published var rewards: [ReferralReward] = []
    @Published var totalInvites: Int = 0
    @Published var successfulReferrals: Int = 0
    @Published var monthsEarned: Int = 0
    @Published var isLoading: Bool = false
    
    // Animation properties
    @Published var giftRotation: Double = 0
    @Published var giftScale: Double = 1.0
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let referralCodeKey = "user_referral_code"
    private let referralsKey = "user_referrals"
    private let rewardsKey = "user_rewards"
    private var cancellables = Set<AnyCancellable>()
    
    // User info
    private let userId = UUID().uuidString
    private let appStoreURL = "https://apps.apple.com/app/fitnessapp/id123456789"
    
    // MARK: - Computed Properties
    var shareMessage: String {
        return """
        🏋️‍♀️ Join me on FitnessApp and get fit together!
        
        Use my referral code: \(referralCode)
        
        Download the app and start your fitness journey:
        \(appStoreURL)?ref=\(referralCode)
        
        💪 Let's reach our goals together!
        """
    }
    
    var nextRewardProgress: Double {
        let currentProgress = successfulReferrals % 1
        return Double(currentProgress)
    }
    
    // MARK: - Initialization
    init() {
        loadSavedData()
        setupAnimations()
        generateInitialData()
    }
    
    // MARK: - Public Methods
    func loadReferralData() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateStatistics()
            self.isLoading = false
        }
    }
    
    func generateNewCode() {
        let newCode = generateReferralCode()
        referralCode = newCode
        saveReferralCode()
        
        // Animate gift icon
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            giftRotation += 360
            giftScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                self.giftScale = 1.0
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func shareViaSMS() {
        // Implementation for SMS sharing
        print("Opening SMS with referral message...")
        // In real app: use MessageUI framework
    }
    
    func showQRCode() {
        // Implementation for QR code display
        print("Showing QR code for referral...")
        // In real app: generate QR code with referral link
    }
    
    func showAllReferrals() {
        // Implementation to show all referrals
        print("Showing all referrals...")
    }
    
    func inviteFriend(name: String, email: String) {
        let newReferral = ReferralData(
            friendName: name,
            friendEmail: email,
            inviteDate: Date(),
            status: .pending,
            subscriptionDate: nil,
            rewardGranted: false
        )
        
        referrals.insert(newReferral, at: 0)
        totalInvites += 1
        
        saveReferrals()
        updateStatistics()
    }
    
    func processSuccessfulReferral(_ referralId: UUID) {
        guard let index = referrals.firstIndex(where: { $0.id == referralId }) else { return }
        
        // Update referral status
        let updatedReferral = ReferralData(
            friendName: referrals[index].friendName,
            friendEmail: referrals[index].friendEmail,
            inviteDate: referrals[index].inviteDate,
            status: .subscribed,
            subscriptionDate: Date(),
            rewardGranted: true
        )
        
        referrals[index] = updatedReferral
        
        // Grant reward
        grantReward(for: referralId)
        
        saveReferrals()
        updateStatistics()
    }
    
    // MARK: - Private Methods
    private func loadSavedData() {
        // Load referral code
        if let savedCode = userDefaults.string(forKey: referralCodeKey) {
            referralCode = savedCode
        } else {
            referralCode = generateReferralCode()
            saveReferralCode()
        }
        
        // Load referrals
        if let data = userDefaults.data(forKey: referralsKey),
           let savedReferrals = try? JSONDecoder().decode([ReferralData].self, from: data) {
            referrals = savedReferrals
        }
        
        // Load rewards
        if let data = userDefaults.data(forKey: rewardsKey),
           let savedRewards = try? JSONDecoder().decode([ReferralReward].self, from: data) {
            rewards = savedRewards
        }
        
        updateStatistics()
    }
    
    private func saveReferralCode() {
        userDefaults.set(referralCode, forKey: referralCodeKey)
    }
    
    private func saveReferrals() {
        if let data = try? JSONEncoder().encode(referrals) {
            userDefaults.set(data, forKey: referralsKey)
        }
    }
    
    private func saveRewards() {
        if let data = try? JSONEncoder().encode(rewards) {
            userDefaults.set(data, forKey: rewardsKey)
        }
    }
    
    private func generateReferralCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let prefix = "FIT"
        let randomSuffix = String((0..<4).map { _ in letters.randomElement()! })
        return prefix + randomSuffix
    }
    
    private func updateStatistics() {
        totalInvites = referrals.count
        successfulReferrals = referrals.filter { $0.status == .subscribed }.count
        monthsEarned = rewards.reduce(0) { $0 + $1.rewardType.months }
    }
    
    private func grantReward(for referralId: UUID) {
        let reward = ReferralReward(
            referralId: referralId,
            rewardType: .oneMonthFree,
            grantedDate: Date(),
            expirationDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            isActive: true
        )
        
        rewards.append(reward)
        saveRewards()
    }
    
    private func setupAnimations() {
        // Gentle gift rotation animation
        Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    self.giftRotation += 5
                }
            }
            .store(in: &cancellables)
        
        // Gentle scale pulse
        Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    self.giftScale = 1.05
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 1)) {
                        self.giftScale = 1.0
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func generateInitialData() {
        // Generate some mock referrals for demonstration
        if referrals.isEmpty {
            let mockReferrals = [
                ReferralData(
                    friendName: "Alex Smith",
                    friendEmail: "alex@example.com",
                    inviteDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                    status: .subscribed,
                    subscriptionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
                    rewardGranted: true
                ),
                ReferralData(
                    friendName: "Maria Garcia",
                    friendEmail: "maria@example.com",
                    inviteDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
                    status: .registered,
                    subscriptionDate: nil,
                    rewardGranted: false
                ),
                ReferralData(
                    friendName: "John Doe",
                    friendEmail: "john@example.com",
                    inviteDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
                    status: .pending,
                    subscriptionDate: nil,
                    rewardGranted: false
                )
            ]
            
            // Only add mock data if this is the first time opening the app
            if !userDefaults.bool(forKey: "mock_data_added") {
                referrals = mockReferrals
                
                // Generate corresponding rewards for subscribed referrals
                for referral in referrals where referral.status == .subscribed {
                    let reward = ReferralReward(
                        referralId: referral.id,
                        rewardType: .oneMonthFree,
                        grantedDate: referral.subscriptionDate ?? Date(),
                        expirationDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                        isActive: true
                    )
                    rewards.append(reward)
                }
                
                saveReferrals()
                saveRewards()
                userDefaults.set(true, forKey: "mock_data_added")
            }
            
            updateStatistics()
        }
    }
}

// MARK: - Extension for Analytics Integration
extension TellAFViewModel {
    
    // Track referral events for analytics
    func trackReferralEvent(_ event: ReferralEvent) {
        // Implementation for analytics tracking
        print("Tracking referral event: \(event.rawValue)")
    }
    
    enum ReferralEvent: String {
        case codeGenerated = "referral_code_generated"
        case codeCopied = "referral_code_copied"
        case linkShared = "referral_link_shared"
        case friendInvited = "friend_invited"
        case referralCompleted = "referral_completed"
        case rewardEarned = "reward_earned"
    }
}

// MARK: - Extension for Backend Integration
extension TellAFViewModel {
    
    // Methods for real backend integration
    func syncWithBackend() {
        // TODO: Sync referral data with backend
        // GET /api/referrals/user/{userId}
    }
    
    func submitReferral(email: String, completion: @escaping (Bool) -> Void) {
        // TODO: Submit referral to backend
        // POST /api/referrals
        completion(true)
    }
    
    func validateReferralCode(_ code: String, completion: @escaping (Bool) -> Void) {
        // TODO: Validate referral code with backend
        // GET /api/referrals/validate/{code}
        completion(true)
    }
    
    func claimReward(rewardId: UUID, completion: @escaping (Bool) -> Void) {
        // TODO: Claim reward through backend
        // POST /api/rewards/claim/{rewardId}
        completion(true)
    }
}
