import SwiftUI
// MARK: - ProgressBarView COMPLETA (Con título y líneas de progreso integradas)
struct ProgressBarView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Título de fase y porcentaje
            HStack {
                Text(progressViewModel.currentPhaseInfo.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(progressViewModel.currentPhaseInfo.color)
                
                Spacer()
                
                Text("\(progressViewModel.progressPercentage)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            // Indicadores de fase con líneas de progreso integradas
            PhaseIndicatorsRow(progressViewModel: progressViewModel)
        }
    }
}

// MARK: - SOLO LA BARRA (Sin título ni porcentaje) - PARA PANTALLAS EXISTENTES
struct SegmentedProgressBar: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<progressViewModel.phases.count, id: \.self) { phaseIndex in
                    SegmentView(
                        phase: progressViewModel.phases[phaseIndex],
                        isCompleted: phaseIndex < progressViewModel.currentPhase,
                        isCurrent: phaseIndex == progressViewModel.currentPhase,
                        progress: phaseIndex == progressViewModel.currentPhase ? progressViewModel.phaseProgress : 0.0,
                        width: (geometry.size.width - 12) / 4
                    )
                }
            }
        }
        .frame(height: 12)
    }
}

// MARK: - ⭐ VERSIÓN PERFECTA: SOLO ICONOS CON LÍNEAS DE PROGRESO
struct ProgressBarWithIcons: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        // Solo indicadores de fase con líneas de progreso integradas
        PhaseIndicatorsRow(progressViewModel: progressViewModel)
    }
}

// MARK: - SOLO ICONOS DE FASES CON LÍNEAS DE PROGRESO INTEGRADAS
struct PhaseIndicatorsRow: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        HStack(spacing: 8) { // Reducido de 0 a 8 para mejor control
            ForEach(0..<progressViewModel.phases.count, id: \.self) { phaseIndex in
                let phase = progressViewModel.phases[phaseIndex]
                let isCompleted = phaseIndex < progressViewModel.currentPhase
                let isCurrent = phaseIndex == progressViewModel.currentPhase
                let progress = phaseIndex == progressViewModel.currentPhase ? progressViewModel.phaseProgress : 0.0
                
                HStack(spacing: 4) { // Spacing más pequeño entre icono y línea
                    PhaseIndicatorCompact(
                        phase: phase,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        progress: progress
                    )
                    
                    if phaseIndex < progressViewModel.phases.count - 1 {
                        // Línea conectora centrada y más pegada
                        ZStack(alignment: .leading) {
                            // Fondo de la línea de progreso
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 30, height: 3) // Ancho fijo y altura reducida
                            
                            // Progreso en la línea conectora
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            progressViewModel.phases[phaseIndex].color.opacity(0.8),
                                            progressViewModel.phases[phaseIndex].color
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 30 * connectionProgress(for: phaseIndex), height: 3)
                                .animation(.easeInOut(duration: 0.5), value: progressViewModel.currentPhase)
                                .animation(.easeInOut(duration: 0.5), value: progressViewModel.phaseProgress)
                        }
                        .offset(y: -8) // Mueve la línea hacia arriba para centrarla con los iconos
                    }
                }
            }
        }
    }
    
    // Calcular el progreso de la línea conectora entre fases
    private func connectionProgress(for phaseIndex: Int) -> CGFloat {
        if phaseIndex < progressViewModel.currentPhase {
            // Fase completada - línea completamente llena
            return 1.0
        } else if phaseIndex == progressViewModel.currentPhase {
            // Fase actual - progreso parcial
            return CGFloat(progressViewModel.phaseProgress)
        } else {
            // Fase futura - línea vacía
            return 0.0
        }
    }
}

