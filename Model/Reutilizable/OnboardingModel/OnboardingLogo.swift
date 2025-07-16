import SwiftUI

struct OnboardingLogo: View {
    var body: some View {
        Image("samsonWhite")
            .resizable()
            .scaledToFit()
            .frame(width: 170)
            .padding(.top, 5)
            .padding(.bottom, -10)
            .opacity(1.0)
    }
} 