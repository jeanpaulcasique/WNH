import SwiftUI

struct HeartRateIndicator: View {
    var bpm: Double?
    var isAuthorized: Bool
    var onRequestAuthorization: () -> Void
    @State private var bpmScale: CGFloat = 1.0
    @State private var heartScale: CGFloat = 1.0
    @State private var showAuthDialog = false
    var body: some View {
        let bpmInt = bpm != nil ? Int(bpm!) : 0
        ZStack {
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [Color.red.opacity(0.35), .black]), center: .center, startRadius: 8, endRadius: 40)
                )
                .frame(width: 60, height: 60)
            
            VStack(spacing: 1) {
                Text("BPM")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.yellow.opacity(0.7))
                Text(bpm != nil ? "\(bpmInt)" : "--")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(bpmScale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: bpmScale)
                Image(systemName: "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.red)
                    .scaleEffect(heartScale)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: heartScale)
            }
        }
        .onAppear {
            heartScale = 1.0
            withAnimation {
                heartScale = 1.18
            }
        }
        .onChange(of: bpmInt) { old, new in
            if old != new {
                bpmScale = 1.25
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    bpmScale = 1.0
                }
            }
        }
        .onTapGesture {
            if !isAuthorized {
                showAuthDialog = true
            }
        }
        .alert(isPresented: $showAuthDialog) {
            Alert(
                title: Text("Allow Health Access"),
                message: Text("To show your heart rate, please allow access to Health data."),
                primaryButton: .default(Text("Allow"), action: onRequestAuthorization),
                secondaryButton: .cancel()
            )
        }
    }
}