// MARK: - Phase Indicator Compact (Versión pequeña para pantallas existentes)
struct PhaseIndicatorCompact: View {
    let phase: OnboardingPhase
    let isCompleted: Bool
    let isCurrent: Bool
    let progress: Double
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 1.5)
                    )
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: phase.icon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(iconColor)
                }
            }
            .scaleEffect(isCurrent ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
            
            Text(phase.title)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return phase.color
        } else if isCurrent {
            return phase.color.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isCompleted || isCurrent {
            return phase.color
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var iconColor: Color {
        if isCurrent {
            return phase.color
        } else {
            return Color.gray.opacity(0.6)
        }
    }
    
    private var textColor: Color {
        if isCompleted || isCurrent {
            return phase.color
        } else {
            return Color.gray.opacity(0.6)
        }
    }
}

// MARK: - SegmentView
struct SegmentView: View {
    let phase: OnboardingPhase
    let isCompleted: Bool
    let isCurrent: Bool
    let progress: Double
    let width: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background del segmento
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: 12)
            
            // Progress fill
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * progressWidth, height: 12)
                .animation(.easeInOut(duration: 0.5), value: progressWidth)
            
            // Glow effect para el segmento actual
            if isCurrent && progress > 0 {
                RoundedRectangle(cornerRadius: 6)
                    .fill(phase.color.opacity(0.3))
                    .frame(width: width * progressWidth, height: 12)
                    .blur(radius: 4)
                    .animation(.easeInOut(duration: 0.5), value: progressWidth)
            }
        }
        .overlay(
            // Border
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    isCurrent ? phase.color.opacity(0.6) : Color.clear,
                    lineWidth: isCurrent ? 1 : 0
                )
                .animation(.easeInOut(duration: 0.3), value: isCurrent)
        )
        .scaleEffect(isCurrent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
    }
    
    private var progressWidth: CGFloat {
        if isCompleted {
            return 1.0  // Completamente lleno
        } else if isCurrent {
            return CGFloat(progress)  // Progreso actual
        } else {
            return 0.0  // Vacío
        }
    }
    
    private var gradientColors: [Color] {
        if isCompleted || (isCurrent && progress > 0) {
            return [phase.color.opacity(0.8), phase.color]
        } else {
            return [Color.clear, Color.clear]
        }
    }
}

// MARK: - VERSIÓN ALTERNATIVA: Solo iconos de fases (Para compatibilidad)
struct PhaseIndicatorsOnlyView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        PhaseIndicatorsRow(progressViewModel: progressViewModel)
    }
}

/*
🎯 GUÍA DE COMPONENTES DISPONIBLES:

1. ProgressBarView
   - Versión COMPLETA: título + iconos + barra
   - Para pantallas nuevas que no tienen header propio

2. ProgressBarWithIcons ⭐ RECOMENDADO PARA TI
   - Iconos + barra (sin título)
   - Para pantallas existentes que ya tienen su título/porcentaje

3. SegmentedProgressBar
   - Solo la barra (sin iconos ni título)
   - Para pantallas que solo quieren la barra básica

4. PhaseIndicatorsRow
   - Solo los iconos (sin barra)
   - Para usar por separado si necesitas
*/

// MARK: - Preview
struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // 1. Progress bar COMPLETA (título + iconos con líneas de progreso)
            ProgressBarView(progressViewModel: ProgressViewModel())
                .padding()
            
            // 2. ⭐ DISEÑO LIMPIO: Solo iconos con líneas de progreso integradas
            VStack(spacing: 8) {
                HStack {
                    Text("Physical Profile")
                        .foregroundColor(.blue)
                     
                    Spacer()
                }
                ProgressBarWithIcons(progressViewModel: ProgressViewModel()) // ⭐ DISEÑO ACTUALIZADO
            }
            .padding()
            
            // 3. Para referencia: Barra tradicional antigua (opcional)
            VStack(spacing: 8) {
                HStack {
                    Text("Legacy Progress Bar")
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                SegmentedProgressBar(progressViewModel: ProgressViewModel())
            }
            .padding()
        }
        .background(Color.black)
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
