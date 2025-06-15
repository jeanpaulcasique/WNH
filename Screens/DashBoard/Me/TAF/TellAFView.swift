import SwiftUI

struct TellAFView: View {
    @StateObject private var viewModel = TellAFViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showShareSheet = false
    @State private var showCopiedAnimation = false
    @State private var showInviteSuccess = false
    @State private var showCodeInfo = false
    @State private var showAllReferrals = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    referralCodeSection
                    rewardsInfoSection
                    progressSection
                    shareOptionsSection
                    friendsListSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Refer Friends")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadReferralData()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetTaF(items: [viewModel.shareMessage])
        }
        .sheet(isPresented: $showAllReferrals) {
            AllReferralsView(viewModel: viewModel)
        }
        .alert("Referral Code Info", isPresented: $showCodeInfo) {
            Button("Got it!") { }
        } message: {
            Text("This is your unique referral code! Share it with friends and earn 1 free month for each friend who subscribes to Premium Annual or Lifetime plans.")
        }
        .overlay(
            // Success animation overlay
            Group {
                if showInviteSuccess {
                    InviteSuccessView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .overlay(
            // Copied animation
            Group {
                if showCopiedAnimation {
                    CopiedTooltip()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension TellAFView {
    
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
        VStack(spacing: 20) {
            // Animated gift icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appYellow)
                    .rotationEffect(.degrees(viewModel.giftRotation))
                    .scaleEffect(viewModel.giftScale)
            }
            
            VStack(spacing: 12) {
                Text("Share the Fitness Journey!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                Text("Invite your friends and earn free premium time for each successful referral")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.top, 20)
    }
    
    var referralCodeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Referral Code")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                // Info button instead of refresh
                Button(action: {
                    showCodeInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.appYellow.opacity(0.7))
                        .font(.system(size: 16))
                }
            }
            
            // Referral code display
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.referralCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.appWhite)
                        .tracking(2)
                    
                    Text("Tap to copy")
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
                
                Spacer()
                
                Button(action: copyReferralCode) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 24))
                        .foregroundColor(.appYellow)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                    )
            )
            .onTapGesture {
                copyReferralCode()
            }
        }
    }
    
    var rewardsInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How it Works")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                RewardStepView(
                    step: "1",
                    title: "Share Your Code",
                    description: "Send your unique referral code to friends",
                    icon: "square.and.arrow.up",
                    color: .blue
                )
                
                RewardStepView(
                    step: "2",
                    title: "Friend Subscribes",
                    description: "They subscribe to Premium Annual or Lifetime",
                    icon: "crown.fill",
                    color: .purple
                )
                
                RewardStepView(
                    step: "3",
                    title: "You Get Rewarded",
                    description: "Earn 1 month free Premium for each referral",
                    icon: "gift.fill",
                    color: .green
                )
            }
        }
    }
    
    var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 20) {
                // Progress stats
                HStack(spacing: 20) {
                    ProgressStatCard(
                        title: "Invited",
                        value: "\(viewModel.totalInvites)",
                        subtitle: "friends",
                        color: .blue
                    )
                    
                    ProgressStatCard(
                        title: "Subscribed",
                        value: "\(viewModel.successfulReferrals)",
                        subtitle: "conversions",
                        color: .green
                    )
                    
                    ProgressStatCard(
                        title: "Earned",
                        value: "\(viewModel.monthsEarned)",
                        subtitle: "free months",
                        color: .appYellow
                    )
                }
            }
            .padding(20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    var shareOptionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Share Options")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ShareOptionCard(
                    title: "Share Link",
                    icon: "link",
                    color: .blue
                ) {
                    showShareSheet = true
                }
                
                ShareOptionCard(
                    title: "Copy Code",
                    icon: "doc.on.clipboard",
                    color: .green
                ) {
                    copyReferralCode()
                }
                
                ShareOptionCard(
                    title: "QR Code",
                    icon: "qrcode",
                    color: .purple
                ) {
                    viewModel.showQRCode()
                }
                
                ShareOptionCard(
                    title: "Invite via SMS",
                    icon: "message",
                    color: .orange
                ) {
                    viewModel.shareViaSMS()
                }
            }
        }
    }
    
    var friendsListSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Referrals")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
                
                if !viewModel.referrals.isEmpty {
                    Button("View All") {
                        showAllReferrals = true
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.appYellow)
                }
            }
            
            if viewModel.referrals.isEmpty {
                EmptyReferralsView()
            } else {
                ForEach(viewModel.referrals.prefix(3), id: \.id) { referral in
                    ReferralRow(referral: referral)
                }
            }
        }
    }
    
    // MARK: - Actions
    func copyReferralCode() {
        UIPasteboard.general.string = viewModel.referralCode
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showCopiedAnimation = false
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Supporting Views
struct RewardStepView: View {
    let step: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                    
                    Text(step)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(color)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ProgressBarWo: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow, Color.yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)), height: 8)
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 8)
    }
}

