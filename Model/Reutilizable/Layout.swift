import SwiftUI

// MARK: - Card Grid Layout
struct CardGridLayout<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: Content
    
    init(
        columns: Int = 2,
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            content
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Section Layout
struct SectionLayout<Content: View>: View {
    let title: String?
    let content: Content
    
    init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                SimpleSectionHeader(title: title)
            }
            
            content
        }
    }
}

// MARK: - Scrollable Content
struct ScrollableContent<Content: View>: View {
    let showsIndicators: Bool
    let content: Content
    
    init(
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            VStack(spacing: 30) {
                content
            }
            .padding(.bottom, 100) // Space for bottom button
        }
    }
}

// MARK: - Margen horizontal reutilizable
struct HorizontalScreenPaddingModifier: ViewModifier {
    let value: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, value)
    }
}

extension View {
    func screenHorizontalPadding(_ value: CGFloat = 20) -> some View {
        self.modifier(HorizontalScreenPaddingModifier(value: value))
    }
} 