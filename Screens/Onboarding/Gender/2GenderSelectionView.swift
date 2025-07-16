import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender? = nil
    @State private var navigateToGoal = false
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var viewModel: GenderSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 1. Fondo blanco limpio
            Color.white.ignoresSafeArea()

            // 3. Contenido principal
            VStack(spacing: 0) {
                Image("samsonWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .padding(.top, 5)
                    .padding(.bottom, -70)
                    .opacity(1.0)

                // Título principal y subtítulo en una card mejorada
                VStack(spacing: 8) {
                    Text("WHAT'S YOUR GENDER?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 1)
                    Text("To give you a better experience we need to know your gender")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .cascadingAppear(index: 1)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 18)
                .background(
                    ZStack {
                        // Fondo amarillo sólido
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.primaryYellow)
                        // Borde negro grueso
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.black, lineWidth: 3)
                        // Sombra negra difusa
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.clear)
                    }
                )
                .padding(.top, 60)
                .padding(.horizontal, 24)
                
                    .padding(.bottom, 60)
                
                // Botones de género - Estilo minimalista
                VStack(spacing: 40) {
                    // Botón Male
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedGender = .male
                        }
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                // Círculo con estilo minimalista
                                Circle()
                                    .fill(selectedGender == .male ? Color.primaryYellow : Color.white.opacity(0.18))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedGender == .male ? Color.clear : Color.black.opacity(0.1), lineWidth: 2)
                                    )
                                    .shadow(
                                        color: selectedGender == .male ? Color.primaryYellow.opacity(0.3) : Color.black.opacity(0.05),
                                        radius: selectedGender == .male ? 12 : 8,
                                        x: 0,
                                        y: selectedGender == .male ? 6 : 4
                                    )
                                
                                Text("♂")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(selectedGender == .male ? .black : .black.opacity(0.7))
                            }
                            
                            Text("Male")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedGender == .male ? .black : .black.opacity(0.7))
                        }
                    }
                    .scaleEffect(selectedGender == .male ? 1.05 : 1.0)
                    .cascadingAppear(index: 2)
                    
                    // Botón Female
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedGender = .female
                        }
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(selectedGender == .female ? Color.primaryYellow : Color.white.opacity(0.18))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedGender == .female ? Color.clear : Color.black.opacity(0.1), lineWidth: 2)
                                    )
                                    .shadow(
                                        color: selectedGender == .female ? Color.primaryYellow.opacity(0.3) : Color.black.opacity(0.05),
                                        radius: selectedGender == .female ? 12 : 8,
                                        x: 0,
                                        y: selectedGender == .female ? 6 : 4
                                    )
                                
                                Text("♀")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(selectedGender == .female ? .black : .black.opacity(0.7))
                            }
                            
                            Text("Female")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedGender == .female ? .black : .black.opacity(0.7))
                        }
                    }
                    .scaleEffect(selectedGender == .female ? 1.05 : 1.0)
                    .cascadingAppear(index: 3)
                }
                
                Spacer()
                
                // Botón Next - Estilo minimalista amarillo
                if selectedGender != nil {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            if let gender = selectedGender {
                                viewModel.selectedGender = gender
                            }
                            progressViewModel.advanceProgress()
                            navigateToGoal = true
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
                                    .fill(Color.primaryYellow)
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                            )
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.1), value: selectedGender)
                        .padding(.trailing, 32)
                        .padding(.bottom, 20)
                        
                        NavigationLink(
                            destination: GoalView(viewModel: GoalViewModel(), progressViewModel: progressViewModel),
                            isActive: $navigateToGoal
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Color Extensions
extension Color {
    static let primaryYellow = Color(red: 1.0, green: 0.827, blue: 0.0)
    static let backgroundWhite = Color.white
    static let textBlack = Color.black
    static let textGray = Color.black.opacity(0.6)
}

// MARK: - Preview
struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenderSelectionView(
                progressViewModel: ProgressViewModel(),
                viewModel: GenderSelectionViewModel()
            )
        }
        .preferredColorScheme(.light)
    }
}
