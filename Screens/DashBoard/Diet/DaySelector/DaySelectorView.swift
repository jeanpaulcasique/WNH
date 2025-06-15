import SwiftUI

struct DaySelectorView: View {
    @ObservedObject var viewModel: DaySelectorViewModel
    
    private let shortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "E"
        return f
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Day")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.days, id: \.self) { day in
                        let label = shortFormatter.string(from: day)
                        VStack(spacing: 8) {
                            Text(label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.7))
                            
                            Text(viewModel.dayNumber(from: day))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(viewModel.selectedDay == day ? .appBlack : .appWhite)
                                .frame(width: 45, height: 45)
                                .background(viewModel.selectedDay == day ? Color.appYellow : Color.gray.opacity(0.1))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            viewModel.selectedDay == day ? Color.clear : Color.appYellow.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(
                                    color: viewModel.selectedDay == day ? Color.appYellow.opacity(0.3) : Color.clear,
                                    radius: 8, x: 0, y: 4
                                )
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                viewModel.select(day: day)
                            }
                            
                            // Haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }
                }
            }
        }
    }
}

struct DaySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DaySelectorView(viewModel: DaySelectorViewModel())
            .preferredColorScheme(.dark)
    }
} 