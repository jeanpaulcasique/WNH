import SwiftUI

struct FitnessTrainerApp: View {
    @StateObject private var viewModel = FitnessTrainerViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: TrainerCategory = .all
    @State private var selectedTrainer: Trainer?
    @State private var showChat = false
    @State private var showMap = false
    @State private var favorites: Set<UUID> = []
    @State private var isDataReady = false
    
    var filteredTrainers: [Trainer] {
        viewModel.getFilteredTrainers(searchText: searchText, category: selectedCategory)
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerSection
                searchAndFilterSection
                trainersList
            }
        }
        .sheet(item: $selectedTrainer) { trainer in
            TrainerDetailView(trainer: trainer) { trainer in
                // Handle booking
                showChat = true
            }
        }
        .sheet(isPresented: $showChat) {
            if let trainer = selectedTrainer {
                TrainerChatView(trainer: trainer)
            }
        }
        .sheet(isPresented: $showMap) {
            TrainersMapsView(
                trainers: filteredTrainers,
                onSelectTrainer: { trainer in
                    selectedTrainer = trainer
                    showMap = false
                }
            )
        }
        .onAppear {
            print("📱 FitnessTrainerApp onAppear - Cargando entrenadores...")
            viewModel.loadTrainers { [self] in
                DispatchQueue.main.async {
                    self.isDataReady = true
                    print("🎯 Datos listos para selección")
                }
            }
        }
    }
}

// MARK: - View Components
private extension FitnessTrainerApp {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.black, Color.gray.opacity(0.3), Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("FitPro Trainers")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Connect with certified fitness professionals who will help you achieve your health and wellness goals.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search trainers by name, specialty, or location...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                Button(action: { showMap = true }) {
                    Image(systemName: "map")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
            )
            .padding(.horizontal, 20)
            
            // Category Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TrainerCategory.allCases, id: \.self) { category in
                        CategoryTag(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
    }
    
    var trainersList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.isLoading {
                    loadingView
                } else if filteredTrainers.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredTrainers) { trainer in
                        TrainerCard(
                            trainer: trainer,
                            isFavorited: favorites.contains(trainer.id),
                            onTap: {
                                // Verificar que los datos estén listos para selección
                                guard isDataReady else { 
                                    print("⚠️ Datos no listos aún. isDataReady: \(isDataReady)")
                                    return 
                                }
                                print("✅ Seleccionando entrenador: \(trainer.name)")
                                print("📊 Trainer data - Name: \(trainer.name), Specialty: \(trainer.specialty), Rating: \(trainer.rating)")
                                selectedTrainer = trainer
                                print("🎯 selectedTrainer establecido: \(selectedTrainer?.name ?? "nil")")
                            },
                            onFavorite: {
                                if favorites.contains(trainer.id) {
                                    favorites.remove(trainer.id)
                                } else {
                                    favorites.insert(trainer.id)
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            
            Text("Loading trainers...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No trainers found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Try adjusting your search or filters")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.top, 60)
    }
}

// MARK: - TrainerCard
struct TrainerCard: View {
    let trainer: Trainer
    let isFavorited: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    private var specialty: TrainerSpecialty {
        TrainerSpecialty(rawValue: trainer.specialty) ?? .weightLoss
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Profile Image
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [specialty.color, specialty.color.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        
                        if trainer.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .offset(x: 25, y: -25)
                        }
                    }
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(trainer.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            if trainer.isVerified {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(specialty.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(specialty.color)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", trainer.rating))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text("\(trainer.experience)y exp")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("$\(trainer.pricePerSession)/session")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Spacer()
                    
                    // Actions
                    VStack(spacing: 8) {
                        Button(action: onFavorite) {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorited ? .red : .gray)
                        }
                        
                        if trainer.isOnline {
                            Text("ONLINE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(20)
                
                // Bio
                if !trainer.bio.isEmpty {
                    HStack {
                        Text(trainer.bio)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(cardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(specialty.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.1),
                        specialty.color.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - CategoryTag
struct CategoryTag: View {
    let category: TrainerCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .black : .yellow)
                
                Text(category.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.yellow : Color.gray.opacity(0.3))
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - ViewModel
@MainActor
class FitnessTrainerViewModel: ObservableObject {
    @Published var trainers: [Trainer] = []
    @Published var isLoading = false
    
    func loadTrainers() {
        guard trainers.isEmpty else { return }
        print("🔄 Iniciando carga de entrenadores...")
        isLoading = true
        
        // Cargar inmediatamente sin delay
        self.trainers = TrainerData.sampleTrainers
        print("✅ Entrenadores cargados: \(self.trainers.count)")
        self.isLoading = false
        print("🏁 Carga completada. Loading: \(self.isLoading)")
    }
    
    func loadTrainers(completion: @escaping () -> Void) {
        guard trainers.isEmpty else { 
            completion()
            return 
        }
        print("🔄 Iniciando carga de entrenadores...")
        isLoading = true
        
        // Cargar inmediatamente sin delay
        self.trainers = TrainerData.sampleTrainers
        print("✅ Entrenadores cargados: \(self.trainers.count)")
        self.isLoading = false
        print("🏁 Carga completada. Loading: \(self.isLoading)")
        
        // Notificar que los datos están listos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
    func getFilteredTrainers(searchText: String, category: TrainerCategory) -> [Trainer] {
        var filtered = trainers
        
        if !searchText.isEmpty {
            filtered = filtered.filter { trainer in
                trainer.name.localizedCaseInsensitiveContains(searchText) ||
                trainer.bio.localizedCaseInsensitiveContains(searchText) ||
                trainer.location.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if category != .all {
            filtered = filtered.filter { trainer in
                trainer.specialty == category.rawValue
            }
        }
        
        return filtered
    }
}
