import SwiftUI
import Combine

/// ViewModel especializado para manejar la lógica del header de WorkoutView
class WorkoutHeaderViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var currentTipIndex: Int = 0
    @Published var animateTip: Bool = false
    
    private var tipTimer: Timer?
    private let tips = WorkoutTip.workoutTips
    
    init() {
        loadUserName()
        startTipAnimation()
    }
    
    deinit {
        tipTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Carga el nombre del usuario desde UserDefaults
    func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    /// Inicia la animación de los tips
    func startTipAnimation() {
        animateTip = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animateTip = true
        }
        startTipTimer()
    }
    
    /// Obtiene el tip actual
    var currentTip: WorkoutTip {
        tips[currentTipIndex]
    }
    
    /// Obtiene el mensaje de saludo
    var greetingMessage: String {
        userName.isEmpty ? "Ready to train?" : "Hi, \(userName)!"
    }
    
    // MARK: - Private Methods
    
    private func startTipTimer() {
        tipTimer?.invalidate()
        tipTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            self?.cycleToNextTip()
        }
    }
    
    private func cycleToNextTip() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
            animateTip = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let isLast = self.currentTipIndex == self.tips.count - 1
            if isLast {
                self.tipTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                    self.currentTipIndex = 0
                    self.animateTip = true
                    self.startTipTimer()
                }
            } else {
                self.currentTipIndex = (self.currentTipIndex + 1)
                self.animateTip = true
                self.startTipTimer()
            }
        }
    }
} 