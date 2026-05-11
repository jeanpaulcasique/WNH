import SwiftUI

// MARK: - StyledRecipeCard
struct StyledRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 16) {
            // Recipe image
            ZStack {
                if let image = UIImage(named: recipe.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: mealIcon(for: recipe.mealType))
                        .font(.system(size: 24))
                        .foregroundColor(.appYellow)
                }
            }
            
            // Recipe info
            VStack(alignment: .leading, spacing: 4) {
                Text(LanguageManager.localizedString(recipe.title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(recipe.mealType.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(recipe.calories) kcal")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.appYellow)
                    }
                }
            }
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.4))
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func mealIcon(for mealType: MealType) -> String {
        switch mealType {
        case .Breakfast:
            return "sun.rise.fill"
        case .Lunch:
            return "sun.max.fill"
        case .Dinner:
            return "moon.stars.fill"
        }
    }
}

// MARK: - RecipeDetailView
struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showFullScreenImage = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Gradient background matching app style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    headerImageSection
                    recipeInfoSection
                    ingredientsSection
                    instructionsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(LanguageManager.localizedString(recipe.title))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Dismiss the current view
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appYellow)
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageName: recipe.imageName, recipeTitle: LanguageManager.localizedString(recipe.title))
        }
    }
    
    private var headerImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // Recipe image
            if let image = UIImage(named: recipe.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        showFullScreenImage = true
                    }
                    .overlay(
                        // Tap indicator
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appYellow.opacity(0.6), lineWidth: 2)
                            .opacity(0.8)
                    )
            } else {
                // Recipe image placeholder with gradient
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appYellow.opacity(0.6))
                }
            }
            
            // Calories badge
            VStack(spacing: 4) {
                Text("\(recipe.calories)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appBlack)
                
                Text("kcal")
                    .font(.system(size: 12))
                    .foregroundColor(.appBlack.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appYellow)
            .cornerRadius(12)
            .padding()
        }
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LanguageManager.localizedString(recipe.title))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appYellow)
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow)
                    
                    Text(recipe.mealType.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow)
                    
                    Text("~30 min")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.circle.fill")
                    .foregroundColor(.appYellow)
                    .font(.system(size: 20))
                
                Text("Ingredients")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
            }
            
            VStack(spacing: 12) {
                ForEach(recipe.ingredients) { ingredient in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.appYellow.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(LanguageManager.localizedString(ingredient.name))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.appWhite)
                            
                            Text(ingredient.quantity)
                                .font(.system(size: 13))
                                .foregroundColor(.appYellow.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.appYellow)
                    .font(.system(size: 20))
                
                Text("Instructions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
            }
            
            Text(LanguageManager.localizedString(recipe.instructions))
                .font(.system(size: 15))
                .foregroundColor(.appWhite)
                .lineSpacing(6)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - FullScreenImageView
struct FullScreenImageView: View {
    let imageName: String
    let recipeTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageLoadAttempts: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.appBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.appYellow)
                    }
                    
                    Spacer()
                    
                    Text(recipeTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Invisible spacer to maintain centering
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Image
                let image = UIImage(named: imageName)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            // Pinch to zoom
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 4.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .gesture(
                            // Drag to pan
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        let delta = CGSize(
                                            width: value.translation.width - lastOffset.width,
                                            height: value.translation.height - lastOffset.height
                                        )
                                        lastOffset = value.translation
                                        offset = CGSize(
                                            width: offset.width + delta.width,
                                            height: offset.height + delta.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = .zero
                                }
                        )
                        .onTapGesture(count: 2) {
                            // Double tap to reset
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                } else {
                    // Placeholder with reload button when image not found
                    VStack(spacing: 20) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appYellow.opacity(0.6))
                        
                        Text("Image not found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.appWhite.opacity(0.7))
                        
                        if imageLoadAttempts > 0 {
                            Text("Attempts: \(imageLoadAttempts)")
                                .font(.system(size: 14))
                                .foregroundColor(.appWhite.opacity(0.5))
                        }
                        
                        Button(action: {
                            // Try to reload the image
                            imageLoadAttempts += 1
                            // Force view refresh by updating state
                            // This will trigger a re-evaluation of UIImage(named:)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Reload Image")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.appYellow)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.appYellow.opacity(0.15))
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
