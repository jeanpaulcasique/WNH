import Foundation
import AVKit
import SwiftUI

class VideoMuscleViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = true
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    
    private var player: AVPlayer?
    let videos: [ExerciseVideo] // ✅ Exposer videos
    
    var nextVideoData: ExerciseVideo? {
        let nextIndex = currentIndex + 1
        guard nextIndex < videos.count else { return nil }
        return videos[nextIndex]
    }
    
    var shouldShowNextPreview: Bool {
        guard duration > 5 else { return false }
        return (duration - currentTime) <= 5 && nextVideoData != nil
    }
    
    var currentVideo: ExerciseVideo {
        return videos[currentIndex]
    }
    
    init(videos: [ExerciseVideo], initialIndex: Int) {
        self.videos = videos
        self.currentIndex = initialIndex
        setupPlayer()
    }
    
    func setupPlayer() {
        let url = URL(string: currentVideo.videoURL) ?? URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!
        player = AVPlayer(url: url)
        observePlayer()
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    func playPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func previousVideo() {
        if currentIndex > 0 {
            currentIndex -= 1
            setupPlayer()
            player?.play()
            currentTime = 0
            isPlaying = true
        }
    }
    
    func goToNextVideo() {
        if currentIndex < videos.count - 1 {
            currentIndex += 1
            setupPlayer()
            player?.play()
            currentTime = 0
            isPlaying = true
        }
    }
    
    func seek(to time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime)
    }
    
    func timeString(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func observePlayer() {
        guard let player = player,
              let item = player.currentItem else { return }
        
        duration = item.asset.duration.seconds.isNaN ? 1 : item.asset.duration.seconds
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            if self?.currentTime ?? 0 >= self?.duration ?? 1 {
                self?.goToNextVideo()
            }
        }
    }
}
