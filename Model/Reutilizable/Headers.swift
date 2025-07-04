import SwiftUI

// MARK: - Section Header
struct SimpleSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Page Header
struct PageHeader: View {
    let icon: String
    let title: String
    let subtitle: String?
    let progressViewModel: ProgressViewModel?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        progressViewModel: ProgressViewModel? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.progressViewModel = progressViewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let progressViewModel = progressViewModel {
                ProgressBarWithIcons(progressViewModel: progressViewModel)
                    .padding(.top, 10)
            }
            
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
    }
} 