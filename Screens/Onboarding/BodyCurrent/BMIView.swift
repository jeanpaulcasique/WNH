import SwiftUI

struct BMIView: View {
    @ObservedObject var viewModel: BMIViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    @State private var navigateToWeightView = false
    @State private var showInfoSheet = false
    
    var body: some View {
        ZStack {
            // Fondo degradado gris-negro
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.18, green: 0.19, blue: 0.22),
                    Color(red: 0.10, green: 0.11, blue: 0.13)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                // Gauge semicircular BMI
                ZStack {
                    // Gauge de colores
                    GaugeArc()
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                    // Aguja
                    let bmi = viewModel.bmi
                    let bmiColor = viewModel.bmiColor
                    let categoryText = viewModel.bmiCategoryText
                    let angle = viewModel.bmiNeedleAngle
                    NeedleLine()
                        .stroke(Color.white, lineWidth: 8)
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(angle))
                        .rotationEffect(.degrees(-90))
                    // (Eliminado círculo central para limpiar la visualización)
                    // Texto central
                    VStack(spacing: 8) {
                        Text("YOUR BMI")
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        Text(String(format: "%.1f", bmi))
                            .font(.system(size: 54, weight: .black, design: .default))
                            .foregroundColor(bmiColor)
                        Text(categoryText)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(bmiColor)
                    }
                }
                // Mensaje motivacional debajo del gauge y categoría
                VStack {
                    VStack(alignment: .center, spacing: 16) {
                        Text("Your Personalized Recommendation")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Text(viewModel.motivationalMessage)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))

                        Text("Follow your personalized plan and track your progress with Samson.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding()
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                }
                Spacer()
                // Botones reutilizables abajo
                HStack {
                    OnboardingBack {
                        navigateToWeightView = true
                    }
                    Spacer()
                    OnboardingNext {
                        progressViewModel.advanceProgress()
                        navigateToNextView = true
                    }
                }
                .frame(height: 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
                // Navegación
                NavigationLink(
                    destination: TargetWeightView(
                        viewModel: TargetWeightViewModel(),
                        progressViewModel: progressViewModel
                    ),
                    isActive: $navigateToNextView
                ) {
                    EmptyView()
                }
                .hidden()
                NavigationLink(
                    destination: WeightView(viewModel: WeightViewModel(), progressViewModel: progressViewModel),
                    isActive: $navigateToWeightView
                ) {
                    EmptyView()
                }
                .hidden()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showInfoSheet = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.yellow)
                            .clipShape(Circle())
                            .shadow(color: Color.yellow.opacity(0.4), radius: 8, x: 0, y: 4)
                            .scaleEffect(showInfoSheet ? 1.15 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                value: showInfoSheet
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showInfoSheet) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.18, green: 0.19, blue: 0.22),
                        Color(red: 0.10, green: 0.11, blue: 0.13)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    Text("What is BMI?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text("BMI (Body Mass Index) is a general indicator of body fat based on your height and weight. It's useful for population-level trends but not always precise for individuals.")
                        .foregroundColor(.white)
                        .font(.body)
                    Text("To get more accurate data like fat %, muscle mass and visceral fat, we recommend working with a certified trainer available in our app.")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.body)
                    Spacer()
                    Button("Close") {
                        showInfoSheet = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .padding(28)
            }
        }
    }
}


// MARK: - Preview
struct BMIView_Previews: PreviewProvider {
    static var previews: some View {
        BMIView(viewModel: BMIViewModel(), progressViewModel: ProgressViewModel())
    }
}

// GaugeArc: Semicircular, colores: verde, amarillo, naranja, rojo
struct GaugeArc: View {
    var body: some View {
        ZStack {
            // Verde (Normal)
            ArcShape(startAngle: .degrees(-135), endAngle: .degrees(-45))
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .leading, endPoint: .trailing), lineWidth: 22)
            // Amarillo (Sobrepeso)
            ArcShape(startAngle: .degrees(-45), endAngle: .degrees(30))
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing), lineWidth: 22)
            // Naranja/Rojo (Obesidad)
            ArcShape(startAngle: .degrees(30), endAngle: .degrees(135))
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing), lineWidth: 22)
        }
    }
}

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

// NeedleLine: línea blanca delgada desde el centro hasta el borde del gauge
struct NeedleLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = rect.width / 2
        let innerRadius = rect.width / 2 - 22
        let start = CGPoint(x: center.x, y: center.y - innerRadius)
        let end = CGPoint(x: center.x, y: center.y - outerRadius)
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}
