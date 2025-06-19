import SwiftUI
import AVKit

struct VideoMuscleView: View {
    @StateObject private var viewModel: VideoMuscleViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(videos: [ExerciseVideo], initialIndex: Int) {
        _viewModel = StateObject(wrappedValue: VideoMuscleViewModel(videos: videos, initialIndex: initialIndex))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Video player que ocupa la mayor parte
                ZStack {
                    if let player = viewModel.getPlayer() {
                        VideoPlayer(player: player)
                            .onAppear {
                                player.play()
                                viewModel.isPlaying = true
                            }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    
                    // Header sobrepuesto
                    VStack {
                        HStack {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            Spacer()
                            
                            // Video counter
                            Text("\(viewModel.currentIndex + 1) de \(viewModel.videos.count)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                        Spacer()
                    }
                    
                    // Next exercise preview (aparece últimos 5 segundos)
                    if viewModel.shouldShowNextPreview, let nextVideo = viewModel.nextVideoData {
                        VStack {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Next exercise")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                        .fontWeight(.semibold)
                                    
                                    // Thumbnail preview más grande y visible
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.black.opacity(0.9))
                                            .frame(width: 120, height: 80)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.yellow, lineWidth: 2)
                                            )
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: "figure.strengthtraining.traditional")
                                                .font(.title2)
                                                .foregroundColor(.yellow)
                                            
                                            Text(nextVideo.title)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 100)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Bottom control area con fondo negro
                VStack(spacing: 16) {
                    // Timer grande
                    Text(viewModel.timeString(viewModel.currentTime))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Progress info y barra
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(viewModel.progressPercentage * 100))%")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(viewModel.timeString(viewModel.duration))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: geometry.size.width * viewModel.progressPercentage, height: 4)
                                    .cornerRadius(2)
                                
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                    .offset(x: geometry.size.width * viewModel.progressPercentage - 6)
                            }
                        }
                        .frame(height: 12)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newProgress = max(0, min(1, value.location.x / 300))
                                    let newTime = newProgress * viewModel.duration
                                    viewModel.seek(to: newTime)
                                }
                        )
                    }
                    
                    // Control buttons
                    HStack(spacing: 40) {
                        Button(action: viewModel.previousVideo) {
                            Text("Prev")
                                .font(.headline)
                                .foregroundColor(viewModel.currentIndex <= 0 ? .gray : .white)
                        }
                        .disabled(viewModel.currentIndex <= 0)
                        
                        Button(action: viewModel.playPause) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(Color.yellow)
                                .cornerRadius(20)
                        }
                        
                        Button(action: viewModel.goToNextVideo) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(viewModel.currentIndex >= viewModel.videos.count - 1 ? .gray : .white)
                        }
                        .disabled(viewModel.currentIndex >= viewModel.videos.count - 1)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.black)
            }
        }
        .navigationBarHidden(true)
    }
}

// Helper extension para calcular progreso
extension VideoMuscleViewModel {
    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
}

struct VideoMuscleView_Previews: PreviewProvider {
    static var previews: some View {
        VideoMuscleView(
            videos: [
                ExerciseVideo(
                    id: "1",
                    title: "Squats with a jump",
                    description: "High intensity leg workout",
                    videoURL: "https://www.w3schools.com/html/mov_bbb.mp4",
                    thumbnailURL: "",
                    duration: 150,
                    difficulty: .intermediate,
                    location: .atHome,
                    muscleGroup: "Legs",
                    equipment: nil,
                    calories: 120,
                    instructions: ["Stand with feet apart", "Jump up explosively"]
                )
            ],
            initialIndex: 0
        )
    }
}
