import SwiftUI
import Combine

// MARK: - Heart Rate Alert View

struct HeartRateAlertView: View {
    @ObservedObject var notificationManager = HeartRateNotificationManager.shared
    @State private var showEmergencyOptions = false
    
    var body: some View {
        ZStack {
            if notificationManager.showInAppAlert,
               let alert = notificationManager.currentAlert {
                
                // Background overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissAlert()
                    }
                
                // Alert card
                alertCard(for: alert)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: notificationManager.showInAppAlert)
            }
        }
        .sheet(isPresented: $showEmergencyOptions) {
            EmergencyOptionsView()
        }
    }
    
    @ViewBuilder
    private func alertCard(for alert: HeartRateAlert) -> some View {
        VStack(spacing: 20) {
            // Header with icon and type
            VStack(spacing: 8) {
                alertIcon(for: alert.type)
                
                Text(alert.type.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(alertColor(for: alert.type))
                    .multilineTextAlignment(.center)
            }
            
            // Heart rate display
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    
                    Text("\(alert.heartRate)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("bpm")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Text(alert.zone.description + " Zone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(alert.zone.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(alert.zone.color.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Message
            Text(alert.message)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Timestamp
            Text("Detected at \(alert.formattedTime)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            // Action buttons
            actionButtons(for: alert)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appBlack)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [alertColor(for: alert.type).opacity(0.6), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: alertColor(for: alert.type).opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func alertIcon(for type: HeartRateAlertType) -> some View {
        ZStack {
            Circle()
                .fill(alertColor(for: type).opacity(0.2))
                .frame(width: 80, height: 80)
            
            Image(systemName: alertSystemImage(for: type))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(alertColor(for: type))
        }
    }
    
    @ViewBuilder
    private func actionButtons(for alert: HeartRateAlert) -> some View {
        VStack(spacing: 12) {
            if alert.type == .critical {
                // Emergency button for critical alerts
                Button(action: {
                    showEmergencyOptions = true
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Emergency Options")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
            
            HStack(spacing: 12) {
                // View details button
                Button(action: {
                    openWorkoutView()
                }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("View Details")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appYellow)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.appYellow.opacity(0.2))
                    .cornerRadius(10)
                }
                
                // Dismiss button
                Button(action: {
                    dismissAlert()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Dismiss")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func alertColor(for type: HeartRateAlertType) -> Color {
        switch type {
        case .tooHigh:
            return .orange
        case .tooLow:
            return .blue
        case .critical:
            return .red
        case .normal:
            return .green
        }
    }
    
    private func alertSystemImage(for type: HeartRateAlertType) -> String {
        switch type {
        case .tooHigh:
            return "arrow.up.circle.fill"
        case .tooLow:
            return "arrow.down.circle.fill"
        case .critical:
            return "exclamationmark.triangle.fill"
        case .normal:
            return "checkmark.circle.fill"
        }
    }
    
    private func dismissAlert() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            notificationManager.showInAppAlert = false
        }
        
        // Clear after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            notificationManager.clearOldAlerts()
        }
    }
    
    private func openWorkoutView() {
        // TODO: Navigate to workout/heart rate view
        dismissAlert()
        print("🫀 Opening workout view for heart rate details")
    }
}

// MARK: - Emergency Options View

struct EmergencyOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cross.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Emergency Options")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Critical heart rate detected")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                // Emergency actions
                VStack(spacing: 16) {
                    emergencyButton(
                        title: "Call Emergency Services",
                        subtitle: "Call 911 immediately",
                        icon: "phone.fill",
                        color: .red
                    ) {
                        callEmergencyServices()
                    }
                    
                    emergencyButton(
                        title: "Contact Emergency Contact",
                        subtitle: "Notify your emergency contact",
                        icon: "person.fill",
                        color: .orange
                    ) {
                        contactEmergencyContact()
                    }
                    
                    emergencyButton(
                        title: "Open Health App",
                        subtitle: "View detailed health data",
                        icon: "heart.text.square.fill",
                        color: .blue
                    ) {
                        openHealthApp()
                    }
                }
                
                Spacer()
                
                // Disclaimer
                Text("If you are experiencing chest pain, difficulty breathing, or other serious symptoms, call emergency services immediately.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(24)
            .background(Color.appBlack)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private func emergencyButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Emergency Actions
    
    private func callEmergencyServices() {
        if let url = URL(string: "tel://911") {
            UIApplication.shared.open(url)
        }
        dismiss()
    }
    
    private func contactEmergencyContact() {
        // TODO: Get emergency contact from user profile
        print("🫀 Contacting emergency contact")
        dismiss()
    }
    
    private func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        }
        dismiss()
    }
}

// MARK: - Heart Rate Monitoring Toggle

struct HeartRateMonitoringToggle: View {
    @ObservedObject var notificationManager = HeartRateNotificationManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Heart Rate Monitoring")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Get alerts for unusual heart rate patterns")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { notificationManager.isMonitoringEnabled },
                    set: { enabled in
                        if enabled {
                            notificationManager.startMonitoring()
                        } else {
                            notificationManager.stopMonitoring()
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .appYellow))
            }
            
            if notificationManager.isMonitoringEnabled {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Monitoring active")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button("Test") {
                        notificationManager.testNotificationSystem()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appYellow.opacity(0.2))
                    .cornerRadius(6)
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Preview

struct HeartRateAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HeartRateMonitoringToggle()
                
                Button("Test High Alert") {
                    let alert = HeartRateAlert(
                        type: .tooHigh,
                        heartRate: 180,
                        zone: .veryHigh,
                        timestamp: Date(),
                        message: "Your heart rate is elevated. Consider resting and monitoring your condition."
                    )
                    HeartRateNotificationManager.shared.currentAlert = alert
                    HeartRateNotificationManager.shared.showInAppAlert = true
                }
                .foregroundColor(.appYellow)
                
                Button("Test Critical Alert") {
                    let alert = HeartRateAlert(
                        type: .critical,
                        heartRate: 210,
                        zone: .critical,
                        timestamp: Date(),
                        message: "CRITICAL: Your heart rate is extremely high. Please seek immediate medical attention."
                    )
                    HeartRateNotificationManager.shared.currentAlert = alert
                    HeartRateNotificationManager.shared.showInAppAlert = true
                }
                .foregroundColor(.red)
            }
            .padding()
            
            HeartRateAlertView()
        }
        .preferredColorScheme(.dark)
    }
}

