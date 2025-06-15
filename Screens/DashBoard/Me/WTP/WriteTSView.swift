import SwiftUI
import MessageUI

// MARK: - Email Composer
struct EmailComposerView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    let recipients: [String]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        composer.setToRecipients(recipients)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposerView
        
        init(_ parent: EmailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EmailUnavailableView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.appYellow)
                
                Text("Email Not Available")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text("Please set up the Mail app on your device to send emails, or use our live chat feature instead.")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button("Use Live Chat Instead") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.appYellow)
                .cornerRadius(25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBlack)
            .navigationTitle("Email Support")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct WriteTSView: View {
    @StateObject private var viewModel = WriteTSViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText = ""
    @State private var showEmailComposer = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showConversationHistory = false
    @State private var showNewConversationAlert = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con opciones
                headerSection
                
                // Área de chat
                if viewModel.selectedContactMethod == .chat {
                    chatArea
                } else {
                    emailPreviewArea
                }
                
                // Input area
                inputArea
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: backButton,
            trailing: HStack {
                conversationHistoryButton
                newConversationButton
            }
        )
        .onAppear {
            viewModel.loadPreviousConversations()
        }
        .sheet(isPresented: $showEmailComposer) {
            if MFMailComposeViewController.canSendMail() {
                EmailComposerView(
                    subject: "Support Request - FitnessApp",
                    body: viewModel.generateEmailBody(),
                    recipients: ["support@fitnessapp.com"]
                )
            } else {
                EmailUnavailableView()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                viewModel.addAttachment(image: image)
                selectedImage = nil // Reset para permitir seleccionar la misma imagen de nuevo
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showConversationHistory) {
            ConversationHistoryView(viewModel: viewModel)
        }
        .alert("New Conversation", isPresented: $showNewConversationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start New") {
                viewModel.startNewConversation()
            }
        } message: {
            Text("Are you sure you want to start a new conversation? Your current conversation will be saved to history.")
        }
        .alert("Support", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - Subviews
private extension WriteTSView {
    
    var headerSection: some View {
        VStack(spacing: 16) {
            // Contact method selector
            HStack(spacing: 0) {
                ForEach(ContactMethod.allCases, id: \.self) { method in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedContactMethod = method
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: method.icon)
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.selectedContactMethod == method ? .black : .appWhite)
                            
                            Text(method.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(viewModel.selectedContactMethod == method ? .black : .appWhite)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.selectedContactMethod == method ?
                            Color.appYellow : Color.clear
                        )
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            
            // Status indicator
            if viewModel.selectedContactMethod == .chat {
                HStack {
                    Circle()
                        .fill(viewModel.isOnline ? .green : .orange)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.isOnline ? "Support team is online" : "We'll respond as soon as possible")
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Usually responds in \(viewModel.responseTime)")
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appBlack)
    }
    
    var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Welcome message
                    if viewModel.messages.isEmpty {
                        WelcomeMessageView()
                            .padding(.top, 20)
                    }
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if viewModel.isTyping {
                        TypingIndicator()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    var emailPreviewArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Email Preview")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appYellow)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                EmailFieldView(label: "To:", value: "support@fitnessapp.com")
                EmailFieldView(label: "Subject:", value: "Support Request - FitnessApp")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.8))
                    
                    ScrollView {
                        Text(viewModel.generateEmailBody())
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding(.horizontal, 20)
            
            // Attachments
            if !viewModel.attachments.isEmpty {
                AttachmentsView(attachments: viewModel.attachments) { attachment in
                    viewModel.removeAttachment(attachment)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    var inputArea: some View {
        VStack(spacing: 12) {
            if viewModel.selectedContactMethod == .chat && !viewModel.attachments.isEmpty {
                AttachmentsView(attachments: viewModel.attachments) { attachment in
                    viewModel.removeAttachment(attachment)
                }
                .padding(.horizontal, 16)
            }
            
            HStack(spacing: 12) {
                // Attachment button
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.appYellow)
                }
                
                // Text input
                HStack {
                    TextField(
                        viewModel.selectedContactMethod == .chat ? "Type your message..." : "Describe your issue...",
                        text: $messageText,
                        axis: .vertical
                    )
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite)
                    .lineLimit(1...4)
                    
                    if !messageText.isEmpty {
                        Button(action: {
                            messageText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                
                // Send/Email button
                Button(action: {
                    if viewModel.selectedContactMethod == .chat {
                        sendMessage()
                    } else {
                        sendEmail()
                    }
                }) {
                    Image(systemName: viewModel.selectedContactMethod == .chat ? "arrow.up.circle.fill" : "envelope.fill")
                        .font(.system(size: 24))
                        .foregroundColor(messageText.isEmpty ? .gray : .appYellow)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.appBlack)
        }
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var conversationHistoryButton: some View {
        Button(action: {
            showConversationHistory = true
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.appYellow)
                .font(.system(size: 20))
        }
    }
    
    var newConversationButton: some View {
        Button(action: {
            if !viewModel.messages.isEmpty {
                showNewConversationAlert = true
            } else {
                viewModel.startNewConversation()
            }
        }) {
            Image(systemName: "plus.message")
                .foregroundColor(.appYellow)
                .font(.system(size: 20))
        }
    }
    
    var helpButton: some View {
        Button(action: {
            viewModel.showQuickHelp()
        }) {
            Image(systemName: "questionmark.circle")
                .foregroundColor(.appYellow)
                .font(.system(size: 20))
        }
    }
    
    // MARK: - Actions
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.sendMessage(text: messageText)
        messageText = ""
        
        // Generate haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func sendEmail() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.setEmailMessage(messageText)
        
        if MFMailComposeViewController.canSendMail() {
            showEmailComposer = true
        } else {
            alertMessage = "Email is not configured on this device. Please set up Mail app first."
            showingAlert = true
        }
    }
    
    // MARK: - Keyboard Helper
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views
struct WelcomeMessageView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "headphones")
                .font(.system(size: 48))
                .foregroundColor(.appYellow)
            
            Text("Hi there! 👋")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text("How can we help you today? Our support team is here to assist you with any questions or issues.")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Quick actions
            VStack(spacing: 8) {
                QuickActionButton(title: "Account Issues", icon: "person.circle") {
                    // Handle quick action
                }
                QuickActionButton(title: "App Problems", icon: "app.badge") {
                    // Handle quick action
                }
                QuickActionButton(title: "Subscription Help", icon: "creditcard") {
                    // Handle quick action
                }
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "headphones")
                .font(.system(size: 48))
                .foregroundColor(.appYellow)
            
            Text("Hi there! 👋")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text("How can we help you today? Our support team is here to assist you with any questions or issues.")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Quick actions
            VStack(spacing: 8) {
                QuickActionButton(title: "Account Issues", icon: "person.circle") {
                    // Handle quick action
                }
                QuickActionButton(title: "App Problems", icon: "app.badge") {
                    // Handle quick action
                }
                QuickActionButton(title: "Subscription Help", icon: "creditcard") {
                    // Handle quick action
                }
            }
            .padding(.top, 16)
        }
        .padding(20)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }


struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appYellow)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.appWhite)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.appWhite.opacity(0.5))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct MessageBubble: View {
    let message: SupportMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                if !message.isFromUser {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.appYellow)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("S")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                            )
                        
                        Text("Support Team")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appYellow)
                        
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.text)
                        .font(.system(size: 16))
                        .foregroundColor(message.isFromUser ? .black : .appWhite)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            message.isFromUser ?
                            Color.appYellow :
                            Color.gray.opacity(0.2)
                        )
                        .cornerRadius(18)
                    
                    if !message.attachments.isEmpty {
                        AttachmentPreviewView(attachments: message.attachments)
                    }
                }
                
                HStack {
                    if message.isFromUser {
                        Spacer()
                    }
                    
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundColor(.appWhite.opacity(0.5))
                    
                    if message.isFromUser {
                        Image(systemName: message.status == .sent ? "checkmark" :
                              message.status == .delivered ? "checkmark.circle" : "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.appWhite.opacity(0.5))
                    }
                    
                    if !message.isFromUser {
                        Spacer()
                    }
                }
            }
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 4)
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.appYellow)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("S")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    )
                
                Text("Support is typing")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                animationOffset = 10
            }
        }
    }
}

