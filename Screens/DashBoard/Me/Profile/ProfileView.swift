import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditSheet = false
    @State private var editingItem: ProfileItem?
    @State private var showStatsDetail = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    personalInfoSection
                    fitnessGoalsSection
                    preferencesSection
                    achievementsSection
                }
                .padding(.bottom, 100)
            }
        }
        .confirmationDialog("Choose Photo Source", isPresented: $viewModel.showPhotoOptions, titleVisibility: .visible) {
            Button("Camera") {
                viewModel.sourceType = .camera
                viewModel.showImagePicker = true
            }
            Button("Photo Library") {
                viewModel.sourceType = .photoLibrary
                viewModel.showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $viewModel.showImagePicker) {
            ImagePicker(sourceType: viewModel.sourceType, selectedImage: $viewModel.profileImage)
        }
        .sheet(isPresented: $showEditSheet) {
            if let item = editingItem {
                switch item.text {
                case "Gender":
                    ProfileGenderSelectionView(currentGender: item.value) { newGender in
                        viewModel.updateItem(item, newValue: newGender)
                    }
                case "Birth Year":
                    ProfileBirthYearSelectionView(currentBirthYear: item.value) { newBirthYear in
                        viewModel.updateItem(item, newValue: newBirthYear)
                    }
                case "Height":
                    ProfileHeightSelectionView(currentHeight: item.value) { newHeight in
                        viewModel.updateItem(item, newValue: newHeight)
                    }
                case "Current Weight":
                    ProfileCurrentWeightSelectionView(currentWeight: item.value) { newWeight in
                        viewModel.updateItem(item, newValue: newWeight)
                    }
                case "Target Weight":
                    ProfileTargetWeightSelectionView(currentTargetWeight: item.value) { newTargetWeight in
                        viewModel.updateItem(item, newValue: newTargetWeight)
                    }
                case "Primary Goal":
                    ProfileGoalSelectionView(currentGoal: item.value) { newGoal in
                        viewModel.updateItem(item, newValue: newGoal)
                    }
                case "Workout Level":
                    ProfileWorkoutLevelSelectionView(currentLevel: item.value) { newLevel in
                        viewModel.updateItem(item, newValue: newLevel)
                    }
                case "Activity Level":
                    ProfileActivityLevelSelectionView(currentLevel: item.value) { newLevel in
                        viewModel.updateItem(item, newValue: newLevel)
                    }
                default:
                    EditFieldView(item: item) { newValue in
                        viewModel.updateItem(item, newValue: newValue)
                    }
                }
            }
        }
        .sheet(isPresented: $showStatsDetail) {
            DetailedStatsView(viewModel: viewModel)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.appYellow)
                }
            }
        }

    }
}

// MARK: - Subviews
private extension ProfileView {
    
