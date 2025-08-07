import SwiftUI
import AVFoundation

struct FoodScannerView: View {
    @StateObject private var clarifaiService = ClarifaiService()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showResults = false
    @State private var detectedFoods: [DetectedFood] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            Text("Food Scanner")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Take a photo of your food to get calorie estimates")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Camera preview or placeholder
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                    } else {
                        // Camera placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.2))
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appYellow.opacity(0.3), lineWidth: 2, antialiased: false)
                                )
                            
                            VStack(spacing: 16) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 60))
                                    .foregroundColor(.appYellow.opacity(0.6))
                                
                                Text("Tap to take a photo")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            showCamera = true
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        if selectedImage == nil {
                            // Take photo button
                            Button(action: {
                                showCamera = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20))
                                    
                                    Text("Take Photo")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.appBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appYellow)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            // Analyze and retake buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    showCamera = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16))
                                        
                                        Text("Retake")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.appYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appYellow.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    analyzeImage()
                                }) {
                                    HStack(spacing: 8) {
                                        if clarifaiService.isAnalyzing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .appBlack))
                                        } else {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 16))
                                        }
                                        
                                        Text(clarifaiService.isAnalyzing ? "Analyzing..." : "Analyze")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.appBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appYellow)
                                    .cornerRadius(8)
                                }
                                .disabled(clarifaiService.isAnalyzing)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showResults) {
                FoodScanResultsView(
                    detectedFoods: detectedFoods,
                    totalCalories: detectedFoods.reduce(0) { $0 + $1.calories }
                )
            }
            .alert("Error", isPresented: .constant(clarifaiService.errorMessage != nil)) {
                Button("OK") {
                    clarifaiService.errorMessage = nil
                }
            } message: {
                Text(clarifaiService.errorMessage ?? "")
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        clarifaiService.analyzeFoodImage(image) { result in
            switch result {
            case .success(let foods):
                self.detectedFoods = foods
                self.showResults = true
            case .failure(let error):
                print("Analysis failed: \(error.localizedDescription)")
            }
        }
    }
} 