import SwiftUI
import MapKit

struct TrainersMapsView: View {
    let trainers: [Trainer]
    let onSelectTrainer: (Trainer) -> Void
    @Binding var favoritedTrainers: Set<UUID>
    var toggleFavorite: ((Trainer) -> Void)? = nil
    var isFavorited: ((Trainer) -> Bool)? = nil
    
    @StateObject private var viewModel = TrainersMapsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrainer: Trainer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                mapContent
            }
            .background(Color.clear)
            .onAppear {
                viewModel.setTrainers(trainers)
                viewModel.onAppearMap() // Centrar en la ubicación del usuario al entrar
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - View Components
private extension TrainersMapsView {
    var headerSection: some View {
        HStack {
            VStack(alignment: .center, spacing: 4) {
                Text("Trainers Near You")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Found \(trainers.count) trainer\(trainers.count != 1 ? "s" : "") nearby")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appYellow)
    }
    
    var mapContent: some View {
        ZStack {
            mapSection
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedTrainer != nil {
                        selectedTrainer = nil
                    }
                }
            if let trainer = selectedTrainer {
                VStack {
                    Spacer()
                    ZStack {
                        TrainerCard(
                            trainer: trainer,
                            isFavorited: isFavorited?(trainer) ?? favoritedTrainers.contains(trainer.id),
                            onTap: {}, // No hace nada aquí
                            onFavorite: {
                                if let toggle = toggleFavorite {
                                    toggle(trainer)
                                } else {
                                    if favoritedTrainers.contains(trainer.id) {
                                        favoritedTrainers.remove(trainer.id)
                                    } else {
                                        favoritedTrainers.insert(trainer.id)
                                    }
                                }
                            }
                        )
                        .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 400))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 16)
                        .highPriorityGesture(TapGesture().onEnded {
                            onSelectTrainer(trainer)
                        })
                        .overlay(
                            HStack {
                                Spacer()
                                VStack {
                                    Button(action: { selectedTrainer = nil }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.gray.opacity(0.8))
                                            .padding(10)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.top, -2)
                            .padding(.trailing, -2)
                        )
                    }
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }
                .background(
                    Color.black.opacity(0.001)
                        .onTapGesture { selectedTrainer = nil }
                )
            }
        }
    }
    
    var mapSection: some View {
        ZStack {
            // Mapa real con pines de entrenadores
            Map(coordinateRegion: $viewModel.region, annotationItems: trainers) { trainer in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: trainer.location.latitude, longitude: trainer.location.longitude)) {
                    Button(action: {
                        selectedTrainer = trainer
                        // NO llamar onSelectTrainer aquí
                    }) {
                        VStack(spacing: 0) {
                            Image(systemName: selectedTrainer?.id == trainer.id ? "mappin.circle.fill" : "mappin.circle")
                                .font(.system(size: selectedTrainer?.id == trainer.id ? 36 : 28))
                                .foregroundColor(selectedTrainer?.id == trainer.id ? .yellow : .appYellow)
                        }
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        selectedTrainer = trainer
                    })
                }
            }
            // ... controles y overlays existentes ...
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        mapControlButton("+") { viewModel.zoomIn() }
                        mapControlButton("-") { viewModel.zoomOut() }
                        mapControlButton("⊙") { viewModel.centerMapOnUserLocation() }
                    }
                }
                Spacer()
            }
            .padding(16)
            .zIndex(4)
            // ... user location indicator ...
        }
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
        .highPriorityGesture(TapGesture().onEnded {
            action()
        })
        .allowsHitTesting(true)
        .zIndex(5)
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
            onSelectTrainer: { _ in },
            favoritedTrainers: .constant([])
        )
        .preferredColorScheme(.dark)
    }
}