    var headerSection: some View {
        VStack(spacing: 20) {

            
            // Profile photo with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Button(action: {
                    viewModel.showPhotoOptions = true
                }) {
                    ZStack {
                        if let image = viewModel.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.appYellow, lineWidth: 3)
                                )
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.appYellow)
                                        
                                        Text("Add Photo")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.appWhite.opacity(0.7))
                                    }
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.appYellow.opacity(0.5), lineWidth: 2)
                                )
                        }
                        
                        // Edit overlay
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(Color.appYellow)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                    )
                                    .offset(x: -8, y: -8)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                }
                .shadow(color: Color.appYellow.opacity(0.3), radius: 20, x: 0, y: 10)
            }
            
            VStack(spacing: 8) {
                Text(viewModel.userName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(viewModel.userLevel)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appYellow)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                Text("Member since \(viewModel.memberSince)")
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .padding(.bottom, 30)
    }
    
    var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                Button("View Details") {
                    showStatsDetail = true
                }
                .font(.system(size: 14))
                .foregroundColor(.appYellow)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    title: "Workouts",
                    value: "\(viewModel.totalWorkouts)",
                    subtitle: "completed",
                    color: .red
                )
                
                StatCard(
                    icon: "calendar",
                    title: "Streak",
                    value: "\(viewModel.currentStreak)",
                    subtitle: "days",
                    color: .orange
                )
                
                StatCard(
                    icon: "target",
                    title: "Goals",
                    value: "\(viewModel.achievedGoals)",
                    subtitle: "achieved",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
    
    var personalInfoSection: some View {
        VStack(spacing: 16) {
            ProfileSectionHeader(
                title: "Personal Information",
                icon: "person.circle.fill"
            )
            
            VStack(spacing: 8) {
                let personalItems = viewModel.getPersonalInfoItems()
                ForEach(personalItems, id: \.id) { item in
                    ProfileInfoRow(item: item) {
                        editingItem = item
                        showEditSheet = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
    
    var fitnessGoalsSection: some View {
        VStack(spacing: 16) {
            ProfileSectionHeader(
                title: "Fitness Goals",
                icon: "target"
            )
            
            VStack(spacing: 8) {
                let goalItems = viewModel.getFitnessGoalItems()
                ForEach(goalItems, id: \.id) { item in
                    ProfileInfoRow(item: item) {
                        editingItem = item
                        showEditSheet = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
    
    var preferencesSection: some View {
        VStack(spacing: 16) {
            ProfileSectionHeader(
                title: "Preferences",
                icon: "slider.horizontal.3"
            )
            
            VStack(spacing: 8) {
                let preferenceItems = viewModel.getPreferenceItems()
                ForEach(preferenceItems, id: \.id) { item in
                    ProfileInfoRow(item: item) {
                        editingItem = item
                        showEditSheet = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 30)
    }
    
    var achievementsSection: some View {
        VStack(spacing: 16) {
            ProfileSectionHeader(
                title: "Recent Achievements",
                icon: "trophy.fill"
            )
            
            if viewModel.recentAchievements.isEmpty {
                EmptyAchievementsView()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentAchievements, id: \.id) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views
struct ProfileSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.appYellow)
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.appYellow)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProfileInfoRow: View {
    let item: ProfileItem
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 16) {
                Image(systemName: item.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color.appYellow)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.text)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appWhite)
                    
                    Text(item.value)
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.appYellow.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AchievementCard: View {
    let achievement: ProfileAchievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(achievement.color)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite)
                    .multilineTextAlignment(.center)
                
                Text(achievement.date, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 48))
                .foregroundColor(.appYellow.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Achievements Yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text("Complete workouts and reach goals to earn achievements!")
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(30)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Detailed Stats View
struct DetailedStatsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Weekly progress chart placeholder
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weekly Progress")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.appYellow)
                            
                            // This would be a real chart in production
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 200)
                                .overlay(
                                    Text("Progress Chart\n(Coming Soon)")
                                        .font(.system(size: 16))
                                        .foregroundColor(.appWhite.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                )
                        }
                        
                        // Detailed stats grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            DetailedStatCard(title: "Total Distance", value: "125.4 km", icon: "location", color: .blue)
                            DetailedStatCard(title: "Calories Burned", value: "12,540", icon: "flame", color: .red)
                            DetailedStatCard(title: "Average Duration", value: "45 min", icon: "clock", color: .green)
                            DetailedStatCard(title: "Personal Records", value: "8", icon: "medal", color: .purple)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Detailed Stats")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.appYellow))
        }
        .preferredColorScheme(.dark)
    }
}

struct DetailedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.appYellow)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.appWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Enhanced Edit Field View
struct EditFieldView: View {
    var item: ProfileItem
    var onSave: (String) -> Void
    
    @State private var newValue: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo negro con gradiente
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Field info
                    VStack(spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                        
                        Text("Edit \(item.text)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                    }
                    .padding(.top, 40)
                    
                    // Input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.text)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appYellow)
                        
                        TextField("Enter new value", text: $newValue)
                            .font(.system(size: 18))
                            .foregroundColor(.appWhite)
                            .padding(16)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(newValue)
                        dismiss()
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appWhite)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                newValue = item.value
                isTextFieldFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Profile Gender Selection View
struct ProfileGenderSelectionView: View {
    let currentGender: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGender: String = ""
    @State private var headerOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOffset: CGFloat = 20
    @State private var optionsOpacity: Double = 0
    @State private var optionsOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                            .opacity(headerOpacity)
                            .scaleEffect(headerScale)
                        
                        Text("Select Gender")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                    }
                    .padding(.top, 40)
                    
                    // Gender options (solo 2 como en tu pantalla original)
                    HStack(spacing: 40) {
                        // Male option
                        ProfileGenderOptionCard(
                            title: "Male",
                            icon: "figure.stand",
                            isSelected: selectedGender == "Male"
                        ) {
                            selectedGender = "Male"
                        }
                        
                        // Female option
                        ProfileGenderOptionCard(
                            title: "Female",
                            icon: "figure.stand.dress",
                            isSelected: selectedGender == "Female"
                        ) {
                            selectedGender = "Female"
                        }
                    }
                    .opacity(optionsOpacity)
                    .offset(y: optionsOffset)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(selectedGender)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedGender.isEmpty)
                    .opacity(selectedGender.isEmpty ? 0.6 : 1.0)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                selectedGender = currentGender == "Not Set" ? "" : currentGender
                startStaggeredAnimation()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Staggered Animation
    private func startStaggeredAnimation() {
        // Reset states
        headerOpacity = 0
        headerScale = 0.8
        headerOffset = 20
        optionsOpacity = 0
        optionsOffset = 30
        buttonOpacity = 0
        buttonOffset = 30
        
        // Header Animation (0.0s delay)
        withAnimation(.easeOut(duration: 0.8)) {
            headerOpacity = 1.0
            headerScale = 1.0
            headerOffset = 0
        }
        
        // Options Animation (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                optionsOpacity = 1.0
                optionsOffset = 0
            }
        }
        
        // Button Animation (0.6s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}

// MARK: - Profile Birth Year Selection View
struct ProfileBirthYearSelectionView: View {
    let currentBirthYear: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int = 17 // Default a edad 33 (33 - 16 = 17)
    @State private var headerOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOffset: CGFloat = 20
    @State private var pickerOpacity: Double = 0
    @State private var pickerScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    
    // Configuración visual
    private let minAge = 16
    private let maxAge = 80
    private let itemHeight: CGFloat = 60
    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    private var ageRange: [Int] { Array(minAge...maxAge) }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                            .opacity(headerOpacity)
                            .scaleEffect(headerScale)
                        
                        Text("Select Birth Year")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Picker visual con 5 elementos (2 arriba, 1 centro, 2 abajo)
                    ZStack {
                        // Líneas amarillas de selección
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.appYellow)
                                .frame(width: 120, height: 4)
                            Spacer().frame(height: itemHeight - 6)
                            Rectangle()
                                .fill(Color.appYellow)
                                .frame(width: 120, height: 4)
                            Spacer()
                        }
                        .frame(height: itemHeight * 5)
                        .opacity(pickerOpacity)
                        .scaleEffect(pickerScale)

                        // Scroll Picker funcional
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 0) {
                                    // Top padding para centrar
                                    Color.clear.frame(height: itemHeight * 2)
                                    
                                    // Age items
                                    ForEach(Array(ageRange.enumerated()), id: \.offset) { index, age in
                                        let distance = index - selectedIndex
                                        Text("\(age)")
                                            .font(.system(size: fontSizeForDistance(distance) + 16, weight: fontWeightForDistance(distance)))
                                            .foregroundColor(colorForDistance(distance))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: itemHeight)
                                            .scaleEffect(scaleForDistance(distance))
                                            .opacity(opacityForDistance(distance))
                                            .id(index)
                                    }
                                    
                                    // Bottom padding para centrar
                                    Color.clear.frame(height: itemHeight * 2)
                                }
                            }
                            .frame(height: itemHeight * 5)
                            .onAppear {
                                // Scroll to selected index - más suave y lento
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 1.2)) {
                                        proxy.scrollTo(selectedIndex, anchor: .center)
                                    }
                                }
                            }
                            .onChange(of: selectedIndex) { oldValue, newIndex in
                                // Scroll to new index - más suave
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    proxy.scrollTo(newIndex, anchor: .center)
                                }
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }
                            .simultaneousGesture(
                                DragGesture()
                                    .onEnded { value in
                                        handleDragEnd(value)
                                    }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        let age = ageRange[selectedIndex]
                        let birthYear = "\(currentYear - age)"
                        onSave(birthYear)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedIndex < 0 || selectedIndex >= ageRange.count)
                    .opacity(selectedIndex < 0 || selectedIndex >= ageRange.count ? 0.6 : 1.0)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                loadCurrentBirthYear()
                startStaggeredAnimation()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadCurrentBirthYear() {
        if let birthYear = Int(currentBirthYear), birthYear > 1900 {
            let age = currentYear - birthYear
            if age >= minAge && age <= maxAge {
                selectedIndex = age - minAge
            }
        }
    }
    
    // MARK: - Visual Effects Functions
    private func fontSizeForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 44      // Elemento central
        case 1: return 32      // Elementos adyacentes
        case 2: return 26      // Elementos extremos
        default: return 20     // Elementos fuera del rango visible
        }
    }
    
    private func fontWeightForDistance(_ distance: Int) -> Font.Weight {
        switch abs(distance) {
        case 0: return .bold
        case 1: return .semibold
        case 2: return .medium
        default: return .regular
        }
    }
    
    private func colorForDistance(_ distance: Int) -> Color {
        switch abs(distance) {
        case 0: return .appWhite
        case 1: return Color.appWhite.opacity(0.7)
        case 2: return Color.appWhite.opacity(0.4)
        default: return Color.appWhite.opacity(0.2)
        }
    }
    
    private func scaleForDistance(_ distance: Int) -> CGFloat {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.9
        case 2: return 0.8
        default: return 0.7
        }
    }
    
    private func opacityForDistance(_ distance: Int) -> Double {
        switch abs(distance) {
        case 0: return 1.0
        case 1: return 0.8
        case 2: return 0.5
        default: return 0.3
        }
    }
    
    // MARK: - Drag Handling
    private func handleDragEnd(_ value: DragGesture.Value) {
        // Calcular el índice basado en el scroll
        let scrollOffset = value.translation.height
        let itemOffset = scrollOffset / itemHeight
        let newIndex = selectedIndex - Int(round(itemOffset))
        
        // Asegurar que esté dentro del rango
        let clampedIndex = max(0, min(newIndex, ageRange.count - 1))
        
        if clampedIndex != selectedIndex {
            selectedIndex = clampedIndex
        }
    }
    
    // MARK: - Staggered Animation
    private func startStaggeredAnimation() {
        // Reset states
        headerOpacity = 0
        headerScale = 0.8
        headerOffset = 20
        pickerOpacity = 0
        pickerScale = 0.9
        buttonOpacity = 0
        buttonOffset = 30
        
        // Header Animation (0.0s delay)
        withAnimation(.easeOut(duration: 0.8)) {
            headerOpacity = 1.0
            headerScale = 1.0
            headerOffset = 0
        }
        
        // Picker Animation (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                pickerOpacity = 1.0
                pickerScale = 1.0
            }
        }
        
        // Button Animation (0.6s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}

