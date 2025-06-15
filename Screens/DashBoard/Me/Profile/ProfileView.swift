import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditSheet = false
    @State private var editingItem: ProfileItem?
    @State private var showStatsDetail = false
    
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
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
                if item.text == "Gender" {
                    ProfileGenderSelectionView(currentGender: item.value) { newGender in
                        viewModel.updateItem(item, newValue: newGender)
                    }
                } else {
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
                    .background(Color.appYellow.opacity(0.2))
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
                .foregroundColor(color)
            
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
                    .foregroundColor(item.iconColor)
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
                    .stroke(Color.appYellow, lineWidth: 1.5)
            )
            .shadow(color: Color.appYellow.opacity(0.3), radius: 4, x: 0, y: 2)
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
                .stroke(Color.appYellow, lineWidth: 1.5)
        )
        .shadow(color: Color.appYellow.opacity(0.3), radius: 6, x: 0, y: 3)
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
                .stroke(Color.appYellow, lineWidth: 1.5)
        )
        .shadow(color: Color.appYellow.opacity(0.3), radius: 6, x: 0, y: 3)
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
                .foregroundColor(color)
            
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
                Color.appBlack.ignoresSafeArea()
                
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
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(27)
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.appYellow)
                        
                        Text("Select Gender")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.appWhite)
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
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        onSave(selectedGender)
                        dismiss()
                    }) {
                        Text("Save Selection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.appYellow)
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(selectedGender.isEmpty)
                    .opacity(selectedGender.isEmpty ? 0.6 : 1.0)
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
            }
        }
        .preferredColorScheme(.dark)
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
                    .foregroundColor(isSelected ? .appYellow : .appWhite.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appYellow : .appWhite)
            }
            .frame(width: 120, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appYellow.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.appYellow : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? Color.appYellow.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
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
