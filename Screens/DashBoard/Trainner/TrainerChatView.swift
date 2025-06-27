import SwiftUI

struct TrainerChatView: View {
    let trainer: Trainer
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                chatHeader
                messagesSection
                messageInput
            }
            .background(Color.black)
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Close") { dismiss() }.foregroundColor(.yellow))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadSampleMessages()
        }
    }
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(TrainerSpecialty(rawValue: trainer.specialty)?.color ?? .gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(trainer.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(trainer.isOnline ? "Online" : "Away")
                    .font(.system(size: 12))
                    .foregroundColor(trainer.isOnline ? .green : .gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
    }
    
    private var messagesSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    ChatBubble(message: message)
                }
            }
            .padding(16)
        }
    }
    
    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
            
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.yellow)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let message = ChatMessage(
            text: messageText,
            isFromUser: true,
            timestamp: Date(),
            trainerId: trainer.id
        )
        
        messages.append(message)
        messageText = ""
        
        // Simulate trainer response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responses = [
                "Thanks for your message! I'll get back to you shortly.",
                "That sounds great! Let's work on that together.",
                "I'd be happy to help you with that goal.",
                "Let's schedule a session to discuss this further.",
                "Great question! Here's what I recommend..."
            ]
            
            let response = ChatMessage(
                text: responses.randomElement() ?? "Thanks for your message!",
                isFromUser: false,
                timestamp: Date(),
                trainerId: trainer.id
            )
            messages.append(response)
        }
    }
    
    private func loadSampleMessages() {
        messages = [
            ChatMessage(
                text: "Hi! Welcome to your training program! I'm excited to work with you.",
                isFromUser: false,
                timestamp: Date().addingTimeInterval(-3600),
                trainerId: trainer.id
            ),
            ChatMessage(
                text: "Thanks! I'm excited to get started. What should we focus on first?",
                isFromUser: true,
                timestamp: Date().addingTimeInterval(-3000),
                trainerId: trainer.id
            ),
            ChatMessage(
                text: "Let's start with understanding your current fitness level and goals. What are you hoping to achieve?",
                isFromUser: false,
                timestamp: Date().addingTimeInterval(-2400),
                trainerId: trainer.id
            )
        ]
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(message.isFromUser ? .black : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isFromUser ? Color.yellow : Color.gray.opacity(0.3))
                    )
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser { Spacer() }
        }
    }
}
