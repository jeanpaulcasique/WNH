import SwiftUI

struct FAQView: View {
    @StateObject private var viewModel = FAQViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCategory: FAQCategory = .all
    @State private var expandedItems: Set<UUID> = []
    
    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                searchSection
                categoryFilter
                faqContent
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadFAQs()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Subviews
private extension FAQView {
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.appYellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frequently Asked Questions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appWhite)
                    
                    Text("Find answers to common questions")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .padding(.bottom, 20)
    }
    
    var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appYellow)
                .font(.system(size: 16))
            
            TextField("Search questions...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(.appWhite)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appWhite.opacity(0.6))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FAQCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        count: viewModel.getCountFor(category: category)
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    var faqContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let filteredFAQs = viewModel.getFilteredFAQs(
                    category: selectedCategory,
                    searchText: searchText
                )
                
                if filteredFAQs.isEmpty {
                    EmptyFAQView(searchText: searchText, category: selectedCategory)
                } else {
                    ForEach(filteredFAQs) { faq in
                        FAQCard(
                            faq: faq,
                            isExpanded: expandedItems.contains(faq.id)
                        ) {
                            toggleExpansion(for: faq.id)
                            viewModel.incrementViews(for: faq.id)
                        } onHelpful: {
                            viewModel.markAsHelpful(faq.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Actions
    func toggleExpansion(for id: UUID) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if expandedItems.contains(id) {
                expandedItems.remove(id)
            } else {
                expandedItems.insert(id)
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views
struct QuickStatView: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.appYellow)
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CategoryChip: View {
    let category: FAQCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSelected ? .black : .appYellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.appWhite.opacity(0.3) : Color.appYellow.opacity(0.2))
                        )
                }
            }
            .foregroundColor(isSelected ? .black : .appWhite)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appYellow : Color.gray.opacity(0.2))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FAQCard: View {
    let faq: FAQ
    let isExpanded: Bool
    let onTap: () -> Void
    let onHelpful: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Question header
            Button(action: onTap) {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: faq.category.icon)
                            .font(.system(size: 16))
                            .foregroundColor(faq.category.color)
                            .frame(width: 20)
                        
                        Text(faq.question)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appWhite)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appYellow)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Answer content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(Color.appYellow.opacity(0.3))
                    
                    Text(faq.answer)
                        .font(.system(size: 15))
                        .foregroundColor(.appWhite.opacity(0.9))
                        .lineSpacing(4)
                    
                    if !faq.tags.isEmpty {
                        HStack {
                            Text("Tags:")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.6))
                            
                            ForEach(faq.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 11))
                                    .foregroundColor(.appYellow)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.appYellow.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Action buttons
                    HStack {
                        Button(action: onHelpful) {
                            HStack(spacing: 6) {
                                Image(systemName: faq.isMarkedHelpful ? "heart.fill" : "heart")
                                    .font(.system(size: 14))
                                    .foregroundColor(faq.isMarkedHelpful ? .red : .appWhite.opacity(0.6))
                                
                                Text("Helpful")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.appWhite.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "eye")
                                    .font(.system(size: 11))
                                    .foregroundColor(.appWhite.opacity(0.5))
                                
                                Text("\(faq.viewCount)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.appWhite.opacity(0.5))
                            }
                            
                            Text("Updated \(faq.lastUpdated, style: .date)")
                                .font(.system(size: 11))
                                .foregroundColor(.appWhite.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isExpanded ? Color.appYellow.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct EmptyFAQView: View {
    let searchText: String
    let category: FAQCategory
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.folder")
                .font(.system(size: 64))
                .foregroundColor(.appYellow.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(emptyTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(emptyMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to support or contact
            }) {
                HStack {
                    Image(systemName: "message")
                        .font(.system(size: 14))
                    
                    Text("Contact Support")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.appYellow)
                .cornerRadius(20)
            }
        }
        .padding(40)
    }
    
    private var emptyTitle: String {
        if !searchText.isEmpty {
            return "No Results Found"
        } else {
            return "No FAQs Available"
        }
    }
    
    private var emptyMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or browse different categories."
        } else {
            return "We're working on adding helpful content. In the meantime, feel free to contact support."
        }
    }
}

// MARK: - Preview
struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FAQView()
        }
        .preferredColorScheme(.dark)
    }
}
