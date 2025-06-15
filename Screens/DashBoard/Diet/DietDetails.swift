import SwiftUI

// MARK: - DietDetails Model
struct DietDetails: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let howItWorks: String
    let benefits: [String]
    let considerations: [String]
    let color: Color
    let gradientColors: [Color]
    let icon: String
    let difficulty: String
    let timeToResults: String
    let macroSplit: String
}

// MARK: - Epic Diet Card
struct EpicDietCard: View {
    let imageName: String
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let isSelected: Bool
    let dietDetails: DietDetails
    let onTap: () -> Void
    let onLearnMore: () -> Void
    
    var body: some View {
        ZStack {
            cardBackground
            cardContent
        }
        .scaleEffect(isSelected ? 1.05 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Epic Diet Card Components
private extension EpicDietCard {
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: isSelected ?
                        [dietDetails.color.opacity(0.6), dietDetails.color.opacity(0.3)] :
                        [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ?
                                [dietDetails.color, dietDetails.color.opacity(0.5)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .shadow(
                color: isSelected ? dietDetails.color.opacity(0.4) : Color.black.opacity(0.2),
                radius: isSelected ? 20 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
    }
    
    var cardContent: some View {
        VStack(spacing: 16) {
            headerSection
            descriptionSection
            Spacer()
            if isSelected {
                footerSection
            }
            Spacer(minLength: 16)
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 12) {
            iconCircle
            titleSection
        }
        .padding(.top, 20)
    }
    
    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            dietDetails.color.opacity(isSelected ? 0.8 : 0.4),
                            dietDetails.color.opacity(isSelected ? 0.4 : 0.2)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 50
                    )
                )
                .frame(width: 80, height: 80)
            
            Image(systemName: imageName)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(isSelected ? .appWhite : dietDetails.color)
        }
    }
    
    var titleSection: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(dietDetails.difficulty)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(dietDetails.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(dietDetails.color.opacity(0.2))
                .cornerRadius(8)
        }
    }
    
    var descriptionSection: some View {
        VStack(spacing: 8) {
            Text(shortDescription)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.9))
                .multilineTextAlignment(.center)
            
            if isSelected {
                Text(detailedDescription)
                    .font(.system(size: 13))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var footerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Results")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appWhite.opacity(0.7))
                    
                    Text(dietDetails.timeToResults)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(dietDetails.color)
                }
                
                Spacer()
                
                Button(action: {
                    onLearnMore()
                }) {
                    Text("Learn More")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appWhite)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(dietDetails.color.opacity(0.8))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Quick Comparison Card
struct QuickComparisonCard: View {
    @ObservedObject var viewModel: DietTypeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<viewModel.imageCount, id: \.self) { index in
                ComparisonRow(index: index, viewModel: viewModel)
            }
        }
        .padding(20)
        .background(cardBackground)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Comparison Row
private struct ComparisonRow: View {
    let index: Int
    @ObservedObject var viewModel: DietTypeViewModel
    
    private var details: DietDetails {
        viewModel.getDietDetails(for: index)
    }
    
    private var isSelected: Bool {
        index == viewModel.currentIndex
    }
    
    var body: some View {
        HStack(spacing: 16) {
            iconSection
            infoSection
            Spacer()
            selectionIndicator
        }
        .padding(.vertical, 8)
        .opacity(isSelected ? 1.0 : 0.6)
    }
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(details.color.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Image(systemName: details.icon)
                .font(.system(size: 18))
                .foregroundColor(details.color)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.titles[index])
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appWhite)
            
            HStack {
                Text(details.difficulty)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(details.color)
                
                Text("•")
                    .foregroundColor(.appWhite.opacity(0.5))
                
                Text(details.timeToResults)
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    private var selectionIndicator: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(details.color)
        }
    }
}

// MARK: - Epic Diet Info View
struct EpicDietInfoView: View {
    let dietDetails: DietDetails
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                contentScrollView
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: dismissButton)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var dismissButton: some View {
        Button("Got it!") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.appYellow)
        .font(.system(size: 16, weight: .semibold))
    }
    
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                statsSection
                howItWorksSection
                benefitsSection
                considerationsSection
                Spacer(minLength: 30)
            }
            .padding(20)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            headerIcon
            headerTitles
            headerDescription
        }
    }
    
    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [dietDetails.color.opacity(0.4), dietDetails.color.opacity(0.1)],
                        center: .center,
                        startRadius: 40,
                        endRadius: 80
                    )
                )
                .frame(width: 120, height: 120)
            
            Image(systemName: dietDetails.icon)
                .font(.system(size: 50))
                .foregroundColor(dietDetails.color)
        }
    }
    
    private var headerTitles: some View {
        VStack(spacing: 8) {
            Text(dietDetails.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
            
            Text(dietDetails.subtitle)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(dietDetails.color)
        }
    }
    
    private var headerDescription: some View {
        Text(dietDetails.description)
            .font(.system(size: 16))
            .foregroundColor(.appWhite.opacity(0.9))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatBox(title: "Difficulty", value: dietDetails.difficulty, color: .orange)
            StatBox(title: "Results", value: dietDetails.timeToResults, color: .green)
            StatBox(title: "Macros", value: dietDetails.macroSplit, color: .blue)
        }
    }
    
    private var howItWorksSection: some View {
        InfoSection(
            title: "How It Works",
            content: dietDetails.howItWorks,
            icon: "gear.circle.fill",
            color: .blue
        )
    }
    
    private var benefitsSection: some View {
        BenefitsSection(benefits: dietDetails.benefits)
    }
    
    private var considerationsSection: some View {
        ConsiderationsSection(considerations: dietDetails.considerations)
    }
}

// MARK: - Diet Info View Components
private struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

private struct InfoSection: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.appWhite.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .background(sectionBackground(color))
    }
}

private struct BenefitsSection: View {
    let benefits: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            benefitsList
        }
        .padding(20)
        .background(sectionBackground(.green))
    }
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
            
            Text("Key Benefits")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            
            Spacer()
        }
    }
    
    private var benefitsList: some View {
        VStack(spacing: 12) {
            ForEach(benefits, id: \.self) { benefit in
                BenefitRowD(text: benefit)
            }
        }
    }
}

private struct ConsiderationsSection: View {
    let considerations: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader
            considerationsList
        }
        .padding(20)
        .background(sectionBackground(.orange))
    }
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
            
            Text("Important Considerations")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            
            Spacer()
        }
    }
    
    private var considerationsList: some View {
        VStack(spacing: 12) {
            ForEach(considerations, id: \.self) { consideration in
                BenefitRowD(text: consideration)
            }
        }
    }
}

private struct BenefitRowD: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(text.prefix(2)))
                .font(.system(size: 16))
            
            Text(String(text.dropFirst(2)))
                .font(.system(size: 15))
                .foregroundColor(.appWhite.opacity(0.9))
                .lineSpacing(3)
            
            Spacer()
        }
    }
}

// MARK: - Shared Background Function
private func sectionBackground(_ color: Color) -> some View {
    RoundedRectangle(cornerRadius: 16)
        .fill(color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
}
