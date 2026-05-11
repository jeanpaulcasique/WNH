import SwiftUI

struct MuscleCategoryCards: View {
    let muscleGroups: [MuscleGroup]
    let selectedMuscle: MuscleGroup?
    let onMuscleSelected: (MuscleGroup) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(muscleGroups) { group in
                    Button(action: {
                        onMuscleSelected(group)
                    }) {
                        HStack(spacing: 6) {
                            Text(LanguageManager.localizedString(group.name))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appWhite)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedMuscle == group ? Color.appYellow : Color.white.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .shadow(color: Color.appYellow.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedMuscle)
                }
            }
        
          
        }
    }
}

// MARK: - Preview
struct MuscleCategoryCards_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            VStack {
                MuscleCategoryCards(
                    muscleGroups: [
                        MuscleGroup(name: "Cardio", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: false),
                        MuscleGroup(name: "Shoulders", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true),
                        MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true),
                        MuscleGroup(name: "Biceps", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: false)
                    ],
                    selectedMuscle: nil,
                    onMuscleSelected: { _ in }
                )
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
} 
