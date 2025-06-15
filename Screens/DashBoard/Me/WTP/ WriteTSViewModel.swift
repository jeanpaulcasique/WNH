import SwiftUI
import Foundation
import Combine
import UIKit

// MARK: - Models
struct SupportMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let attachments: [MessageAttachment]
    let status: MessageStatus
    
    enum MessageStatus: String, Codable {
        case sending, sent, delivered, failed
    }
}

struct MessageAttachment: Identifiable, Codable {
    let id = UUID()
    let filename: String
    let type: AttachmentType
    let data: Data?
    
    enum AttachmentType: String, Codable {
        case image, document, video
        
        var icon: String {
            switch self {
            case .image: return "photo"
            case .document: return "doc"
            case .video: return "video"
            }
        }
    }
}

struct ConversationHistory: Identifiable, Codable {
    var id = UUID()
    let conversationNumber: Int
    let startDate: Date
    let endDate: Date
    let messages: [SupportMessage]
    let title: String
    
    init(conversationNumber: Int, messages: [SupportMessage]) {
        self.id = UUID()
        self.conversationNumber = conversationNumber
        self.messages = messages
        self.startDate = messages.first?.timestamp ?? Date()
        self.endDate = messages.last?.timestamp ?? Date()
        
        // Generate title based on first user message or default
        if let firstUserMessage = messages.first(where: { $0.isFromUser }) {
            let truncatedText = String(firstUserMessage.text.prefix(30))
            self.title = truncatedText.count < firstUserMessage.text.count ? truncatedText + "..." : truncatedText
        } else {
            self.title = "Support Conversation"
        }
    }
}

enum ContactMethod: String, CaseIterable {
    case chat = "chat"
    case email = "email"
    
    var title: String {
        switch self {
        case .chat: return "Live Chat"
        case .email: return "Email"
        }
    }
    
    var icon: String {
        switch self {
        case .chat: return "message"
        case .email: return "envelope"
        }
    }
}

struct UserInfo {
    let userId: String
    let email: String
    let appVersion: String
    let deviceModel: String
    let osVersion: String
    let subscriptionStatus: String
}