struct ShareOptionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReferralRow: View {
    let referral: ReferralData
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(referral.status.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(String(referral.friendName.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(referral.status.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(referral.friendName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text(referral.inviteDate, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            // Status badge
            Text(referral.status.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(referral.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(referral.status.color.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EmptyReferralsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundColor(.appYellow.opacity(0.5))
            
            Text("No referrals yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appWhite)
            
            Text("Start sharing your code to see your referrals here!")
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct CopiedTooltip: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Copied to clipboard!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 100)
        }
    }
}

struct InviteSuccessView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Invitation Sent!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appWhite)
        }
        .padding(40)
        .background(Color.appBlack.opacity(0.9))
        .cornerRadius(20)
    }
}

// MARK: - All Referrals View
struct AllReferralsView: View {
    @ObservedObject var viewModel: TellAFViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedFilter: ReferralFilter = .all
    
    enum ReferralFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case registered = "Signed Up"
        case subscribed = "Subscribed"
        case expired = "Expired"
        
        var status: ReferralData.ReferralStatus? {
            switch self {
            case .all: return nil
            case .pending: return .pending
            case .registered: return .registered
            case .subscribed: return .subscribed
            case .expired: return .expired
            }
        }
    }
    
    var filteredReferrals: [ReferralData] {
        var filtered = viewModel.referrals
        
        // Apply status filter
        if let status = selectedFilter.status {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { referral in
                referral.friendName.localizedCaseInsensitiveContains(searchText) ||
                referral.friendEmail.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.inviteDate > $1.inviteDate }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and filter section
                    VStack(spacing: 16) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.appWhite.opacity(0.6))
                            
                            TextField("Search friends...", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.appWhite)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        // Filter tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ReferralFilter.allCases, id: \.self) { filter in
                                    FilterTab(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter,
                                        count: getCountForFilter(filter)
                                    ) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Referrals list
                    if filteredReferrals.isEmpty {
                        EmptyStateView(filter: selectedFilter, searchText: searchText)
                    } else {
                        List {
                            ForEach(filteredReferrals) { referral in
                                DetailedReferralRow(referral: referral)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.appBlack)
                    }
                }
            }
            .navigationTitle("All Referrals (\(viewModel.referrals.count))")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.appYellow)
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func getCountForFilter(_ filter: ReferralFilter) -> Int {
        if filter == .all {
            return viewModel.referrals.count
        } else if let status = filter.status {
            return viewModel.referrals.filter { $0.status == status }.count
        }
        return 0
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? .black : .appWhite)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isSelected ? Color.appWhite.opacity(0.3) : Color.appYellow.opacity(0.3)
                        )
                        .cornerRadius(8)
                }
            }
            .foregroundColor(isSelected ? .black : .appWhite)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.appYellow : Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DetailedReferralRow: View {
    let referral: ReferralData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar with status indicator
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(referral.status.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(referral.friendName.prefix(1)).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(referral.status.color)
                        )
                    
                    Circle()
                        .fill(referral.status.color)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.appBlack, lineWidth: 2)
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(referral.friendName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appWhite)
                    
                    Text(referral.friendEmail)
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.7))
                    
                    HStack {
                        Text("Invited:")
                            .font(.system(size: 12))
                            .foregroundColor(.appWhite.opacity(0.5))
                        
                        Text(referral.inviteDate, style: .date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appWhite.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Status badge
                    Text(referral.status.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(referral.status.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(referral.status.color.opacity(0.2))
                        .cornerRadius(12)
                    
                    // Reward indicator
                    if referral.status == .subscribed && referral.rewardGranted {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            
                            Text("Reward Earned")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            // Additional info for subscribed users
            if let subscriptionDate = referral.subscriptionDate {
                Divider()
                    .background(Color.appWhite.opacity(0.2))
                
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text("Subscribed:")
                            .font(.system(size: 12))
                            .foregroundColor(.appWhite.opacity(0.7))
                        
                        Text(subscriptionDate, style: .date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    if referral.rewardGranted {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.appYellow)
                            
                            Text("+1 Month Free")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appYellow)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
}

struct EmptyStateView: View {
    let filter: AllReferralsView.ReferralFilter
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "person.2.fill" : "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.appYellow.opacity(0.5))
            
            Text(emptyMessage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
            
            Text(emptySubtitle)
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private var emptyMessage: String {
        if !searchText.isEmpty {
            return "No results found"
        }
        
        switch filter {
        case .all:
            return "No referrals yet"
        case .pending:
            return "No pending invitations"
        case .registered:
            return "No friends have signed up yet"
        case .subscribed:
            return "No successful conversions yet"
        case .expired:
            return "No expired invitations"
        }
    }
    
    private var emptySubtitle: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or filters"
        }
        
        switch filter {
        case .all:
            return "Start sharing your referral code to see your referrals here!"
        case .pending:
            return "Invited friends who haven't signed up yet will appear here"
        case .registered:
            return "Friends who signed up but haven't subscribed will appear here"
        case .subscribed:
            return "Friends who subscribed to premium will appear here"
        case .expired:
            return "Expired invitations will appear here"
        }
    }
}

// MARK: - Share Sheet
struct ShareSheetTaF: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct TellAFView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TellAFView()
        }
        .preferredColorScheme(.dark)
    }
}