struct ProfileGenderOptionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(Color.appYellow)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appYellow : .appWhite)
            }
            .frame(width: 120, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.appYellow : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Current Weight Selection View
struct ProfileCurrentWeightSelectionView: View {
    let currentWeight: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int = 40 // Default a 50kg (50 - 30 = 20)
    @State private var dragOffset: CGFloat = 0
    @State private var headerOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOffset: CGFloat = 20
    @State private var pickerOpacity: Double = 0
    @State private var pickerScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    
    // Configuración visual
    private let minWeight = 30 // 30kg
    private let maxWeight = 200 // 200kg
    private let itemWidth: CGFloat = 8 // Ancho de cada tick en la cinta
    private let conversionFactor: Double = 2.20462
    private var weightRange: [Double] { stride(from: Double(minWeight), through: Double(maxWeight), by: 0.5).map { $0 } }
    @State private var isKgSelected: Bool = true
    @State private var selectedWeightKg: Double = 50.0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "scalemass")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                            .opacity(headerOpacity)
                            .scaleEffect(headerScale)
                        
                        Text("Select Current Weight")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Valor grande y cinta métrica horizontal
                    VStack(spacing: 0) {
                        // Valor de peso
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Spacer()
                            Text(isKgSelected ? "\(selectedWeightKg, specifier: "%.1f")" : "\(selectedWeightKg * 2.20462, specifier: "%.1f")")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.appWhite)
                            Text(isKgSelected ? "kg" : "lb")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.appYellow)
                                .offset(y: -10)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 4)

                        // Selector de unidad
                        HStack(spacing: 12) {
                            Button(action: { isKgSelected = true }) {
                                Text("kg")
                                    .fontWeight(.bold)
                                    .foregroundColor(isKgSelected ? .appBlack : .appWhite.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(isKgSelected ? Color.appYellow : Color.clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.appWhite.opacity(isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                    )
                            }
                            Button(action: { isKgSelected = false }) {
                                Text("lb")
                                    .fontWeight(.bold)
                                    .foregroundColor(!isKgSelected ? .appBlack : .appWhite.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(!isKgSelected ? Color.appYellow : Color.clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.appWhite.opacity(!isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        ZStack {
                            // Cinta métrica horizontal con DragGesture y snapping
                            GeometryReader { geometry in
                                let totalWidth = CGFloat(weightRange.count) * itemWidth
                                let centerX = geometry.size.width / 2
                                
                                HStack(spacing: 0) {
                                    ForEach(Array(weightRange.enumerated()), id: \.offset) { index, weight in
                                        VStack(spacing: 4) {
                                            Rectangle()
                                                .fill(index == selectedIndex ? Color.appYellow : Color.appWhite.opacity(0.4))
                                                .frame(width: 2, height: weight.truncatingRemainder(dividingBy: 5) == 0 ? 30 : 20)
                                            Spacer().frame(height: 12)
                                        }
                                        .frame(width: itemWidth, height: 60)
                                    }
                                }
                                .frame(width: totalWidth, alignment: .leading)
                                .offset(x: centerX - CGFloat(selectedIndex) * itemWidth + dragOffset)
                            }
                            .frame(height: 80)
                            .padding(.horizontal, 0)
                            
                            // Línea central destacada
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.appYellow, Color.appYellow.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 4, height: 70)
                                .cornerRadius(2)
                                .shadow(color: Color.appYellow.opacity(0.5), radius: 8, x: 0, y: 0)
                        }
                    }
                    .opacity(pickerOpacity)
                    .scaleEffect(pickerScale)
                    .padding(.horizontal, 20)
                    .onChange(of: selectedIndex) { oldValue, newIndex in
                        let weight = weightRange[newIndex]
                        selectedWeightKg = weight
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        let weightString = String(format: "%.1f %@", selectedWeightKg, isKgSelected ? "kg" : "lb")
                        onSave(weightString)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                loadCurrentWeight()
                startStaggeredAnimation()
            }
            // DragGesture en toda la pantalla
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Actualizar el offset visual para feedback inmediato
                        dragOffset = value.translation.width
                        
                        // Calcular nuevo índice basado en el drag horizontal
                        let itemsToMove = -value.translation.width / itemWidth
                        let newIndex = selectedIndex + Int(round(itemsToMove))
                        let clampedIndex = max(0, min(newIndex, weightRange.count - 1))
                        
                        // Actualizar el peso mostrado en tiempo real
                        selectedWeightKg = weightRange[clampedIndex]
                    }
                    .onEnded { value in
                        // Calcular nuevo índice final basado en el drag
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        let adjustedOffset = value.translation.width + velocity * 0.1
                        
                        let itemsToMove = -adjustedOffset / itemWidth
                        let newIndex = selectedIndex + Int(round(itemsToMove))
                        let clampedIndex = max(0, min(newIndex, weightRange.count - 1))
                        
                        // Animar al nuevo índice y resetear el offset
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedIndex = clampedIndex
                            selectedWeightKg = weightRange[clampedIndex]
                            dragOffset = 0
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadCurrentWeight() {
        if currentWeight.contains("kg") {
            let weightStr = currentWeight.replacingOccurrences(of: " kg", with: "")
            if let weight = Double(weightStr) {
                selectedWeightKg = weight
                isKgSelected = true
                // Calcular el índice basado en el peso
                if let index = weightRange.firstIndex(of: weight) {
                    selectedIndex = index
                }
            }
        } else if currentWeight.contains("lb") {
            let weightStr = currentWeight.replacingOccurrences(of: " lb", with: "")
            if let weight = Double(weightStr) {
                let weightKg = weight / conversionFactor
                selectedWeightKg = weightKg
                isKgSelected = false
                // Calcular el índice basado en el peso en kg
                if let index = weightRange.firstIndex(of: weightKg) {
                    selectedIndex = index
                }
            }
        }
    }
    
    // MARK: - Staggered Animation
    private func startStaggeredAnimation() {
        // Reset states
        headerOpacity = 0
        headerScale = 0.8
        headerOffset = 20
        pickerOpacity = 0
        pickerScale = 0.9
        buttonOpacity = 0
        buttonOffset = 30
        
        // Header Animation (0.0s delay)
        withAnimation(.easeOut(duration: 0.8)) {
            headerOpacity = 1.0
            headerScale = 1.0
            headerOffset = 0
        }
        
        // Picker Animation (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                pickerOpacity = 1.0
                pickerScale = 1.0
            }
        }
        
        // Button Animation (0.6s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}
// MARK: - Profile Target Weight Selection View
                struct ProfileTargetWeightSelectionView: View {
                    let currentTargetWeight: String
                    let onSave: (String) -> Void
                    @Environment(\.dismiss) private var dismiss
                    @State private var selectedIndex: Int = 40 // Default a 50kg (50 - 30 = 20)
                    @State private var dragOffset: CGFloat = 0
                    @State private var isDragging: Bool = false
                    @State private var dragStartIndex: Int? = nil
                    @State private var visualIndex: Int = 40
                    
                    // Staggered Animation States
                    @State private var headerOpacity: Double = 0
                    @State private var headerScale: CGFloat = 0.8
                    @State private var headerOffset: CGFloat = 20
                    @State private var weightDisplayOpacity: Double = 0
                    @State private var weightDisplayOffset: CGFloat = 30
                    @State private var unitToggleOpacity: Double = 0
                    @State private var unitToggleOffset: CGFloat = 30
                    @State private var tapeOpacity: Double = 0
                    @State private var tapeOffset: CGFloat = 30
                    @State private var buttonOpacity: Double = 0
                    @State private var buttonOffset: CGFloat = 30
                    
                    // Configuración visual
                    private let minWeight = 30 // 30kg
                    private let maxWeight = 200 // 200kg
                    private let itemWidth: CGFloat = 8 // Ancho de cada tick en la cinta
                    private let conversionFactor: Double = 2.20462
                    private var weightRange: [Double] { stride(from: Double(minWeight), through: Double(maxWeight), by: 0.5).map { $0 } }
                    @State private var isKgSelected: Bool = true
                    @State private var selectedWeightKg: Double = 50.0
    
    // Índice visual temporal para mostrar el valor en tiempo real
    private var currentIndex: Int {
        if isDragging {
            let baseIndex = dragStartIndex ?? selectedIndex
            let offset = -dragOffset / itemWidth
            let idx = Int(round(CGFloat(baseIndex) + offset))
            return max(0, min(idx, weightRange.count - 1))
        } else {
            return selectedIndex
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                                                        // Header
                                    VStack(spacing: 12) {
                                        Image(systemName: "target")
                                            .font(.system(size: 48))
                                            .foregroundColor(.appYellow)
                                            .opacity(headerOpacity)
                                            .scaleEffect(headerScale)
                                            .offset(y: headerOffset)
                                        
                                        Text("Select Target Weight")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.appWhite)
                                            .opacity(headerOpacity)
                                            .offset(y: headerOffset)
                                    }
                                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Valor grande y cinta métrica horizontal
                    VStack(spacing: 0) {
                        // Valor de peso
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Spacer()
                            Text(isKgSelected ? "\(selectedWeightKg, specifier: "%.1f")" : "\(selectedWeightKg * 2.20462, specifier: "%.1f")")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.appWhite)
                            Text(isKgSelected ? "kg" : "lb")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.appYellow)
                                .offset(y: -10)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 4)

                        // Selector de unidad
                        HStack(spacing: 12) {
                            Button(action: { isKgSelected = true }) {
                                Text("kg")
                                    .fontWeight(.bold)
                                    .foregroundColor(isKgSelected ? .appBlack : .appWhite.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(isKgSelected ? Color.appYellow : Color.clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.appWhite.opacity(isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                    )
                            }
                            Button(action: { isKgSelected = false }) {
                                Text("lb")
                                    .fontWeight(.bold)
                                    .foregroundColor(!isKgSelected ? .appBlack : .appWhite.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(!isKgSelected ? Color.appYellow : Color.clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.appWhite.opacity(!isKgSelected ? 0.7 : 0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.bottom, 8)
                        
                        ZStack {
                            // Cinta métrica horizontal con DragGesture y snapping
                            GeometryReader { geometry in
                                let totalWidth = CGFloat(weightRange.count) * itemWidth
                                let centerX = geometry.size.width / 2
                                
                                HStack(spacing: 0) {
                                    ForEach(Array(weightRange.enumerated()), id: \.offset) { index, weight in
                                        VStack(spacing: 4) {
                                            Rectangle()
                                                .fill(index == visualIndex ? Color.appYellow : Color.appWhite.opacity(0.4))
                                                .frame(width: 2, height: index == visualIndex ? 50 : (weight.truncatingRemainder(dividingBy: 5) == 0 ? 30 : 20))
                                            Spacer().frame(height: 12)
                                        }
                                        .frame(width: itemWidth, height: 60)
                                    }
                                }
                                .frame(width: totalWidth, alignment: .leading)
                                .offset(x: centerX - CGFloat(visualIndex) * itemWidth + (isDragging ? dragOffset : 0))
                            }
                            .frame(height: 80)
                            .padding(.horizontal, 0)
                            
                            // Línea central destacada
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.appYellow, Color.appYellow.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 4, height: 70)
                                .cornerRadius(2)
                                .shadow(color: Color.appYellow.opacity(0.5), radius: 8, x: 0, y: 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: selectedIndex) { oldValue, newIndex in
                        let weight = weightRange[newIndex]
                        selectedWeightKg = weight
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        let weightString = String(format: "%.1f %@", selectedWeightKg, isKgSelected ? "kg" : "lb")
                        onSave(weightString)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                loadCurrentTargetWeight()
            }
            // DragGesture en toda la pantalla
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Actualizar el offset visual para feedback inmediato
                        dragOffset = value.translation.width
                        
                        if dragStartIndex == nil {
                            dragStartIndex = selectedIndex
                        }
                        isDragging = true

                        let baseIndex = dragStartIndex ?? selectedIndex
                        let offset = -dragOffset / itemWidth
                        let idx = Int(round(CGFloat(baseIndex) + offset))
                        let clampedIndex = max(0, min(idx, weightRange.count - 1))

                        visualIndex = clampedIndex
                        selectedWeightKg = weightRange[clampedIndex]
                    }
                    .onEnded { value in
                        let baseIndex = dragStartIndex ?? selectedIndex
                        let offset = -value.translation.width / itemWidth
                        let newIndex = Int(round(CGFloat(baseIndex) + offset))
                        let clampedIndex = max(0, min(newIndex, weightRange.count - 1))
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedIndex = clampedIndex
                            visualIndex = clampedIndex
                        }
                        dragOffset = 0
                        dragStartIndex = nil
                        isDragging = false
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadCurrentTargetWeight() {
        if currentTargetWeight.contains("kg") {
            let weightStr = currentTargetWeight.replacingOccurrences(of: " kg", with: "")
            if let weight = Double(weightStr) {
                selectedWeightKg = weight
                isKgSelected = true
                // Calcular el índice basado en el peso
                if let index = weightRange.firstIndex(of: weight) {
                    selectedIndex = index
                    visualIndex = index
                }
            }
        } else if currentTargetWeight.contains("lb") {
            let weightStr = currentTargetWeight.replacingOccurrences(of: " lb", with: "")
            if let weight = Double(weightStr) {
                let weightKg = weight / conversionFactor
                selectedWeightKg = weightKg
                isKgSelected = false
                // Calcular el índice basado en el peso en kg
                if let index = weightRange.firstIndex(of: weightKg) {
                    selectedIndex = index
                    visualIndex = index
                }
            }
        }
    }
}

// MARK: - Profile Height Selection View
struct ProfileHeightSelectionView: View {
    let currentHeight: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int = 50 // Default a 150cm (150 - 100 = 50)
    @State private var scrollPickerDragOffset: CGFloat = 0
    @State private var displayIndex: Int = 50 // Índice temporal para mostrar en vivo
    @State private var headerOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOffset: CGFloat = 20
    @State private var pickerOpacity: Double = 0
    @State private var pickerScale: CGFloat = 0.9
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    
    // Configuración visual
    private let minHeight = 100 // 100cm
    private let maxHeight = 230 // 230cm
    private let itemHeight: CGFloat = 8 // Altura más pequeña para la cinta métrica
    private var heightRange: [Int] { Array(minHeight...maxHeight) }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "ruler")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                            .opacity(headerOpacity)
                            .scaleEffect(headerScale)
                        
                        Text("Select Height")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Contenedor principal con valor y cinta métrica
                    HStack(spacing: 0) {
                        // Lado izquierdo - Valor de altura
                        VStack {
                            Text("\(heightRange[displayIndex])")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.appWhite)
                            Text("cm")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.appYellow)
                                .offset(y: -10)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Lado derecho - Cinta métrica vertical
                        VStack(spacing: 0) {
                            // Cinta métrica con picker personalizado
                            ZStack {
                                // Indicador central (línea blanca)
                                HStack {
                                    Rectangle()
                                        .fill(Color.appWhite)
                                        .frame(width: 60, height: 4)
                                        .cornerRadius(2)
                                    Spacer()
                                }
                                .zIndex(1)
                                
                                // Cinta métrica
                                ProfileHeightTapeView(
                                    items: heightRange,
                                    selectedIndex: $selectedIndex,
                                    itemHeight: itemHeight,
                                    externalDragOffset: scrollPickerDragOffset
                                )
                                .frame(width: 100)
                            }
                            .frame(height: 400)
                        }
                        .frame(width: 100)
                    }
                    
                    .opacity(pickerOpacity)
                    .scaleEffect(pickerScale)
                    .padding(.horizontal, 20)
                    .onChange(of: selectedIndex) { oldValue, newIndex in
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        let heightString = "\(heightRange[selectedIndex]) cm"
                        onSave(heightString)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                loadCurrentHeight()
                displayIndex = selectedIndex // Sincronizar displayIndex
                startStaggeredAnimation()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Aplicar el gesto al picker
                        scrollPickerDragOffset = value.translation.height
                        
                        // Calcular el nuevo índice en tiempo real para mostrar el número
                        let itemsToMove = -value.translation.height / itemHeight
                        let newIndex = selectedIndex + Int(round(itemsToMove))
                        let clampedIndex = max(0, min(newIndex, heightRange.count - 1))
                        
                        // Actualizar displayIndex para mostrar el valor en vivo
                        displayIndex = clampedIndex
                    }
                    .onEnded { value in
                        // Calcular nuevo índice basado en el gesto
                        let velocity = value.predictedEndTranslation.height - value.translation.height
                        let adjustedOffset = value.translation.height + velocity * 0.1
                        
                        let itemsToMove = -adjustedOffset / itemHeight
                        let newIndex = selectedIndex + Int(round(itemsToMove))
                        let clampedIndex = max(0, min(newIndex, heightRange.count - 1))
                        
                        // Animar al nuevo índice y sincronizar displayIndex
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedIndex = clampedIndex
                            displayIndex = clampedIndex
                            scrollPickerDragOffset = 0
                        }
                    }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadCurrentHeight() {
        if currentHeight.contains("cm") {
            let heightStr = currentHeight.replacingOccurrences(of: " cm", with: "")
            if let height = Int(heightStr) {
                if height >= minHeight && height <= maxHeight {
                    selectedIndex = height - minHeight
                    displayIndex = height - minHeight // Sincronizar displayIndex
                }
            }
        }
    }
    
    // MARK: - Staggered Animation
    private func startStaggeredAnimation() {
        // Reset states
        headerOpacity = 0
        headerScale = 0.8
        headerOffset = 20
        pickerOpacity = 0
        pickerScale = 0.9
        buttonOpacity = 0
        buttonOffset = 30
        
        // Header Animation (0.0s delay)
        withAnimation(.easeOut(duration: 0.8)) {
            headerOpacity = 1.0
            headerScale = 1.0
            headerOffset = 0
        }
        
        // Picker Animation (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                pickerOpacity = 1.0
                pickerScale = 1.0
            }
        }
        
        // Button Animation (0.6s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}



// MARK: - Profile Goal Selection View
struct ProfileGoalSelectionView: View {
    let currentGoal: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGoal: String = ""
    @State private var headerOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var headerOffset: CGFloat = 20
    @State private var optionsOpacity: Double = 0
    @State private var optionsOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    
    let goals = ["Lose Weight", "Build Muscle", "Keep Fit"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                            .opacity(headerOpacity)
                            .scaleEffect(headerScale)
                        
                        Text("Select Primary Goal")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                    }
                    .padding(.top, 40)
                    
                    // Goal Options
                    VStack(spacing: 16) {
                        ForEach(goals, id: \.self) { goal in
                            SimpleOptionCard(
                                title: goal,
                                isSelected: selectedGoal == goal
                            ) {
                                selectedGoal = goal
                            }
                        }
                    }
                    .opacity(optionsOpacity)
                    .offset(y: optionsOffset)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(selectedGoal)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedGoal.isEmpty)
                    .opacity(selectedGoal.isEmpty ? 0.6 : 1.0)
                    .opacity(buttonOpacity)
                    .offset(y: buttonOffset)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                selectedGoal = currentGoal == "Not Set" ? "" : currentGoal
                startStaggeredAnimation()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Staggered Animation
    private func startStaggeredAnimation() {
        // Reset states
        headerOpacity = 0
        headerScale = 0.8
        headerOffset = 20
        optionsOpacity = 0
        optionsOffset = 30
        buttonOpacity = 0
        buttonOffset = 30
        
        // Header Animation (0.0s delay)
        withAnimation(.easeOut(duration: 0.8)) {
            headerOpacity = 1.0
            headerScale = 1.0
            headerOffset = 0
        }
        
        // Options Animation (0.3s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.8)) {
                optionsOpacity = 1.0
                optionsOffset = 0
            }
        }
        
        // Button Animation (0.6s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                buttonOpacity = 1.0
                buttonOffset = 0
            }
        }
    }
}

