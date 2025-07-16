import SwiftUI
import UIKit

struct GoalView: View {
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToBodyCurrent = false
    @State private var isButtonDisabled = false
    @State private var isLoading = false
    @State private var selectedIndex: Int = 1 // Por defecto "Get fitter" (keepFit)
    @State private var scrollPickerDragOffset: CGFloat = 0
    @State private var isNavigatingToPreviousScreen = false
    
    private let goals: [Goal] = [.loseWeight, .keepFit, .buildMuscle]
    private let itemHeight: CGFloat = 60
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                Image("samsonWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .padding(.top, 5)
                    .padding(.bottom, -10)
                    .opacity(1.0)
                
                VStack(spacing: 6) {
                    Text("WHAT'S YOUR GOAL?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 1)
                    Text("This help us create your personalized plan.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .cascadingAppear(index: 1)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(Color.appYellow)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 3)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, -50)
                
                Spacer()
                
                // Nuevo Custom Picker
                ZStack {
                    // Líneas amarillas de selección
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.appYellow)
                            .frame(width: 280, height: 4)
                        Spacer().frame(height: itemHeight - 6)
                        Rectangle()
                            .fill(Color.appYellow)
                            .frame(width: 280, height: 4)
                        Spacer()
                    }
                    .frame(height: itemHeight * 3)
                    
                    // Nuevo Custom Scroll Picker
                    CustomScrollPicker(
                        items: goals,
                        selectedIndex: $selectedIndex,
                        itemHeight: itemHeight,
                        externalDragOffset: scrollPickerDragOffset
                    ) { goal, distance in
                        Text(goalText(for: goal))
                            .font(.custom("Arial", size: fontSizeForDistance(distance)))
                            .foregroundColor(colorForDistance(distance))
                            .frame(maxWidth: .infinity)
                            .frame(height: itemHeight)
                            .scaleEffect(scaleForDistance(distance))
                            .opacity(opacityForDistance(distance))
                    }
                    .frame(height: itemHeight * 3)
                }
                .onChange(of: selectedIndex) { newIndex in
                    let goal = goals[newIndex]
                    viewModel.selectGoal(goal)
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                .onAppear {
                    if let savedIndex = UserDefaults.standard.object(forKey: "selectedGoal") as? Int,
                       savedIndex >= 0 && savedIndex < goals.count {
                        selectedIndex = savedIndex
                    } else {
                        selectedIndex = 1
                        UserDefaults.standard.set(1, forKey: "selectedGoal")
                    }
                }
                
                Spacer()
                
                HStack {
                    // Botón back circular gris
                    Button(action: {
                        progressViewModel.decreaseProgress()
                        isNavigatingToPreviousScreen = true
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Botón Next igual a GenderSelectionView
                    Button(action: {
                        withAnimation {
                            progressViewModel.advanceProgress()
                        }
                        navigateToBodyCurrent = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(red: 1.0, green: 0.827, blue: 0.0))
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        )
                    }
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: selectedIndex)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    
                    NavigationLink(
                        destination: BirthYearView(viewModel: BirthYearViewModel(), progressViewModel: progressViewModel),
                        isActive: $navigateToBodyCurrent
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(
                        destination: GenderSelectionView(progressViewModel: progressViewModel, viewModel: GenderSelectionViewModel()),
                        isActive: $isNavigatingToPreviousScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Aplicar el gesto al picker
                    scrollPickerDragOffset = value.translation.height
                }
                .onEnded { value in
                    // Calcular nuevo índice basado en el gesto
                    let velocity = value.predictedEndTranslation.height - value.translation.height
                    let adjustedOffset = value.translation.height + velocity * 0.1
                    
                    let itemsToMove = -adjustedOffset / itemHeight
                    let newIndex = selectedIndex + Int(round(itemsToMove))
                    let clampedIndex = max(0, min(newIndex, goals.count - 1))
                    
                    // Animar al nuevo índice
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedIndex = clampedIndex
                        scrollPickerDragOffset = 0
                    }
                    
                    // Guardar en UserDefaults
                    UserDefaults.standard.set(clampedIndex, forKey: "selectedGoal")
                }
        )
    }
    
    private func goalText(for goal: Goal) -> String {
        switch goal {
        case .buildMuscle: return "Gain Weight"
        case .loseWeight: return "Lose weight"
        case .keepFit: return "Get fitter"
        }
    }
    
    private func fontSizeForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 40
        case 1: return 32
        default: return 26
        }
    }
    
    private func colorForDistance(_ distance: Int) -> Color {
        switch abs(distance) {
        case 0: return .black
        case 1: return Color.black.opacity(0.7)
        default: return Color.black.opacity(0.4)
        }
    }
    
    private func scaleForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.9
        default: return 0.8
        }
    }
    
    private func opacityForDistance(_ distance: Int) -> Double {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.8
        default: return 0.5
        }
    }
}

// MARK: - Custom Scroll Picker desde cero
struct CustomScrollPicker<Item: Hashable, Content: View>: View {
    let items: [Item]
    @Binding var selectedIndex: Int
    let itemHeight: CGFloat
    let externalDragOffset: CGFloat
    let content: (Item, Int) -> Content
    
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let centerY = totalHeight / 2
            let padding = centerY - itemHeight / 2
            
            VStack(spacing: 0) {
                // Top padding
                Color.clear.frame(height: padding)
                
                // Items
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let distance = index - selectedIndex
                    content(item, distance)
                        .frame(height: itemHeight)
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                }
                
                // Bottom padding
                Color.clear.frame(height: padding)
            }
            .offset(y: currentOffset + externalDragOffset)
            .onAppear {
                currentOffset = -CGFloat(selectedIndex) * itemHeight
            }
            .onChange(of: selectedIndex) { newIndex in
                // Sincronizar currentOffset cuando selectedIndex cambie externamente
                let targetOffset = -CGFloat(newIndex) * itemHeight
                let offsetDifference = abs(currentOffset - targetOffset)
                
                if offsetDifference > 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentOffset = targetOffset
                    }
                }
            }
        }
        .clipped()
    }
}

#if DEBUG
struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(
            viewModel: GoalViewModel(),
            progressViewModel: ProgressViewModel()
        )
    }
}
#endif
