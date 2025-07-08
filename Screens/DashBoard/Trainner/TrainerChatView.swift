import SwiftUI
import UIKit

class TrainerChatViewModel: ObservableObject {
    let trainer: Trainer
    @Published var messageText = ""
    @Published var messages: [ChatMessage] = []
    @Published var isTrainerTyping = false
    @Published var showImagePicker = false
    @Published var selectedImage: UIImage? = nil
    @Published var showDocumentPicker = false
    @Published var selectedDocumentURL: URL? = nil
    @Published var readMessageIDs: Set<UUID> = []
    
    init(trainer: Trainer) {
        self.trainer = trainer
        loadSampleMessages()
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let message = ChatMessage(
            text: messageText,
            isFromUser: true,
            timestamp: Date(),
            trainerId: trainer.id
        )
        messages.append(message)
        messageText = ""
        simulateTrainerResponse(lastUserMessageID: message.id)
    }
    
    func sendImage(_ image: UIImage) {
        let message = ChatMessage(
            text: "[Imagen]",
            isFromUser: true,
            timestamp: Date(),
            trainerId: trainer.id,
            image: image
        )
        messages.append(message)
        simulateTrainerResponse(image: image, lastUserMessageID: message.id)
    }
    
    func sendPDF(_ url: URL) {
        let message = ChatMessage(
            text: url.lastPathComponent,
            isFromUser: true,
            timestamp: Date(),
            trainerId: trainer.id,
            pdfURL: url
        )
        messages.append(message)
        simulateTrainerResponse(pdfURL: url, lastUserMessageID: message.id)
    }
    
    private func simulateTrainerResponse(image: UIImage? = nil, pdfURL: URL? = nil, lastUserMessageID: UUID? = nil) {
        isTrainerTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response: ChatMessage
            if let image = image {
                response = ChatMessage(
                    text: "¡Gracias por la imagen!",
                    isFromUser: false,
                    timestamp: Date(),
                    trainerId: self.trainer.id,
                    image: image
                )
            } else if let pdfURL = pdfURL {
                response = ChatMessage(
                    text: pdfURL.lastPathComponent,
                    isFromUser: false,
                    timestamp: Date(),
                    trainerId: self.trainer.id,
                    pdfURL: pdfURL
                )
            } else {
                let responses = [
                    "Thanks for your message! I'll get back to you shortly.",
                    "That sounds great! Let's work on that together.",
                    "I'd be happy to help you with that goal.",
                    "Let's schedule a session to discuss this further.",
                    "Great question! Here's what I recommend..."
                ]
                response = ChatMessage(
                    text: responses.randomElement() ?? "Thanks for your message!",
                    isFromUser: false,
                    timestamp: Date(),
                    trainerId: self.trainer.id
                )
            }
            self.messages.append(response)
            self.isTrainerTyping = false
            if let id = lastUserMessageID {
                self.readMessageIDs.insert(id)
            }
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

struct TrainerChatView: View {
    let trainer: Trainer
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TrainerChatViewModel
    @State private var showProfile = false
    
    init(trainer: Trainer) {
        self.trainer = trainer
        _viewModel = StateObject(wrappedValue: TrainerChatViewModel(trainer: trainer))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                chatHeader
                messagesSection
                if viewModel.isTrainerTyping {
                    HStack {
                        Spacer()
                        Text("El entrenador está escribiendo...")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .italic()
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .transition(.opacity)
                }
                messageInput
            }
            .background(Color.black)
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Close") { dismiss() }.foregroundColor(.yellow))
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            DocumentPicker(selectedURL: $viewModel.selectedDocumentURL)
        }
        .sheet(isPresented: $showProfile) {
            TrainerDetailView(trainer: trainer, onHire: { _ in })
        }
        .onChange(of: viewModel.selectedImage) { newImage in
            if let image = newImage {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.sendImage(image)
                }
                viewModel.selectedImage = nil
            }
        }
        .onChange(of: viewModel.selectedDocumentURL) { newURL in
            if let url = newURL {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.sendPDF(url)
                }
                viewModel.selectedDocumentURL = nil
            }
        }
    }
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button(action: { showProfile = true }) {
                Circle()
                    .fill(TrainerSpecialty(rawValue: trainer.specialty)?.color ?? .gray)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
            }
            VStack(alignment: .leading, spacing: 2) {
                Button(action: { showProfile = true }) {
                    Text(trainer.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
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
                ForEach(groupedMessages.keys.sorted(by: >), id: \.self) { date in
                    HStack {
                        Spacer()
                        Text(dateLabel(for: date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.vertical, 4)
                        Spacer()
                    }
                    ForEach(groupedMessages[date] ?? []) { message in
                        ChatBubble(message: message)
                            .environmentObject(viewModel)
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var groupedMessages: [Date: [ChatMessage]] {
        Dictionary(grouping: viewModel.messages) { message in
            Calendar.current.startOfDay(for: message.timestamp)
        }
    }
    
    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Hoy"
        } else if calendar.isDateInYesterday(date) {
            return "Ayer"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private var messageInput: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.showImagePicker = true }) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            }
            Button(action: { viewModel.showDocumentPicker = true }) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            }
            TextField("Type a message...", text: $viewModel.messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
            Button(action: viewModel.sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.yellow)
                    .clipShape(Circle())
            }
            .disabled(viewModel.messageText.isEmpty)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    @EnvironmentObject var viewModel: TrainerChatViewModel
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                if let image = message.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 180, maxHeight: 180)
                        .cornerRadius(12)
                } else if let pdfURL = message.pdfURL {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        Text(pdfURL.lastPathComponent)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                } else {
                    Text(message.text)
                        .font(.system(size: 14))
                        .foregroundColor(message.isFromUser ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(message.isFromUser ? Color.yellow : Color.gray.opacity(0.3))
                        )
                }
                HStack(spacing: 4) {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    if message.isFromUser, viewModel.readMessageIDs.contains(message.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            if !message.isFromUser { Spacer() }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedURL = urls.first
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

