import Foundation
import CoreLocation
import SwiftUI
import MapKit

@MainActor
class TrainersMapsViewModel: NSObject, ObservableObject {
    @Published var trainers: [Trainer] = []
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLoadingLocation = false
    @Published var selectedTrainer: Trainer?
    @Published var isUserLocationPulsing = false
    @Published var mapZoomLevel: Double = 10.0
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    private let locationManager = CLLocationManager()
    private let earthRadiusMiles: Double = 3959.0
    
    // Predefined pin positions for simulation
    private let pinPositions: [CGPoint] = [
        CGPoint(x: 100, y: 80),
        CGPoint(x: 200, y: 150),
        CGPoint(x: 80, y: 220),
        CGPoint(x: 250, y: 100),
        CGPoint(x: 180, y: 280),
        CGPoint(x: 140, y: 120)
    ]
    
    override init() {
        super.init()
        setupLocationManager()
        requestLocationPermission()
    }
    
    // MARK: - Location Management
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation()
        case .denied, .restricted:
            // Use default location (NYC)
            userLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            return
        }
        
        isLoadingLocation = true
        locationManager.requestLocation()
    }
    
    // MARK: - Trainer Management
    func setTrainers(_ newTrainers: [Trainer]) {
        trainers = newTrainers
        sortTrainersByDistance()
    }
    
    func selectTrainer(_ trainer: Trainer) {
        selectedTrainer = trainer
    }
    
    // MARK: - Distance Calculations
    func calculateDistance(from userCoord: CLLocationCoordinate2D, to trainerCoord: CLLocationCoordinate2D) -> Double {
        let lat1Rad = userCoord.latitude * .pi / 180
        let lat2Rad = trainerCoord.latitude * .pi / 180
        let deltaLatRad = (trainerCoord.latitude - userCoord.latitude) * .pi / 180
        let deltaLonRad = (trainerCoord.longitude - userCoord.longitude) * .pi / 180
        
        let a = sin(deltaLatRad/2) * sin(deltaLatRad/2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad/2) * sin(deltaLonRad/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadiusMiles * c
    }
    
    func getDistanceString(for trainer: Trainer) -> String {
        guard let userLoc = userLocation else {
            // Return simulated distance
            let randomDistance = Double.random(in: 0.5...8.0)
            return String(format: "%.1f miles away", randomDistance)
        }
        
        let trainerCoord = CLLocationCoordinate2D(
            latitude: trainer.location.latitude,
            longitude: trainer.location.longitude
        )
        
        let distance = calculateDistance(from: userLoc, to: trainerCoord)
        
        if distance < 1 {
            return String(format: "%.1f miles away", distance)
        } else {
            return String(format: "%.0f miles away", distance)
        }
    }
    
    func sortTrainersByDistance() {
        guard let userLoc = userLocation else { return }
        
        trainers.sort { trainer1, trainer2 in
            let coord1 = CLLocationCoordinate2D(latitude: trainer1.location.latitude, longitude: trainer1.location.longitude)
            let coord2 = CLLocationCoordinate2D(latitude: trainer2.location.latitude, longitude: trainer2.location.longitude)
            
            let distance1 = calculateDistance(from: userLoc, to: coord1)
            let distance2 = calculateDistance(from: userLoc, to: coord2)
            
            return distance1 < distance2
        }
    }
    
    // MARK: - Map Interaction
    func getPinPosition(for index: Int) -> CGPoint {
        return pinPositions[index % pinPositions.count]
    }
    
    func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newDelta = max(region.span.latitudeDelta / 1.5, 0.002)
            region.span = MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
        }
    }
    
    func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newDelta = min(region.span.latitudeDelta * 1.5, 80.0)
            region.span = MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
        }
    }
    
    func centerMapOnUserLocation() {
        guard let userLoc = userLocation else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            region.center = userLoc
        }
    }
    
    func startLocationPulsing() {
        isUserLocationPulsing = true
    }
    
    func stopLocationPulsing() {
        isUserLocationPulsing = false
    }
    
    // MARK: - Filtering and Search
    func getTrainersWithinRadius(_ radiusMiles: Double) -> [Trainer] {
        guard let userLoc = userLocation else { return trainers }
        
        return trainers.filter { trainer in
            let trainerCoord = CLLocationCoordinate2D(
                latitude: trainer.location.latitude,
                longitude: trainer.location.longitude
            )
            let distance = calculateDistance(from: userLoc, to: trainerCoord)
            return distance <= radiusMiles
        }
    }
    
    func getNearestTrainer() -> Trainer? {
        guard !trainers.isEmpty else { return nil }
        
        if let userLoc = userLocation {
            return trainers.min { trainer1, trainer2 in
                let coord1 = CLLocationCoordinate2D(latitude: trainer1.location.latitude, longitude: trainer1.location.longitude)
                let coord2 = CLLocationCoordinate2D(latitude: trainer2.location.latitude, longitude: trainer2.location.longitude)
                
                let distance1 = calculateDistance(from: userLoc, to: coord1)
                let distance2 = calculateDistance(from: userLoc, to: coord2)
                
                return distance1 < distance2
            }
        }
        
        return trainers.first
    }
    
    // MARK: - Map Bounds
    func getMapBounds() -> (northeast: CLLocationCoordinate2D, southwest: CLLocationCoordinate2D)? {
        guard !trainers.isEmpty else { return nil }
        
        let latitudes = trainers.map { $0.location.latitude }
        let longitudes = trainers.map { $0.location.longitude }
        
        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else {
            return nil
        }
        
        return (
            northeast: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon),
            southwest: CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        )
    }
    
    // MARK: - Utility Functions
    func formatDistance(_ distance: Double) -> String {
        if distance < 0.1 {
            return "< 0.1 miles"
        } else if distance < 1 {
            return String(format: "%.1f miles", distance)
        } else {
            return String(format: "%.0f miles", distance)
        }
    }
    
    func getEstimatedTravelTime(to trainer: Trainer) -> String {
        guard let userLoc = userLocation else { return "Unknown" }
        
        let trainerCoord = CLLocationCoordinate2D(
            latitude: trainer.location.latitude,
            longitude: trainer.location.longitude
        )
        
        let distance = calculateDistance(from: userLoc, to: trainerCoord)
        
        // Estimate travel time (assuming average city speed of 25 mph)
        let travelTimeHours = distance / 25.0
        let travelTimeMinutes = Int(travelTimeHours * 60)
        
        if travelTimeMinutes < 60 {
            return "\(travelTimeMinutes) min"
        } else {
            let hours = travelTimeMinutes / 60
            let minutes = travelTimeMinutes % 60
            return "\(hours)h \(minutes)m"
        }
    }
    
    // MARK: - Analytics and Metrics
    func getAverageRatingInArea() -> Double {
        let ratings = trainers.map { $0.rating }
        guard !ratings.isEmpty else { return 0.0 }
        return ratings.reduce(0, +) / Double(ratings.count)
    }
    
    func getAveragePriceInArea() -> Double {
        let prices = trainers.map { Double($0.pricePerSession) }
        guard !prices.isEmpty else { return 0.0 }
        return prices.reduce(0, +) / Double(prices.count)
    }
    
    func getOnlineTrainersCount() -> Int {
        return trainers.filter { $0.isOnline }.count
    }
    
    func getVerifiedTrainersCount() -> Int {
        return trainers.filter { $0.isVerified }.count
    }

    // Llama a este método cuando el usuario entra al mapa
    func onAppearMap() {
        if let userLoc = userLocation {
            region.center = userLoc
        } else {
            getCurrentLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension TrainersMapsViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.isLoadingLocation = false
            self.sortTrainersByDistance()
            self.region.center = location.coordinate // Centrar el mapa automáticamente
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoadingLocation = false
            // Use default location (NYC) if location fails
            self.userLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        }
        print("Location error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationPermissionStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.getCurrentLocation()
            case .denied, .restricted:
                // Use default location
                self.userLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}
