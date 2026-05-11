import Foundation
import Combine
import HealthKit
import SwiftUI

// MARK: - Heart Rate Notification Integration

/// Extensión para integrar las notificaciones de ritmo cardíaco con el sistema HealthKit existente
fileprivate var heartRateIntegrationCancellables = Set<AnyCancellable>()
extension HeartRateNotificationManager {
    
    /// Integra con el HealthKitService existente
    func integrateWithHealthKit(_ healthKitService: HealthKitService) {
        print("🫀 Integrando notificaciones con HealthKitService...")
        
        // Observar cambios en el ritmo cardíaco
        healthKitService.$currentHeartRate
            .compactMap { $0 }
            .sink { [weak self] heartRate in
                self?.processHeartRate(heartRate)
            }
            .store(in: &heartRateIntegrationCancellables)
    }
    
    /// Integra con el HealthKitCoordinator
    func integrateWithHealthKitCoordinator(_ coordinator: HealthKitCoordinator) {
        print("🫀 Integrando notificaciones con HealthKitCoordinator...")
        
        // Observar cambios en el ritmo cardíaco desde el coordinador
        coordinator.$heartRate
            .compactMap { $0 }
            .sink { [weak self] heartRate in
                self?.processHeartRate(Int(heartRate))
            }
            .store(in: &heartRateIntegrationCancellables)
    }
}

// MARK: - Workout Integration

extension HeartRateNotificationManager {
    
    /// Ajusta las alertas basándose en el estado de entrenamiento
    func adjustForWorkoutState(isWorkingOut: Bool, workoutType: String? = nil) {
        if isWorkingOut {
            print("🫀 Ajustando alertas para entrenamiento: \(workoutType ?? "unknown")")
            
            // Durante el entrenamiento, ajustar los umbrales
            adjustThresholdsForWorkout(workoutType: workoutType)
        } else {
            print("🫀 Restaurando alertas normales (no entrenando)")
            
            // Restaurar umbrales normales
            restoreNormalThresholds()
        }
    }
    
    private func adjustThresholdsForWorkout(workoutType: String?) {
        // Durante el ejercicio, permitir ritmos cardíacos más altos
        // Esto se puede personalizar según el tipo de entrenamiento
        print("🫀 Umbrales ajustados para entrenamiento")
        
        // TODO: Implementar lógica específica según el tipo de entrenamiento
        // Por ejemplo: cardio permite hasta 180 bpm, fuerza hasta 160 bpm, etc.
    }
    
    private func restoreNormalThresholds() {
        // Restaurar umbrales normales para actividad en reposo
        print("🫀 Umbrales restaurados a valores normales")
    }
}

// MARK: - Daily Progress Integration

extension HeartRateNotificationManager {
    
    /// Integra con el DailyProgressService para contexto adicional
    func integrateWithDailyProgress(_ progressService: DailyProgressService) {
        print("🫀 Integrando con DailyProgressService...")
        
        // Observar cambios en el progreso diario para contexto
        progressService.$currentDayProgress
            .sink { [weak self] progress in
                self?.updateContextFromDailyProgress(progress)
            }
            .store(in: &heartRateIntegrationCancellables)
    }
    
    private func updateContextFromDailyProgress(_ progress: DailyProgress?) {
        guard let progress = progress else { return }
        
        // Usar datos del progreso diario para mejor contexto en las alertas
        let context = HeartRateContext(
            activeMinutes: progress.activeMinutes,
            caloriesBurned: progress.caloriesBurned,
            currentWeight: progress.currentWeight,
            lastWorkoutTime: progress.updatedAt
        )
        
        updateAlertContext(context)
    }
    
    private func updateAlertContext(_ context: HeartRateContext) {
        // Actualizar el contexto para alertas más inteligentes
        print("🫀 Contexto actualizado: \(context.activeMinutes) min activos, \(context.caloriesBurned) cal")
    }
}

// MARK: - Smart Alert Logic

extension HeartRateNotificationManager {
    
    /// Lógica inteligente para determinar si se debe enviar una alerta
    func shouldSendSmartAlert(heartRate: Int, context: HeartRateContext?) -> Bool {
        // Lógica simplificada que evita depender de miembros privados del manager
        let baseDecision = (heartRate >= 180 || heartRate <= 50)
        guard let context = context else { return baseDecision }
        
        // Factores que pueden suprimir alertas:
        
        // 1. Si hay actividad reciente (últimos 30 minutos)
        if let lastWorkout = context.lastWorkoutTime,
           Date().timeIntervalSince(lastWorkout) < 1800 { // 30 minutes
            print("🫀 Suprimiendo alerta: actividad reciente detectada")
            return false
        }
        
        // 2. Si los minutos activos son altos (persona activa)
        if context.activeMinutes > 30 && heartRate < 180 {
            print("🫀 Suprimiendo alerta: persona activa con ritmo moderado")
            return false
        }
        
        return baseDecision
    }
}

// MARK: - Supporting Models

struct HeartRateContext {
    let activeMinutes: Int
    let caloriesBurned: Int
    let currentWeight: Double?
    let lastWorkoutTime: Date?
}

// (Se removió la extensión de WorkoutViewModel para evitar dependencias inexistentes)

// MARK: - Settings Integration

struct HeartRateNotificationSettings: View {
    @ObservedObject var notificationManager = HeartRateNotificationManager.shared
    @State private var showAdvancedSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Main toggle
            HeartRateMonitoringToggle()
            
            if notificationManager.isMonitoringEnabled {
                // Advanced settings
                Button(action: {
                    showAdvancedSettings = true
                }) {
                    HStack {
                        Text("Advanced Settings")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appYellow)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                // Status info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status Information")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    statusRow("Monitoring", value: notificationManager.getMonitoringStatus())
                    
                    if let lastNotification = notificationManager.lastNotificationTime {
                        statusRow("Last Alert", value: formatLastNotificationTime(lastNotification))
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
        .sheet(isPresented: $showAdvancedSettings) {
            AdvancedHeartRateSettingsView()
        }
    }
    
    @ViewBuilder
    private func statusRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appYellow)
        }
    }
    
    private func formatLastNotificationTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct AdvancedHeartRateSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Advanced settings coming soon")
                    .foregroundColor(.gray)
            }
            .background(Color.appBlack)
            .navigationTitle("Heart Rate Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appYellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