// MARK: - Conversation History View
struct ConversationHistoryView: View {
    @ObservedObject var viewModel: WriteTSViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                
                if viewModel.conversationHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 64))
                            .foregroundColor(.appYellow.opacity(0.5))
                        
                        Text("No Previous Conversations")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                        
                        Text("Your conversation history will appear here once you start chatting with support.")
                            .font(.system(size: 16))
                            .foregroundColor(.appWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(viewModel.conversationHistory) { conversation in
                            ConversationHistoryRow(conversation: conversation) {
                                viewModel.loadConversation(conversation)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteConversations(at: indexSet)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.appBlack)
                }
            }
            .navigationTitle("Conversation History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.appYellow),
                trailing: EditButton().foregroundColor(.appYellow)
            )
        }
        .preferredColorScheme(.dark)
    }
}

struct ConversationHistoryRow: View {
    let conversation: ConversationHistory
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Conversation #\(conversation.conversationNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appWhite)
                    
                    Spacer()
                    
                    Text(conversation.startDate, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
                
                if let lastMessage = conversation.messages.last {
                    Text(lastMessage.text)
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "message")
                        .foregroundColor(.appYellow)
                        .font(.system(size: 12))
                    
                    Text("\(conversation.messages.count) messages")
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                    
                    Spacer()
                    
                    Text(conversation.endDate, style: .time)
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(Color.gray.opacity(0.1))
    }
}

// MARK: - Preview
struct WriteTSView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WriteTSView()
        }
        .preferredColorScheme(.dark)
    }
}
