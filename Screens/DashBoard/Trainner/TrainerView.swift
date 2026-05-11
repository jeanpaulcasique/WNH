import SwiftUI

struct FitnessTrainerApp: View {
    @StateObject private var viewModel = FitnessTrainerViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: TrainerCategory = .all
    @State private var selectedTrainer: Trainer?
    @State private var activeSheet: ActiveSheet?
    @State private var isDataReady = false
    @State private var showMap = false // Nuevo estado para toggle
    
    enum ActiveSheet: Identifiable {
        case detail(Trainer)
        case chat(Trainer)
        case map
        var id: String {
            switch self {
            case .detail(let t): return "detail-\(t.id)"
            case .chat(let t): return "chat-\(t.id)"
            case .map: return "map"
            }
        }
    }
    
    var filteredTrainers: [Trainer] {
        viewModel.getFilteredTrainers(searchText: searchText, category: selectedCategory)
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                headerSection
                searchAndFilterSection
                if showMap {
                    TrainersMapsView(
                        trainers: filteredTrainers,
                        onSelectTrainer: { trainer in
                            selectedTrainer = trainer
                            activeSheet = .detail(trainer)
                        },
                        favoritedTrainers: $viewModel.favorites,
                        toggleFavorite: { viewModel.toggleFavorite(for: $0) },
                        isFavorited: { viewModel.isFavorited($0) }
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    trainersList
                        .transition(.move(edge: .leading))
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .detail(let trainer):
                TrainerDetailView(trainer: trainer) { trainer in
                    selectedTrainer = trainer
                    // Espera antes de mostrar el chat para evitar conflicto de sheets
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        activeSheet = .chat(trainer)
                    }
                }
            case .chat(let trainer):
                TrainerChatView(trainer: trainer)
            case .map:
                TrainersMapsView(
                    trainers: filteredTrainers,
                    onSelectTrainer: { trainer in
                        selectedTrainer = trainer
                        activeSheet = .detail(trainer)
                    },
                    favoritedTrainers: $viewModel.favorites,
                    toggleFavorite: { viewModel.toggleFavorite(for: $0) },
                    isFavorited: { viewModel.isFavorited($0) }
                )
            }
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
                Image(systemName: "person.2.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("Trainers")
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
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search trainers by name, specialty, or location...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                )
                Spacer()
                Button(action: { showMap.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: showMap ? "list.bullet" : "map")
                            .font(.system(size: 18, weight: .bold))
                        Text(showMap ? LanguageManager.localizedString("List") : LanguageManager.localizedString("Map"))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appYellow)
                    )
                    .foregroundColor(.black)
                    .shadow(color: Color.appYellow.opacity(0.18), radius: 6, x: 0, y: 2)
                }
                .padding(.leading, 10)
            }
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
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
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
                            isFavorited: viewModel.isFavorited(trainer),
                            onTap: {
                                guard isDataReady else { return }
                                selectedTrainer = trainer
                                activeSheet = .detail(trainer)
                            },
                            onFavorite: {
                                viewModel.toggleFavorite(for: trainer)
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
                            .fill(Color.gray.opacity(0.18))
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
                            Text("\(trainer.experience)y \(LanguageManager.localizedString("exp"))")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("$\(trainer.pricePerSession)/\(LanguageManager.localizedString("session"))")
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
                        Text(LanguageManager.localizedString(trainer.bio))
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                isSelected ? Color.appYellow : Color.white.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}


#if DEBUG
struct FitnessTrainerApp_Previews: PreviewProvider {
    static var previews: some View {
        FitnessTrainerApp()
            .preferredColorScheme(.dark)
    }
}
#endif
