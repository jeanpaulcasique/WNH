import SwiftUI

struct HorizontalImageScroll: View {
    let images: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                }
            }
            .padding(.vertical, 5)
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.bold())
            .padding(.horizontal)
    }
}
struct GroceryItem: Identifiable {
  let id = UUID()
  let name: String
  let quantity: String
  var purchased: Bool
}


struct Macros {
  var carbs: Int  // en gramos
  var protein: Int
  var fat: Int
}



