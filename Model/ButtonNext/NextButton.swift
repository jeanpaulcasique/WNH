import SwiftUI

struct NextButton: View {
    let title: String
    let action: () -> Void
    @Binding var isLoading: Bool
    @Binding var isDisabled: Bool

    var body: some View {
        Button(action: {
            if !isDisabled {
                isDisabled = true
                isLoading = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isDisabled = false
                    isLoading = false
                }
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow)
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .disabled(isDisabled)
    }
}
