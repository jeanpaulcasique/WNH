import Screens.DashBoard.Diet.AllergySelectionView

@State private var showAllergyScreen = false

Button(action: {
    showAllergyScreen = true
}) {
    // ... código existente ...
}

.navigationDestination(isPresented: $showAllergyScreen) {
    AllergySelectionView(onFinish: { selectedAllergens in
        UserDefaults.standard.set(selectedAllergens, forKey: "userAllergens")
        // Aquí podrías navegar al siguiente paso del onboarding
    })
} 