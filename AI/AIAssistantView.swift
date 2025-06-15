import SwiftUI

class AIAssistantViewModel: ObservableObject {
    @Published var isActive = false
    @Published var currentMessage = ""
    @Published var isTyping = false
    @Published var position = CGPoint(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 200)
    @Published var isExpanded = false
    @Published var userInput = ""
    
    private let responses: [String: [String]] = [
        "saludo": [
            "¡Hola! ¿En qué puedo ayudarte hoy? 💪",
            "¡Bienvenido! ¿Listo para entrenar? 🏋️‍♂️",
            "¡Hey! ¿Qué tal tu día de entrenamiento? 🎯"
        ],
        "duda": [
            "Claro, puedo ayudarte con eso. ¿Qué necesitas saber específicamente? 🤔",
            "Excelente pregunta. Déjame explicarte... 📚",
            "Estoy aquí para ayudarte con cualquier duda que tengas 💡"
        ],
        "motivacion": [
            "¡Tú puedes! Cada repetición te acerca a tu meta 🚀",
            "Recuerda por qué empezaste. ¡Sigue adelante! 💫",
            "¡Eres más fuerte de lo que crees! 💪"
        ],
        "consejo": [
            "Te recomiendo mantener una buena postura durante el ejercicio 🧘‍♂️",
            "No olvides hidratarte durante tu entrenamiento 💧",
            "El descanso es tan importante como el ejercicio 😴"
        ]
    ]
    
    func generateResponse(for type: String) {
        isTyping = true
        currentMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let possibleResponses = self.responses[type] {
                self.currentMessage = possibleResponses.randomElement() ?? ""
            }
            self.isTyping = false
        }
    }
    
    func processUserInput() {
        guard !userInput.isEmpty else { return }
        
        isTyping = true
        currentMessage = ""
        
        let lowercasedInput = userInput.lowercased()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if lowercasedInput.contains("hola") || lowercasedInput.contains("hey") {
                self.generateResponse(for: "saludo")
            } else if lowercasedInput.contains("ayuda") || lowercasedInput.contains("duda") {
                self.generateResponse(for: "duda")
            } else if lowercasedInput.contains("motivacion") || lowercasedInput.contains("ánimo") {
                self.generateResponse(for: "motivacion")
            } else if lowercasedInput.contains("consejo") || lowercasedInput.contains("sugerencia") {
                self.generateResponse(for: "consejo")
            } else {
                self.currentMessage = "Entiendo tu pregunta. ¿Podrías ser más específico? 🤔"
            }
            
            self.userInput = ""
            self.isTyping = false
        }
    }
}

struct AIAssistantView: View {
    @EnvironmentObject var viewModel: AIAssistantViewModel
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        if viewModel.isActive {
            ZStack {
                if viewModel.isExpanded {
                    // Vista expandida
                    VStack(spacing: 16) {
                        // Cabecera del asistente
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                            
                            Text("Asistente de Entrenamiento")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.isExpanded = false
                                }
                            }) {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        
                        // Campo de entrada de texto
                        HStack {
                            TextField("Escribe tu pregunta...", text: $viewModel.userInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.black)
                            
                            Button(action: {
                                viewModel.processUserInput()
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Mensaje del asistente
                        if viewModel.isTyping {
                            TypingIndicator()
                        } else {
                            Text(viewModel.currentMessage)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(16)
                        }
                        
                        // Opciones de interacción rápida
                        HStack(spacing: 20) {
                            AssistantButton(icon: "hand.wave.fill", action: { viewModel.generateResponse(for: "saludo") })
                            AssistantButton(icon: "questionmark.circle.fill", action: { viewModel.generateResponse(for: "duda") })
                            AssistantButton(icon: "flame.fill", action: { viewModel.generateResponse(for: "motivacion") })
                            AssistantButton(icon: "lightbulb.fill", action: { viewModel.generateResponse(for: "consejo") })
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.9))
                            .shadow(color: .yellow.opacity(0.2), radius: 10)
                    )
                    .frame(width: 300)
                } else {
                    // Botón flotante
                    Button(action: {
                        withAnimation {
                            viewModel.isExpanded = true
                        }
                    }) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                            .padding(16)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.9))
                                    .shadow(color: .yellow.opacity(0.2), radius: 10)
                            )
                    }
                }
            }
            .position(x: viewModel.position.x + dragOffset.width,
                     y: viewModel.position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        viewModel.position = CGPoint(
                            x: viewModel.position.x + value.translation.width,
                            y: viewModel.position.y + value.translation.height
                        )
                    }
            )
        }
    }
}

struct AssistantButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct TypingIndicatorIA: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -5
        }
    }
}

#Preview {
    AIAssistantView()
        .preferredColorScheme(.dark)
}
