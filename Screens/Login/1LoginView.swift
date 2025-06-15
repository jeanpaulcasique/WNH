import SwiftUI
import SDWebImageSwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    @StateObject var genderSelectionViewModel = GenderSelectionViewModel()
    @StateObject var progressViewModel = ProgressViewModel()
    @EnvironmentObject var sessionManager: UserSessionManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                GeometryReader { geometry in
                    AnimatedImage(name: "loginBackground.gif")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    Spacer()
                    
                    Text("FitnessRoutine")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                    
                    // Navegación a Fase1 (Onboarding)
                    NavigationLink(destination: Fase1View(
                        genderSelectionViewModel: genderSelectionViewModel,
                        progressViewModel: progressViewModel
                    )) {
                        // Botón START (para nuevo usuario)
                        HStack {
                            Text("START")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.yellow)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                    
                    // Navegación a Dashboard
                    NavigationLink(destination: DashboardView()) {
                        // Botón LOG IN (para usuario existente)
                        HStack {
                            Text("LOG IN")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 50)
                }
                .padding(.bottom, 0)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.resetButton()
            }
        }
    }
    
    // MARK: - Debug Controls (solo para development)
    #if DEBUG
    var debugControls: some View {
        VStack {
            HStack {
                Button("Reset User") {
                    viewModel.forceOnboardingFlow(sessionManager: sessionManager)
                }
                .padding(8)
                .background(Color.red.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Complete Onboarding") {
                    viewModel.simulateExistingUser(sessionManager: sessionManager)
                }
                .padding(8)
                .background(Color.green.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom, 10)
            
            Text("Debug: \(sessionManager.shouldShowOnboarding ? "→ Onboarding" : "→ Dashboard")")
                .font(.caption)
                .foregroundColor(.yellow)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
        }
    }
    #endif

    var optionsView: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(nil) {
                        viewModel.hideLoginOptions()
                    }
                }

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(nil) {
                            viewModel.hideLoginOptions()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.title)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                }

                socialLoginButton(imageName: "applelogo", text: "Iniciar sesión con Apple", backgroundColor: .black) {
                    viewModel.signInWithApple(sessionManager: sessionManager)
                }

                socialLoginButton(imageName: "globe", text: "Google", backgroundColor: .red) {
                    viewModel.signInWithGoogle(sessionManager: sessionManager)
                }

                socialLoginButton(imageName: "facebook", text: "Facebook", backgroundColor: .blue) {
                    viewModel.signInWithFacebook(sessionManager: sessionManager)
                }
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
    }

    func socialLoginButton(imageName: String, text: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                Text(text)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSessionManager())
    }
}
