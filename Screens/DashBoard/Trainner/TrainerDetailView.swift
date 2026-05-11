import SwiftUI

struct TrainerDetailView: View {
    let trainer: Trainer
    let onHire: (Trainer) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeSlot: String?
    @State private var activeTab: DetailTab = .overview
    
    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case schedule = "Schedule"
        case reviews = "Reviews"
    }
    
    private var specialty: TrainerSpecialty {
        TrainerSpecialty(rawValue: trainer.specialty) ?? .weightLoss
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    tabSection
                    contentSection
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Trainer Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") { dismiss() }.foregroundColor(.yellow),
                trailing: Button("Hire Now") { onHire(trainer); dismiss() }.foregroundColor(.yellow)
            )
            .onAppear {
                print("🎬 TrainerDetailView apareció para: \(trainer.name)")
                print("📋 Trainer details - Bio: \(trainer.bio.prefix(50))...")
                print("🏷️ Certifications: \(trainer.certifications.count)")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [specialty.color, specialty.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text(trainer.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if trainer.isVerified {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
                
                Text(specialty.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(specialty.color)
                
                HStack(spacing: 20) {
                    StatBox(title: "Rating", value: String(format: "%.1f", trainer.rating), icon: "star.fill")
                    StatBox(title: "Experience", value: "\(trainer.experience)y", icon: "calendar")
                    StatBox(title: "Sessions", value: "\(trainer.totalClients)", icon: "person.2.fill")
                }
            }
        }
    }
    
    private var tabSection: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: { activeTab = tab }) {
                    Text(LanguageManager.localizedString(tab.rawValue))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(activeTab == tab ? .yellow : .gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            Rectangle()
                                .fill(activeTab == tab ? Color.yellow.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(activeTab == tab ? .yellow : .clear),
                            alignment: .bottom
                        )
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var contentSection: some View {
        Group {
            switch activeTab {
            case .overview:
                overviewContent
            case .schedule:
                scheduleContent
            case .reviews:
                reviewsContent
            }
        }
    }
    
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("About")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text(LanguageManager.localizedString(trainer.bio))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Certifications")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(trainer.certifications, id: \.self) { cert in
                        Text(LanguageManager.localizedString(cert))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Languages")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                
                HStack {
                    ForEach(trainer.languages, id: \.self) { language in
                        Text(LanguageManager.localizedString(language))
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var scheduleContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Available Time Slots - Today")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.yellow)
            
            let timeSlots = ["9:00 AM", "10:00 AM", "11:00 AM", "2:00 PM", "3:00 PM", "4:00 PM", "6:00 PM"]
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(timeSlots, id: \.self) { slot in
                    Button(action: { selectedTimeSlot = slot }) {
                        Text(slot)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedTimeSlot == slot ? .black : .white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedTimeSlot == slot ? Color.yellow : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedTimeSlot == slot ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            
            if let slot = selectedTimeSlot {
                VStack(spacing: 12) {
                    Text("\(LanguageManager.localizedString("Selected")): \(slot)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Button(action: { onHire(trainer); dismiss() }) {
                        Text("\(LanguageManager.localizedString("Confirm Booking")) - $\(trainer.pricePerSession)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.yellow)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var reviewsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Reviews")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.yellow)
            
            ForEach(1...3, id: \.self) { index in
                ReviewCard(reviewerName: "Client \(index)")
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(LanguageManager.localizedString(title))
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ReviewCard: View {
    let reviewerName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reviewerName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text("Amazing trainer! Really helped me achieve my goals. Highly recommend!")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