// MARK: - Simple Option Card
struct SimpleOptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appYellow : .appWhite)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.appYellow)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.appYellow : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Workout Level Selection View
struct ProfileWorkoutLevelSelectionView: View {
    let currentLevel: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: String = ""
    
    let workoutLevels = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                        
                        Text("Select Workout Level")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                    }
                    .padding(.top, 40)
                    
                    // Workout Level Options
                    VStack(spacing: 16) {
                        ForEach(workoutLevels, id: \.self) { level in
                            SimpleOptionCard(
                                title: level,
                                isSelected: selectedLevel == level
                            ) {
                                selectedLevel = level
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(selectedLevel)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedLevel.isEmpty)
                    .opacity(selectedLevel.isEmpty ? 0.6 : 1.0)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                selectedLevel = currentLevel == "Not Set" ? "" : currentLevel
            }
        }
        .preferredColorScheme(.dark)
    }
}



// MARK: - Profile Activity Level Selection View
struct ProfileActivityLevelSelectionView: View {
    let currentLevel: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: String = ""
    
    let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Elegant gradient background (same as ProfileView)
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                        
                        Text("Select Activity Level")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
                    }
                    .padding(.top, 40)
                    
                    // Activity Level Options
                    VStack(spacing: 16) {
                        ForEach(activityLevels, id: \.self) { level in
                            SimpleOptionCard(
                                title: level,
                                isSelected: selectedLevel == level
                            ) {
                                selectedLevel = level
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(selectedLevel)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedLevel.isEmpty)
                    .opacity(selectedLevel.isEmpty ? 0.6 : 1.0)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }.foregroundColor(.appYellow)
            )
            .onAppear {
                selectedLevel = currentLevel == "Not Set" ? "" : currentLevel
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Profile Height Tape View (Custom Yellow Version)
struct ProfileHeightTapeView: View {
    let items: [Int]
    @Binding var selectedIndex: Int
    let itemHeight: CGFloat
    let externalDragOffset: CGFloat
    
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let centerY = totalHeight / 2
            let padding = centerY - itemHeight / 2
            
            VStack(spacing: 0) {
                // Top padding
                Color.clear.frame(height: padding)
                
                // Items de la cinta métrica
                ForEach(Array(items.enumerated()), id: \.offset) { index, height in
                    let distance = abs(index - selectedIndex)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // Línea de medición - FORZADA A AMARILLO
                        Rectangle()
                            .fill(Color.appYellow)
                            .frame(width: tapeLineWidth(for: height), height: 2)
                        
                        // Número cada 5cm - FORZADO A AMARILLO
                        if height % 5 == 0 {
                            Text("\(height)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appYellow.opacity(0.8))
                                .frame(width: 30, alignment: .leading)
                                .padding(.leading, 4)
                        } else {
                            Spacer().frame(width: 30)
                        }
                    }
                    .frame(height: itemHeight)
                }
                
                // Bottom padding
                Color.clear.frame(height: padding)
            }
            .offset(y: currentOffset + externalDragOffset)
            .onAppear {
                // Posicionar inicialmente sin animación
                currentOffset = -CGFloat(selectedIndex) * itemHeight
            }
            .onChange(of: selectedIndex) { newIndex in
                // Sincronizar currentOffset cuando selectedIndex cambie externamente
                let targetOffset = -CGFloat(newIndex) * itemHeight
                let offsetDifference = abs(currentOffset - targetOffset)
                
                if offsetDifference > 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentOffset = targetOffset
                    }
                }
            }
        }
        .clipped()
    }
    
    // Función para determinar el ancho de la línea según la altura
    private func tapeLineWidth(for height: Int) -> CGFloat {
        if height % 10 == 0 {
            return 40 // Líneas más largas cada 10cm
        } else if height % 5 == 0 {
            return 30 // Líneas medianas cada 5cm
        } else {
            return 20 // Líneas cortas cada 1cm
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
        .preferredColorScheme(.dark)
    }
}
