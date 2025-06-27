import SwiftUI
import MapKit

struct TrainersMapsView: View {
    let trainers: [Trainer]
    let onSelectTrainer: (Trainer) -> Void
    
    @StateObject private var viewModel = TrainersMapsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrainer: Trainer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                mapContent
            }
            .background(Color.black)
            .onAppear {
                viewModel.setTrainers(trainers)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - View Components
private extension TrainersMapsView {
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trainers Near You")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Found \(trainers.count) trainer\(trainers.count != 1 ? "s" : "") nearby")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.yellow)
            .font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.9))
    }
    
    var mapContent: some View {
        HStack(spacing: 0) {
            // Map Section
            mapSection
                .frame(maxWidth: .infinity)
            
            // Trainers List Section
            trainersList
                .frame(maxWidth: .infinity)
        }
    }
    
    var mapSection: some View {
        ZStack {
            // Background gradient to simulate map
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.green.opacity(0.2),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Map placeholder content
            VStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow.opacity(0.6))
                
                Text("Interactive Map")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Location-based trainer search")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .opacity(0.4)
            
            // Trainer pins
            ForEach(Array(trainers.enumerated()), id: \.element.id) { index, trainer in
                TrainerPin(
                    trainer: trainer,
                    index: index,
                    isSelected: selectedTrainer?.id == trainer.id,
                    position: viewModel.getPinPosition(for: index)
                ) {
                    selectedTrainer = trainer
                    onSelectTrainer(trainer)
                }
            }
            
            // Map controls
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        mapControlButton("+") { viewModel.zoomIn() }
                        mapControlButton("-") { viewModel.zoomOut() }
                        mapControlButton("⊙") { viewModel.recenter() }
                    }
                }
                Spacer()
            }
            .padding(16)
            
            // User location indicator
            VStack {
                Spacer()
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .scaleEffect(viewModel.isUserLocationPulsing ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: viewModel.isUserLocationPulsing
                        )
                    Spacer()
                }
                .padding(.bottom, 16)
                .padding(.leading, 16)
            }
        }
        .padding(.leading, 20)
        .onAppear {
            viewModel.startLocationPulsing()
        }
    }
    
    func mapControlButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(8)
        }
    }
    
    var trainersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(trainers.enumerated()), id: \.element.id) { index, trainer in
                    TrainerMapCard(
                        trainer: trainer,
                        index: index,
                        isSelected: selectedTrainer?.id == trainer.id,
                        distance: viewModel.getDistanceString(for: trainer)
                    ) {
                        selectedTrainer = trainer
                        onSelectTrainer(trainer)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - TrainerPin
struct TrainerPin: View {
    let trainer: Trainer
    let index: Int
    let isSelected: Bool
    let position: CGPoint
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.yellow : Color.yellow.opacity(0.8))
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text("\(index + 1)")
                    .font(.system(size: isSelected ? 16 : 14, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .position(position)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - TrainerMapCard
struct TrainerMapCard: View {
    let trainer: Trainer
    let index: Int
    let isSelected: Bool
    let distance: String
    let onTap: () -> Void
    
    private var specialty: TrainerSpecialty {
        TrainerSpecialty(rawValue: trainer.specialty) ?? .weightLoss
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Pin number
                    Circle()
                        .fill(isSelected ? Color.yellow : Color.yellow.opacity(0.8))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        )
                    
                    // Trainer info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(trainer.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            if trainer.isVerified {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        
                        Text(trainer.location.address)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        HStack {
                            // Rating
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", trainer.rating))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            // Online status
                            if trainer.isOnline {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                    Text("Online")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    // Price and specialty
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(trainer.pricePerSession)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text(specialty.displayName)
                            .font(.system(size: 10))
                            .foregroundColor(specialty.color)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Distance
                HStack {
                    Spacer()
                    Text(distance)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
struct TrainersMapsView_Previews: PreviewProvider {
    static var previews: some View {
        TrainersMapsView(
            trainers: TrainerData.sampleTrainers,
            onSelectTrainer: { _ in }
        )
        .preferredColorScheme(.dark)
    }
}
