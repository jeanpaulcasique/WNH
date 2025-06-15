import SwiftUI

struct SettingsView: View {
    @AppStorage("isAppleHealthEnabled") private var isAppleHealthEnabled = false
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = true
    @Environment(\.presentationMode) var presentationMode
    
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
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("Customize your experience")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var profileSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Profile")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            NavigationLink(destination: ProfileView()) {
                SettingsRowView(
                    icon: "person.crop.circle",
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    color: .blue
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    var preferencesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Preferences")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                NavigationLink(destination: PlaceholderView(title: "Language")) {
                    SettingsRowView(
                        icon: "globe",
                        title: "Language",
                        subtitle: "English (US)",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Get workout reminders",
                    color: .orange,
                    isOn: $isNotificationsEnabled
                )
                
                SettingsToggleRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Always enabled for fitness focus",
                    color: .purple,
                    isOn: $isDarkModeEnabled
                )
            }
        }
    }
    
    var healthSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Health & Fitness")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            SettingsToggleRow(
                icon: "heart.fill",
                title: "Apple Health",
                subtitle: "Sync workouts and health data",
                color: .red,
                isOn: $isAppleHealthEnabled
            )
        }
    }
    
    var supportSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Support")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                NavigationLink(destination: FAQView()) {
                    SettingsRowView(
                        icon: "questionmark.circle",
                        title: "FAQ",
                        subtitle: "Frequently asked questions",
                        color: .cyan
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: WriteTSView()) {
                    SettingsRowView(
                        icon: "headphones",
                        title: "Contact Support",
                        subtitle: "Get help from our team",
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("About")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRowView(
                    icon: "info.circle",
                    title: "App Version",
                    subtitle: "1.0.0 (Latest)",
                    color: .gray,
                    showChevron: false
                )
                
                NavigationLink(destination: PlaceholderView(title: "Privacy Policy")) {
                    SettingsRowView(
                        icon: "doc.text",
                        title: "Privacy Policy",
                        subtitle: "How we protect your data",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: PlaceholderView(title: "Terms of Service")) {
                    SettingsRowView(
                        icon: "doc.text",
                        title: "Terms of Service",
                        subtitle: "Our terms and conditions",
                        color: .purple
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
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text(subtitle)
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
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text(subtitle)
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

// MARK: - PlaceholderView for missing screens
struct PlaceholderViewSettings: View {
    let title: String

    var body: some View {
        ZStack {
            // Gradient background matching app style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appYellow)
                    
                    Text("Coming Soon")
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("This feature is under development and will be available in a future update.")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
        .preferredColorScheme(.dark)
    }
}
