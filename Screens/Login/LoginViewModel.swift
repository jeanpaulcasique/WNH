import Foundation
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import LocalAuthentication
import Security
import CryptoKit

final class LoginViewModel: ObservableObject {
    enum AuthMode: String, CaseIterable {
        case signIn = "Sign In"
        case signUp = "Create Account"
    }

    @Published var mode: AuthMode = .signIn
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published var isLoading = false
    @Published var rememberForBiometrics = true
    @Published var acceptTerms = false
    @Published var hasStoredCredentials = false
    @Published var isBiometricAvailable = false

    private let authService = FirebaseAuthService.shared
    private let profileService = FirestoreUserProfileService.shared
    private let keychainService = AuthKeychainService()
    private let biometricService = BiometricAuthService()

    private var currentAppleNonce: String?

    private let demoEmail = "prueba@hotmail.com"
    private let demoPassword = "123456"

    init() {
        refreshSecurityState()
    }

    var canSubmit: Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            return false
        }

        if mode == .signUp {
            return !confirmPassword.isEmpty && cleanPassword == confirmPassword && acceptTerms
        }

        return true
    }

    func submit(sessionManager: UserSessionManager) {
        clearMessages()

        if !authService.isConfigured {
            handleOfflineDemoLogin(sessionManager: sessionManager)
            return
        }

        guard validateFields() else { return }

        isLoading = true
        Task { @MainActor in
            do {
                switch mode {
                case .signIn:
                    _ = try await authService.signIn(email: email, password: password)
                    try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: false)
                case .signUp:
                    _ = try await authService.register(email: email, password: password)
                    try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: true)
                }
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    func sendResetPassword() {
        clearMessages()

        if !authService.isConfigured {
            infoMessage = "Firebase is not configured yet. Use the demo account for now."
            return
        }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidEmail(cleanEmail) else {
            errorMessage = "Enter a valid email to reset your password."
            return
        }

        isLoading = true
        Task { @MainActor in
            do {
                try await authService.sendPasswordReset(email: cleanEmail)
                infoMessage = "Password reset email sent."
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    func switchMode(_ newMode: AuthMode) {
        guard mode != newMode else { return }
        mode = newMode
        clearMessages()
        password = ""
        confirmPassword = ""
        if newMode == .signIn {
            acceptTerms = false
        }
    }

    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentAppleNonce = nonce

        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleSignInCompletion(
        _ result: Result<ASAuthorization, Error>,
        sessionManager: UserSessionManager
    ) {
        clearMessages()

        guard authService.isConfigured else {
            errorMessage = "Apple Sign In requires Firebase configuration."
            return
        }

        guard case .success(let authorization) = result else {
            if case .failure(let error) = result {
                errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            }
            return
        }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid Apple credential."
            return
        }

        guard let nonce = currentAppleNonce else {
            errorMessage = "Unable to validate Apple request."
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Unable to read Apple token."
            return
        }

        isLoading = true
        Task { @MainActor in
            do {
                _ = try await authService.signInWithApple(idToken: idTokenString, nonce: nonce)
                try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: false)
                infoMessage = "Signed in with Apple."
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    func signInWithBiometrics(sessionManager: UserSessionManager) {
        clearMessages()

        guard isBiometricAvailable else {
            errorMessage = "Face ID / Touch ID is not available on this device."
            return
        }

        guard let creds = keychainService.loadCredentials() else {
            errorMessage = "No saved credentials found for biometric login."
            return
        }

        isLoading = true
        Task { @MainActor in
            do {
                try await biometricService.authenticate(reason: "Secure sign in")

                if !authService.isConfigured {
                    guard creds.email.lowercased() == demoEmail, creds.password == demoPassword else {
                        handleAuthFailure("Saved credentials are not valid for demo mode.")
                        isLoading = false
                        return
                    }

                    sessionManager.handleSuccessfulAuthentication(isNewUser: false)
                    sessionManager.completeOnboarding()
                    infoMessage = "Signed in with biometrics (demo mode)."
                    isLoading = false
                    return
                }

                _ = try await authService.signIn(email: creds.email, password: creds.password)
                email = creds.email
                try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: false)
                infoMessage = "Signed in with biometrics."
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    func signInWithGoogle(sessionManager: UserSessionManager) {
        clearMessages()

        isLoading = true
        Task { @MainActor in
            do {
                _ = try await authService.signInWithGoogle()
                try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: false)
                infoMessage = "Signed in with Google."
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    func signInWithFacebook(sessionManager: UserSessionManager) {
        clearMessages()

        isLoading = true
        Task { @MainActor in
            do {
                _ = try await authService.signInWithFacebook()
                try await completeAuthSuccess(sessionManager: sessionManager, isNewUser: false)
                infoMessage = "Signed in with Facebook."
            } catch {
                handleAuthFailure(mapAuthError(error))
            }
            isLoading = false
        }
    }

    private func validateFields() -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(cleanEmail) else {
            errorMessage = "Enter a valid email address."
            return false
        }

        guard cleanPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        if mode == .signUp {
            guard isStrongPassword(cleanPassword) else {
                errorMessage = "Use a stronger password (8+ chars, uppercase, lowercase, number)."
                return false
            }

            guard cleanPassword == confirmPassword else {
                errorMessage = "Passwords do not match."
                return false
            }

            guard acceptTerms else {
                errorMessage = "You must accept Terms and Privacy."
                return false
            }
        }

        return true
    }

    private func completeAuthSuccess(sessionManager: UserSessionManager, isNewUser: Bool) async throws {
        sessionManager.handleSuccessfulAuthentication(isNewUser: isNewUser)

        if authService.isConfigured, let user = authService.currentUser {
            try await profileService.upsertBasicProfile(user: user)
        }

        if rememberForBiometrics {
            _ = keychainService.saveCredentials(email: email, password: password)
        } else {
            keychainService.clearCredentials()
        }

        hasStoredCredentials = keychainService.hasCredentials

        if isNewUser {
            infoMessage = "Account created. Complete onboarding next."
        } else {
            infoMessage = "Signed in successfully."
        }
    }

    private func handleAuthFailure(_ message: String) {
        errorMessage = message
    }

    private func handleOfflineDemoLogin(sessionManager: UserSessionManager) {
        guard mode == .signIn else {
            errorMessage = "Sign up is disabled until Firebase is configured."
            return
        }

        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard cleanEmail == demoEmail, cleanPassword == demoPassword else {
            handleAuthFailure("Invalid demo credentials. Use prueba@hotmail.com / 123456.")
            return
        }

        sessionManager.handleSuccessfulAuthentication(isNewUser: false)
        sessionManager.completeOnboarding()

        if rememberForBiometrics {
            _ = keychainService.saveCredentials(email: cleanEmail, password: cleanPassword)
        }

        hasStoredCredentials = keychainService.hasCredentials
        infoMessage = "Demo access enabled."
    }

    private func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    private func refreshSecurityState() {
        isBiometricAvailable = biometricService.isBiometricsAvailable
        hasStoredCredentials = keychainService.hasCredentials

        if hasStoredCredentials, let creds = keychainService.loadCredentials() {
            email = creds.email
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }

        let hasUpper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil

        return hasUpper && hasLower && hasNumber
    }

    private func mapAuthError(_ error: Error) -> String {
        if let serviceError = error as? FirebaseAuthService.AuthServiceError {
            return serviceError.localizedDescription
        }

        if let error = error as? BiometricAuthService.BiometricError {
            return error.localizedDescription
        }

        let nsError = error as NSError

        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return nsError.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "Invalid email format."
        case .wrongPassword, .invalidCredential:
            return "Incorrect credentials."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .userNotFound:
            return "No account found with this email."
        case .weakPassword:
            return "The password is too weak."
        case .networkError:
            return "Network error. Check your connection."
        case .tooManyRequests:
            return "Too many attempts. Try again later."
        default:
            return nsError.localizedDescription
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate secure nonce")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

private final class AuthKeychainService {
    private let service = "com.example.WNH.auth"
    private let account = "biometric_credentials"

    var hasCredentials: Bool {
        loadCredentials() != nil
    }

    func saveCredentials(email: String, password: String) -> Bool {
        guard let data = "\(email)|\(password)".data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    func loadCredentials() -> (email: String, password: String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let raw = String(data: data, encoding: .utf8) else {
            return nil
        }

        let parts = raw.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }

        return (email: parts[0], password: parts[1])
    }

    func clearCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

private final class BiometricAuthService {
    enum BiometricError: LocalizedError {
        case unavailable
        case failed

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "Biometrics are not available."
            case .failed:
                return "Biometric verification failed."
            }
        }
    }

    var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticate(reason: String) async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.unavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: BiometricError.failed)
                }
            }
        }
    }
}