// MARK: - WriteTSViewModel
final class WriteTSViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var messages: [SupportMessage] = []
    @Published var conversationHistory: [ConversationHistory] = []
    @Published var currentConversationNumber: Int = 1
    @Published var selectedContactMethod: ContactMethod = .chat
    @Published var isTyping: Bool = false
    @Published var isOnline: Bool = true
    @Published var responseTime: String = "2-5 minutes"
    @Published var attachments: [MessageAttachment] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let conversationKey = "support_conversation"
    private let historyKey = "conversation_history"
    private let conversationNumberKey = "conversation_number"
    private var emailMessage: String = ""
    
    // User info for context
    private let userInfo = UserInfo(
        userId: UUID().uuidString,
        email: "user@example.com",
        appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        deviceModel: UIDevice.current.model,
        osVersion: UIDevice.current.systemVersion,
        subscriptionStatus: "Free" // This should come from your subscription manager
    )
    
    // MARK: - Initialization
    init() {
        loadCurrentConversationNumber()
        loadConversationHistory()
        setupMockData()
        startTypingSimulation()
    }
    
    // MARK: - Public Methods
    func loadPreviousConversations() {
        if let data = userDefaults.data(forKey: conversationKey),
           let savedMessages = try? JSONDecoder().decode([SupportMessage].self, from: data) {
            messages = savedMessages
        }
    }
    
    func sendMessage(text: String) {
        let newMessage = SupportMessage(
            text: text,
            isFromUser: true,
            timestamp: Date(),
            attachments: attachments,
            status: .sending
        )
        
        messages.append(newMessage)
        attachments.removeAll()
        
        // Update message status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                self.messages[index] = SupportMessage(
                    text: newMessage.text,
                    isFromUser: true,
                    timestamp: newMessage.timestamp,
                    attachments: newMessage.attachments,
                    status: .sent
                )
            }
        }
        
        // Simulate response
        simulateResponse(to: text)
        saveConversation()
    }
    
    func addAttachment(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        let attachment = MessageAttachment(
            filename: "image_\(Date().timeIntervalSince1970).jpg",
            type: .image,
            data: imageData
        )
        
        attachments.append(attachment)
    }
    
    func removeAttachment(_ attachment: MessageAttachment) {
        attachments.removeAll { $0.id == attachment.id }
    }
    
    func setEmailMessage(_ message: String) {
        emailMessage = message
    }
    
    func generateEmailBody() -> String {
        var body = ""
        
        if !emailMessage.isEmpty {
            body += "Message:\n\(emailMessage)\n\n"
        }
        
        body += "System Information:\n"
        body += "App Version: \(userInfo.appVersion)\n"
        body += "Device: \(userInfo.deviceModel)\n"
        body += "iOS Version: \(userInfo.osVersion)\n"
        body += "Subscription: \(userInfo.subscriptionStatus)\n"
        body += "User ID: \(userInfo.userId)\n\n"
        
        body += "Please describe your issue in detail above this line.\n"
        body += "Our support team will respond within 24 hours."
        
        return body
    }
    
    func showQuickHelp() {
        let helpMessage = """
        Quick Help:
        
        • For urgent issues, use Live Chat
        • For detailed reports, use Email
        • Attach screenshots to help us understand
        • Include steps to reproduce the problem
        
        Common solutions:
        • Restart the app
        • Check your internet connection
        • Update to the latest version
        """
        
        let supportMessage = SupportMessage(
            text: helpMessage,
            isFromUser: false,
            timestamp: Date(),
            attachments: [],
            status: .delivered
        )
        
        messages.append(supportMessage)
        saveConversation()
    }
    
    func clearConversation() {
        messages.removeAll()
        userDefaults.removeObject(forKey: conversationKey)
    }
    
    // MARK: - Conversation Management
    func startNewConversation() {
        // Save current conversation to history if it has messages
        if !messages.isEmpty {
            saveCurrentConversationToHistory()
        }
        
        // Clear current conversation
        messages.removeAll()
        attachments.removeAll()
        
        // Increment conversation number
        currentConversationNumber += 1
        saveCurrentConversationNumber()
        
        // Clear current conversation from UserDefaults
        userDefaults.removeObject(forKey: conversationKey)
        
        // Add welcome message for new conversation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let welcomeMessage = SupportMessage(
                text: "Hello! This is a new conversation. How can I help you today?",
                isFromUser: false,
                timestamp: Date(),
                attachments: [],
                status: .delivered
            )
            self.messages.append(welcomeMessage)
            self.saveConversation()
        }
    }
    
    func loadConversation(_ conversation: ConversationHistory) {
        // Save current conversation if it has messages
        if !messages.isEmpty {
            saveCurrentConversationToHistory()
        }
        
        // Load selected conversation
        messages = conversation.messages
        currentConversationNumber = conversation.conversationNumber
        saveConversation()
    }
    
    func deleteConversations(at indexSet: IndexSet) {
        conversationHistory.remove(atOffsets: indexSet)
        saveConversationHistory()
    }
    
    private func saveCurrentConversationToHistory() {
        let conversation = ConversationHistory(
            conversationNumber: currentConversationNumber,
            messages: messages
        )
        
        // Remove existing conversation with same number if exists
        conversationHistory.removeAll { $0.conversationNumber == currentConversationNumber }
        
        // Add to beginning of history (most recent first)
        conversationHistory.insert(conversation, at: 0)
        
        // Keep only last 50 conversations
        if conversationHistory.count > 50 {
            conversationHistory = Array(conversationHistory.prefix(50))
        }
        
        saveConversationHistory()
    }
    
    private func loadConversationHistory() {
        if let data = userDefaults.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([ConversationHistory].self, from: data) {
            conversationHistory = history
        }
    }
    
    private func saveConversationHistory() {
        if let data = try? JSONEncoder().encode(conversationHistory) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
    
    private func loadCurrentConversationNumber() {
        currentConversationNumber = userDefaults.integer(forKey: conversationNumberKey)
        if currentConversationNumber == 0 {
            currentConversationNumber = 1
        }
    }
    
    private func saveCurrentConversationNumber() {
        userDefaults.set(currentConversationNumber, forKey: conversationNumberKey)
    }
    
    // MARK: - Private Methods
    private func setupMockData() {
        // Simulate online status changes
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateOnlineStatus()
            }
            .store(in: &cancellables)
    }
    
    private func updateOnlineStatus() {
        let randomValue = Int.random(in: 1...10)
        isOnline = randomValue > 2 // 80% chance of being online
        responseTime = isOnline ? "2-5 minutes" : "15-30 minutes"
    }
    
    private func startTypingSimulation() {
        // Simulate typing indicator for responses
        $messages
            .dropFirst()
            .sink { messages in
                if let lastMessage = messages.last, lastMessage.isFromUser {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.isTyping = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func simulateResponse(to userMessage: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2.0...5.0)) {
            self.isTyping = false
            
            let response = self.generateAutomaticResponse(for: userMessage)
            let supportMessage = SupportMessage(
                text: response,
                isFromUser: false,
                timestamp: Date(),
                attachments: [],
                status: .delivered
            )
            
            self.messages.append(supportMessage)
            self.saveConversation()
        }
    }
    
    private func generateAutomaticResponse(for message: String) -> String {
        let lowercaseMessage = message.lowercased()
        
        if lowercaseMessage.contains("password") || lowercaseMessage.contains("login") {
            return "I understand you're having trouble with your account access. Let me help you with that! Have you tried using the 'Forgot Password' option on the login screen?"
        }
        
        if lowercaseMessage.contains("subscription") || lowercaseMessage.contains("billing") {
            return "I'd be happy to help with your subscription! Can you tell me more about the specific issue you're experiencing? Is it related to payment, features, or cancellation?"
        }
        
        if lowercaseMessage.contains("bug") || lowercaseMessage.contains("crash") || lowercaseMessage.contains("error") {
            return "Thanks for reporting this issue! To help me investigate, could you please tell me:\n\n1. What were you doing when this happened?\n2. Does it happen every time?\n3. Have you tried restarting the app?\n\nA screenshot would also be very helpful!"
        }
        
        if lowercaseMessage.contains("sync") || lowercaseMessage.contains("data") {
            return "Data sync issues can be frustrating! Let's troubleshoot this:\n\n1. Check your internet connection\n2. Make sure you're logged into the same account\n3. Try pulling down to refresh the data\n\nIf the issue persists, I can escalate this to our technical team."
        }
        
        if lowercaseMessage.contains("feature") || lowercaseMessage.contains("suggestion") {
            return "We love hearing feature suggestions from our users! 🎉 I'll make sure to pass this along to our product team. Is there a specific use case or problem this feature would solve for you?"
        }
        
        // Default responses
        let defaultResponses = [
            "Thanks for reaching out! I'm here to help. Can you provide a bit more detail about what you're experiencing?",
            "I understand your concern. Let me help you resolve this issue. Could you walk me through what happened step by step?",
            "Thanks for contacting support! I'm looking into this for you. In the meantime, have you tried restarting the app?",
            "I appreciate you taking the time to contact us. To better assist you, could you tell me more about when this issue started?"
        ]
        
        return defaultResponses.randomElement() ?? defaultResponses[0]
    }
    
    private func saveConversation() {
        if let data = try? JSONEncoder().encode(messages) {
            userDefaults.set(data, forKey: conversationKey)
        }
    }
}

// MARK: - Supporting Views and Extensions
struct EmailFieldView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AttachmentsView: View {
    let attachments: [MessageAttachment]
    let onRemove: (MessageAttachment) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(attachments) { attachment in
                    AttachmentItem(attachment: attachment) {
                        onRemove(attachment)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct AttachmentItem: View {
    let attachment: MessageAttachment
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                if attachment.type == .image, let data = attachment.data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    Image(systemName: attachment.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.appYellow)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Text(attachment.filename)
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
                    .frame(width: 60)
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .background(Color.appBlack)
                    .clipShape(Circle())
            }
            .offset(x: 8, y: -8)
        }
    }
}

struct AttachmentPreviewView: View {
    let attachments: [MessageAttachment]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(attachments) { attachment in
                    if attachment.type == .image, let data = attachment.data, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        VStack {
                            Image(systemName: attachment.type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.appYellow)
                            
                            Text(attachment.filename)
                                .font(.system(size: 10))
                                .foregroundColor(.appWhite.opacity(0.7))
                                .lineLimit(1)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}
