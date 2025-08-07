import SwiftUI
import AVFoundation

struct FoodScannerView: View {
    @StateObject private var logMealService = LogMealService()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showResults = false
    @State private var detectedFoods: [DetectedFood] = []
    @State private var isViewLoaded = false
    @State private var showCameraError = false
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
                            openCameraOrPhotoLibrary()
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        if selectedImage == nil {
                            // Take photo button
                            Button(action: {
                                openCameraOrPhotoLibrary()
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
                                    openCameraOrPhotoLibrary()
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
                                        if logMealService.isAnalyzing {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .appBlack))
                                        } else {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 16))
                                        }
                                        
                                        Text(logMealService.isAnalyzing ? "Analyzing..." : "Analyze")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .foregroundColor(.appBlack)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appYellow)
                                    .cornerRadius(8)
                                }
                                .disabled(logMealService.isAnalyzing)
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showResults) {
                FoodScanResultsView(
                    detectedFoods: detectedFoods,
                    totalCalories: detectedFoods.reduce(0) { $0 + $1.calories }
                )
            }
            .alert("Error", isPresented: .constant(logMealService.errorMessage != nil)) {
                Button("OK") {
                    logMealService.errorMessage = nil
                }
            } message: {
                Text(logMealService.errorMessage ?? "")
            }
            .alert("Camera Error", isPresented: $showCameraError) {
                Button("OK") {
                    showCameraError = false
                }
            } message: {
                Text("Unable to access camera. Please check your camera permissions in Settings.")
            }
            .onAppear {
                isViewLoaded = true
            }
        }
    }
    
    private func analyzeImage() {
        guard let image = selectedImage else { return }
        
        logMealService.analyzeFoodImage(image) { result in
            switch result {
            case .success(let foods):
                self.detectedFoods = foods
                self.showResults = true
            case .failure(let error):
                print("Analysis failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func openCameraOrPhotoLibrary() {
        print("📸 Attempting to open camera or photo library")
        
        // Check if we're running on simulator
        #if targetEnvironment(simulator)
        print("📱 Running on simulator, using photo library")
        showImagePicker = true
        #else
        // On real device, try camera first
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("📷 Camera available on device, opening camera")
            showCamera = true
        } else {
            print("⚠️ Camera not available, using photo library")
            showImagePicker = true
        }
        #endif
    }
} 