import SwiftUI

// MARK: - Onboarding Template Example
// Este archivo muestra cómo usar los componentes reutilizables para crear pantallas de onboarding

struct OnboardingTemplateExample: View {
    @ObservedObject var viewModel: ExampleViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        OnboardingLayout(
            progressViewModel: progressViewModel,
            header: PageHeader(
                icon: "star.fill",
                title: "Example Title",
                subtitle: "Optional subtitle text",
                progressViewModel: progressViewModel
            ),
            showBackButton: true,
            onBack: {
                progressViewModel.decreaseProgress()
                dismiss()
            }
        ) {
            VStack(spacing: 20) {
                SimpleSectionHeader(title: "Choose an Option")
                
                HStack(spacing: 20) {
                    IconCard(
                        icon: "heart.fill",
                        title: "Option 1",
                        isSelected: viewModel.selectedOption == .option1,
                        color: .red
                    ) {
                        viewModel.selectOption(.option1)
                    }
                    
                    IconCard(
                        icon: "star.fill",
                        title: "Option 2",
                        isSelected: viewModel.selectedOption == .option2,
                        color: .blue
                    ) {
                        viewModel.selectOption(.option2)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .overlay(
            VStack {
                Spacer()
                if viewModel.hasSelection {
                    OnboardingNavigationWithNext(
                        isEnabled: true,
                        action: { viewModel.onNextTapped(progressViewModel: progressViewModel) }
                    )
                }
            }
        )
        .navigationDestination(isPresented: $viewModel.navigateToNext) {
            Text("Next Screen")
        }
    }
}

// MARK: - Example ViewModel
class ExampleViewModel: ObservableObject {
    @Published var selectedOption: ExampleOption?
    @Published var isLoading = false
    @Published var isButtonDisabled = false
    @Published var navigateToNext = false
    
    var hasSelection: Bool {
        selectedOption != nil
    }
    
    func selectOption(_ option: ExampleOption) {
        selectedOption = option
    }
    
    func onNextTapped(progressViewModel: ProgressViewModel) {
        guard hasSelection && !isButtonDisabled else { return }
        
        isButtonDisabled = true
        isLoading = true
        progressViewModel.advanceProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigateToNext = true
            self.isButtonDisabled = false
            self.isLoading = false
        }
    }
}

enum ExampleOption: String, CaseIterable {
    case option1 = "Option 1"
    case option2 = "Option 2"
}

// MARK: - Usage Instructions
/*
 
 CÓMO USAR LOS COMPONENTES REUTILIZABLES:
 
 1. ESTRUCTURA BÁSICA:
    - Usa OnboardingLayout como contenedor principal
    - OnboardingHeader para el título y progreso
    - OnboardingNavigation para el botón Next y navegación
    - OnboardingBackButton para el botón de retroceso
 
 2. CARDS DE SELECCIÓN:
    - IconCard para opciones con iconos
    - SelectionCard para cards personalizadas
    - Ambos incluyen haptic feedback automático
 
 3. NAVEGACIÓN:
    - OnboardingNavigation maneja automáticamente el estado del botón
    - NavigationLink siempre presente para evitar problemas de binding
    - Transiciones suaves y animaciones optimizadas
 
 4. VENTAJAS:
    - Código más limpio y mantenible
    - Consistencia visual en todas las pantallas
    - Optimizado para rendimiento (sin latencia)
    - Fácil de personalizar y extender
 
 EJEMPLO DE IMPLEMENTACIÓN:
 
 struct GenderSelectionView: View {
     @ObservedObject var viewModel: GenderSelectionViewModel
     @ObservedObject var progressViewModel: ProgressViewModel
     @Environment(\.dismiss) var dismiss
     
     var body: some View {
         OnboardingLayout(
             progressViewModel: progressViewModel,
             header: OnboardingHeader(
                 icon: "person.2.fill",
                 title: "What's your gender?",
                 progressViewModel: progressViewModel
             ),
             navigation: OnboardingNavigation(
                 title: "Next",
                 isEnabled: viewModel.selectedGender != nil,
                 isLoading: $viewModel.isLoading,
                 isDisabled: $viewModel.isButtonDisabled,
                 action: { viewModel.onNextTapped(progressViewModel: progressViewModel) },
                 destination: AnyView(GoalView(viewModel: GoalViewModel(), progressViewModel: progressViewModel)),
                 isActive: $viewModel.navigateToGoal
             )
         ) {
             VStack(spacing: 20) {
                 SectionHeader(title: "Choose Your Gender")
                 
                 HStack(spacing: 20) {
                     IconCard(
                         icon: "figure.arms.open",
                         title: "Male",
                         isSelected: viewModel.selectedGender == .male,
                         color: .blue
                     ) {
                         viewModel.selectGender(.male)
                     }
                     
                     IconCard(
                         icon: "figure.stand",
                         title: "Female",
                         isSelected: viewModel.selectedGender == .female,
                         color: .pink
                     ) {
                         viewModel.selectGender(.female)
                     }
                 }
                 .padding(.horizontal, 20)
             }
         }
                 .navigationBarItems(leading: OnboardingBackButton(
            progressViewModel: progressViewModel,
            presentationMode: dismiss
        ))
     }
 }
 
 */ 