import SwiftUI
import SDWebImageSwiftUI

struct Fase1View: View {
    @State private var navigateToNext = false
    @State private var gifFinished = false
    let genderSelectionViewModel: GenderSelectionViewModel
    let progressViewModel: ProgressViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            AnimatedImage(name: "fase1.gif", isAnimating: .constant(true))
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityIdentifier("fase1Gif")

          
            // NavigationLink usando la nueva sintaxis
            NavigationLink(
                destination: GenderSelectionView(
                    viewModel: genderSelectionViewModel,
                    progressViewModel: progressViewModel
                ),
                isActive: $navigateToNext
            ) {
                EmptyView()
            }
        }
        .onAppear {
            print("🎬 Fase1View apareció - iniciando timer de 4.4 segundos")
            
            // Ajusta el tiempo al que dura exactamente tu gif
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.4) {
                print("🎬 Timer completado - activando navegación")
                gifFinished = true
                navigateToNext = true
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationView {
        Fase1View(
            genderSelectionViewModel: GenderSelectionViewModel(),
            progressViewModel: ProgressViewModel()
        )
    }
}
