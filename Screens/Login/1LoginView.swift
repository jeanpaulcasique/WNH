import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var sessionManager: UserSessionManager

    @State private var revealPassword = false
    @State private var revealConfirmPassword = false

    init(viewModel: LoginViewModel = LoginViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                loginBackground

                GeometryReader { geometry in
                    loginLayout(in: geometry)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var loginBackground: some View {
        Color.black
            .ignoresSafeArea()
    }

    private func loginLayout(in geometry: GeometryProxy) -> some View {
        let topInset = max(geometry.safeAreaInsets.top, 18)
        let bottomInset = max(geometry.safeAreaInsets.bottom, 18)
        let availableHeight = geometry.size.height - topInset - bottomInset - 20

        return VStack {
            loginCard(height: availableHeight, topInset: topInset)
                .frame(maxHeight: availableHeight)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 12)
        .padding(.top, topInset + 10)
        .padding(.bottom, bottomInset + 10)
    }

    private func loginCard(height: CGFloat, topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            heroSection(height: heroHeight(for: height), topInset: topInset)
            formSection
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 18)
    }

    private func heroHeight(for totalHeight: CGFloat) -> CGFloat {
        min(max(totalHeight * 0.37, 250), 312)
    }

    private func heroSection(height: CGFloat, topInset: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Image(viewModel.mode == .signIn ? "human_front" : "human_back")
                .resizable()
                .scaledToFill()
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.18), Color.black.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 18) {
                modeTabs

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.mode == .signIn ? "Welcome back," : "Hello newbie,")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.96))

                    Text(viewModel.mode == .signIn ? "Julietta" : "create your account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text(viewModel.mode == .signIn ? "Sign in below or continue with another account." : "Enter your information below or sign up with another account.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, max(28, min(topInset + 14, 42)))
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .clipShape(TopCardShape())
    }

    private var modeTabs: some View {
        HStack(spacing: 34) {
            modeTab(title: "Login", mode: .signIn)
            modeTab(title: "Sign up", mode: .signUp)
        }
    }

    private func modeTab(title: String, mode: LoginViewModel.AuthMode) -> some View {
        Button {
            viewModel.switchMode(mode)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.mode == mode ? .white : .white.opacity(0.62))

                Capsule()
                    .fill(viewModel.mode == mode ? Color(red: 0.78, green: 0.34, blue: 0.98) : Color.clear)
                    .frame(width: 54, height: 4)
            }
        }
        .buttonStyle(.plain)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            statusArea

            fieldStack

            termsSlot

            actionRow
            socialRow

            biometricSlot
            rememberSlot
            complianceSlot
        }
        .padding(.horizontal, 26)
        .padding(.top, 22)
        .padding(.bottom, 22)
        .background(Color(red: 0.12, green: 0.12, blue: 0.13))
    }

    private var fieldStack: some View {
        VStack(spacing: 16) {
            UnderlineField(
                title: "Email",
                placeholder: "Enter your email",
                text: $viewModel.email,
                isSecure: false,
                revealSecureText: .constant(false)
            )

            UnderlineField(
                title: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                isSecure: true,
                revealSecureText: $revealPassword
            )

            Group {
                if viewModel.mode == .signUp {
                    UnderlineField(
                        title: "Password again",
                        placeholder: "Repeat your password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        revealSecureText: $revealConfirmPassword
                    )
                } else {
                    UnderlineFieldPlaceholder(title: "Password again")
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(alignment: .center) {
            if viewModel.mode == .signIn {
                Button("Forgot Password") {
                    viewModel.sendResetPassword()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.78, green: 0.34, blue: 0.98))
            } else {
                Color.clear.frame(width: 120, height: 20)
            }

            Spacer()

            Button {
                viewModel.submit(sessionManager: sessionManager)
            } label: {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }

                    Text(viewModel.mode == .signIn ? "Login" : "Sign up")
                        .font(.system(size: 18, weight: .bold))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(width: 172, height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.32, blue: 0.95),
                            Color(red: 0.62, green: 0.27, blue: 0.94)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
            .disabled(viewModel.isLoading || !viewModel.canSubmit)
            .opacity((viewModel.isLoading || !viewModel.canSubmit) ? 0.65 : 1)
        }
    }

    private var socialRow: some View {
        HStack(spacing: 18) {
            SignInWithAppleButton(.signIn) { request in
                viewModel.prepareAppleSignInRequest(request)
            } onCompletion: { result in
                viewModel.handleAppleSignInCompletion(result, sessionManager: sessionManager)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .disabled(viewModel.isLoading)

            Button {
                viewModel.signInWithGoogle(sessionManager: sessionManager)
            } label: {
                SocialCircleButton(symbol: "g.circle.fill", size: 60)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

            if viewModel.mode == .signIn {
                Button {
                    viewModel.signInWithFacebook(sessionManager: sessionManager)
                } label: {
                    SocialCircleButton(symbol: "f.circle.fill", size: 64)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
            } else {
                Color.clear
                    .frame(width: 64, height: 64)
            }

            Spacer()
        }
        .frame(height: 64)
        .padding(.top, 4)
    }

    private var biometricButton: some View {
        Button {
            viewModel.signInWithBiometrics(sessionManager: sessionManager)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "faceid")
                    .font(.system(size: 18, weight: .bold))
                Text("Use Face ID / Touch ID")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white.opacity(0.92))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }

    private var rememberToggle: some View {
        Toggle("Remember for Face ID / Touch ID", isOn: $viewModel.rememberForBiometrics)
            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.78, green: 0.34, blue: 0.98)))
            .foregroundColor(.white.opacity(0.82))
            .font(.system(size: 13, weight: .medium))
    }

    private var statusArea: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                statusText(errorMessage, color: Color(red: 1.0, green: 0.28, blue: 0.43))
            } else if let infoMessage = viewModel.infoMessage {
                statusText(infoMessage, color: Color(red: 0.54, green: 0.92, blue: 0.64))
            } else {
                Color.clear
            }
        }
        .frame(height: 18)
    }

    private var termsSlot: some View {
        Group {
            if viewModel.mode == .signUp {
                Toggle("I accept Terms and Privacy Policy", isOn: $viewModel.acceptTerms)
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.78, green: 0.34, blue: 0.98)))
                    .foregroundColor(.white.opacity(0.86))
                    .font(.system(size: 13, weight: .medium))
            } else {
                Color.clear.frame(height: 31)
            }
        }
    }

    private var biometricSlot: some View {
        Group {
            if viewModel.mode == .signIn && viewModel.isBiometricAvailable && viewModel.hasStoredCredentials {
                biometricButton
            } else {
                Color.clear.frame(height: 48)
            }
        }
    }

    private var rememberSlot: some View {
        Group {
            if viewModel.mode == .signIn {
                rememberToggle
            } else {
                Color.clear.frame(height: 31)
            }
        }
    }

    private var complianceSlot: some View {
        Group {
            if viewModel.mode == .signIn {
                complianceFooter
            } else {
                Color.clear.frame(height: 34)
            }
        }
    }

    private var complianceFooter: some View {
        VStack(spacing: 8) {
            Text("By continuing, you agree to our policies")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.54))

            HStack(spacing: 10) {
                Link("Terms", destination: URL(string: "https://example.com/terms")!)
                    .foregroundColor(Color(red: 0.78, green: 0.34, blue: 0.98))
                Text("•")
                    .foregroundColor(.white.opacity(0.4))
                Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
                    .foregroundColor(Color(red: 0.78, green: 0.34, blue: 0.98))
            }
            .font(.system(size: 12, weight: .bold))
        }
        .padding(.top, 2)
    }

    private func statusText(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct UnderlineField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    @Binding var revealSecureText: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.73, green: 0.37, blue: 0.95))

            HStack(spacing: 10) {
                if isSecure && !revealSecureText {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .foregroundColor(.white.opacity(0.94))
                        .font(.system(size: 18, weight: .medium))
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(title == "Email" ? .emailAddress : .default)
                        .foregroundColor(.white.opacity(0.94))
                        .font(.system(size: 18, weight: .medium))
                }

                if isSecure {
                    Button {
                        revealSecureText.toggle()
                    } label: {
                        Image(systemName: revealSecureText ? "eye" : "eye.slash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.28))
                    }
                    .buttonStyle(.plain)
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }
}

private struct UnderlineFieldPlaceholder: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.clear)

            Color.clear
                .frame(height: 24)

            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
        }
    }
}

private struct SocialCircleButton: View {
    let symbol: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: size, height: size)

            Image(systemName: symbol)
                .font(.system(size: size * 0.44, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

private struct TopCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 34
        let cutHeight: CGFloat = 58

        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: radius),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cutHeight))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        return path
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSessionManager())
            .preferredColorScheme(.dark)
    }
}
