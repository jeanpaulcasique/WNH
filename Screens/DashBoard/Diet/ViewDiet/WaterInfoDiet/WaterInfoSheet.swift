import SwiftUI

struct WaterInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Formula Section
                    formulaSection
                    
                    // Benefits Section
                    benefitsSection
                    
                    // Sources Section
                    sourcesSection
                    
                    // Research Section
                    researchSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Water Intake Science")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 48))
                .foregroundColor(.cyan)
            
            Text("Scientific Hydration Guide")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Based on comprehensive research from leading health organizations")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Scientific Formula", icon: "function")
            
            VStack(spacing: 12) {
                formulaCard(
                    title: "Base Formula",
                    description: "3.7L for men, 2.7L for women",
                    icon: "person.fill"
                )
                
                formulaCard(
                    title: "Activity Adjustment",
                    description: "+0.5L per hour of exercise",
                    icon: "figure.run"
                )
                
                formulaCard(
                    title: "Climate Factor",
                    description: "+0.5L in hot/humid conditions",
                    icon: "thermometer.sun.fill"
                )
                
                formulaCard(
                    title: "Body Weight Factor",
                    description: "+0.033L per kg of body weight",
                    icon: "scalemass.fill"
                )
            }
        }
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Benefits of Proper Hydration", icon: "heart.fill")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                benefitCard("Enhanced cognitive function", "brain.head.profile")
                benefitCard("Improved physical performance", "figure.strengthtraining.traditional")
                benefitCard("Better temperature regulation", "thermometer")
                benefitCard("Optimal kidney function", "heart.circle.fill")
                benefitCard("Reduced risk of kidney stones", "shield.checkered")
                benefitCard("Improved skin health", "face.smiling")
                benefitCard("Better digestion", "stomach.fill")
                benefitCard("Enhanced nutrient absorption", "leaf.fill")
            }
        }
    }
    
    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Scientific Sources", icon: "book.fill")
            
            VStack(spacing: 12) {
                sourceCard(
                    "Institute of Medicine (2004)",
                    "Dietary Reference Intakes",
                    "🏛️"
                )
                
                sourceCard(
                    "American College of Sports Medicine (2007)",
                    "Exercise and Fluid Replacement",
                    "🏃‍♂️"
                )
                
                sourceCard(
                    "European Food Safety Authority (2010)",
                    "Scientific Opinion on Dietary Reference Values",
                    "🇪🇺"
                )
            }
        }
    }
    
    private var researchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Research Findings", icon: "magnifyingglass")
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Studies show that even mild dehydration (1-2% body weight loss) can impair:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    researchPoint("Cognitive performance")
                    researchPoint("Mood and mental clarity")
                    researchPoint("Physical endurance")
                    researchPoint("Reaction time")
                }
                
                Text("The IOM's comprehensive review of over 200 studies established these guidelines as the gold standard for hydration recommendations.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            .padding(16)
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.cyan)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func formulaCard(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func benefitCard(_ title: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.cyan)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.cyan.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func sourceCard(_ title: String, _ subtitle: String, _ emoji: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func researchPoint(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.cyan)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    WaterInfoSheet()
} 