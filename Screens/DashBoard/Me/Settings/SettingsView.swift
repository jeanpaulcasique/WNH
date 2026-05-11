import SwiftUI

struct SettingsView: View {
    @AppStorage("isAppleHealthEnabled") private var isAppleHealthEnabled = false
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = true
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        ZStack {
            // Gradient background matching app style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    headerSection
                    profileSection
                    preferencesSection
                    healthSection
                    supportSection
                    aboutSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

// MARK: - Sections
private extension SettingsView {
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
            }
            
            VStack(spacing: 8) {
                Text(languageManager.text(.settingsTitle))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text(languageManager.text(.settingsSubtitle))
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var profileSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.text(.settingsProfile))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            NavigationLink(destination: ProfileView()) {
                    SettingsRowView(
                        icon: "person.crop.circle",
                        title: languageManager.text(.settingsEditProfile),
                        subtitle: languageManager.text(.settingsEditProfileSubtitle),
                        color: .appYellow
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var preferencesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.text(.settingsPreferences))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                NavigationLink(destination: LanguageSelectionView()) {
                    SettingsRowView(
                        icon: "globe",
                        title: languageManager.text(.settingsLanguage),
                        subtitle: languageManager.languageName(languageManager.currentLanguage),
                        color: .appYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: languageManager.text(.settingsNotifications),
                    subtitle: languageManager.text(.settingsNotificationsSubtitle),
                    color: .appYellow,
                    isOn: $isNotificationsEnabled
                )
                
                SettingsToggleRow(
                    icon: "moon.fill",
                    title: languageManager.text(.settingsDarkMode),
                    subtitle: languageManager.text(.settingsDarkModeSubtitle),
                    color: .appYellow,
                    isOn: $isDarkModeEnabled
                )
            }
        }
    }
    
    var healthSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.text(.settingsHealthFitness))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            SettingsToggleRow(
                icon: "heart.fill",
                title: languageManager.text(.settingsAppleHealth),
                subtitle: languageManager.text(.settingsAppleHealthSubtitle),
                color: .appYellow,
                isOn: $isAppleHealthEnabled
            )
        }
    }
    
    var supportSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.text(.settingsSupport))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                NavigationLink(destination: FAQView()) {
                    SettingsRowView(
                        icon: "questionmark.circle",
                        title: languageManager.text(.settingsFAQ),
                        subtitle: languageManager.text(.settingsFAQSubtitle),
                        color: .appYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: WriteTSView()) {
                    SettingsRowView(
                        icon: "headphones",
                        title: languageManager.text(.settingsContactSupport),
                        subtitle: languageManager.text(.settingsContactSupportSubtitle),
                        color: .appYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageManager.text(.settingsAbout))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRowView(
                    icon: "info.circle",
                    title: languageManager.text(.settingsAppVersion),
                    subtitle: languageManager.text(.settingsLatest),
                    color: .appYellow,
                    showChevron: false
                )
                
                NavigationLink(destination: PlaceholderViewSettings(title: languageManager.text(.settingsPrivacyPolicy))) {
                    SettingsRowView(
                        icon: "doc.text",
                        title: languageManager.text(.settingsPrivacyPolicy),
                        subtitle: languageManager.text(.settingsPrivacyPolicySubtitle),
                        color: .appYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PlaceholderViewSettings(title: languageManager.text(.settingsTerms))) {
                    SettingsRowView(
                        icon: "doc.text",
                        title: languageManager.text(.settingsTerms),
                        subtitle: languageManager.text(.settingsTermsSubtitle),
                        color: .appYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Supporting Views
struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let showChevron: Bool
    
    init(icon: String, title: String, subtitle: String, color: Color, showChevron: Bool = true) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.showChevron = showChevron
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LanguageManager.localizedString(title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text(LanguageManager.localizedString(subtitle))
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.4))
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LanguageManager.localizedString(title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text(LanguageManager.localizedString(subtitle))
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .appYellow))
                .scaleEffect(0.8)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    languageOptions
                    currentLanguageNote
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(languageManager.text(.languageTitle))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)

                Image(systemName: "globe")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.appYellow)
            }

            VStack(spacing: 8) {
                Text(languageManager.text(.languageTitle))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)

                Text(languageManager.text(.languageSubtitle))
                    .font(.system(size: 15))
                    .foregroundColor(.appWhite.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var languageOptions: some View {
        VStack(spacing: 12) {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        languageManager.setLanguage(language)
                    }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.appYellow.opacity(0.18))
                                .frame(width: 44, height: 44)

                            Text(language.rawValue.uppercased())
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.appYellow)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageManager.languageName(language))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appWhite)

                            Text(language.nativeName)
                                .font(.system(size: 12))
                                .foregroundColor(.appWhite.opacity(0.6))
                        }

                        Spacer()

                        if language == languageManager.currentLanguage {
                            HStack(spacing: 6) {
                                Text(languageManager.text(.languageSelected))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.appYellow)

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appYellow)
                            }
                        }
                    }
                    .padding(16)
                    .background(language == languageManager.currentLanguage ? Color.appYellow.opacity(0.12) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(language == languageManager.currentLanguage ? Color.appYellow.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var currentLanguageNote: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18))
                .foregroundColor(.appYellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(languageManager.text(.languageCurrent)): \(languageManager.languageName(languageManager.currentLanguage))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite)

                Text(languageManager.text(.languageInstant))
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.65))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: - PlaceholderView for missing screens
struct PlaceholderViewSettings: View {
    let title: String
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: getIcon(for: title))
                        .font(.system(size: 40))
                        .foregroundColor(.appYellow)
                }
                
                VStack(spacing: 8) {
                    Text(LanguageManager.localizedString(title))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appYellow)
                    
                    Text(languageManager.text(.comingSoon))
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text(languageManager.text(.comingSoonDescription))
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .blackGradientBackground()
        .navigationTitle(title)
    }
    
    private func getIcon(for title: String) -> String {
        switch title {
        case "Language":
            return "globe"
        case "Privacy Policy":
            return "doc.text"
        case "Terms of Service":
            return "doc.text"
        default:
            return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .environmentObject(LanguageManager())
        .preferredColorScheme(.dark)
    }
}
