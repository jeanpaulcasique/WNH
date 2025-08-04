import Foundation
import Combine
import UIKit
import SwiftUI

/// Servicio que maneja optimizaciones de performance para el módulo Workout
class PerformanceOptimizer: ObservableObject {
    
    // MARK: - Cache Management
    private var exerciseCache: [String: [Exercise]] = [:]
    private var muscleGroupCache: [String: [MuscleGroup]] = [:]
    private var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        return cache
    }()
    
    // MARK: - Background Processing
    private let backgroundQueue = DispatchQueue(label: "com.wnh.workout.background", qos: .utility)
    private let imageProcessingQueue = DispatchQueue(label: "com.wnh.workout.images", qos: .userInitiated)
    
    // MARK: - Memory Management
    private var cancellables = Set<AnyCancellable>()
    private var memoryWarningObserver: NSObjectProtocol?
    
    // MARK: - Performance Metrics
    @Published var cacheHitRate: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var averageLoadTime: Double = 0.0
    
    private var cacheHits = 0
    private var cacheMisses = 0
    private var loadTimes: [TimeInterval] = []
    
    // MARK: - Initialization
    
    init() {
        setupMemoryWarningObserver()
        setupCacheMetrics()
    }
    
    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        clearAllCaches()
    }
    
    // MARK: - Cache Management
    
    /// Obtiene ejercicios del cache o los carga si no están disponibles
    func getExercises(for muscleName: String, loadFunction: @escaping () async throws -> [Exercise]) async throws -> [Exercise] {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Check cache first
        if let cachedExercises = exerciseCache[muscleName] {
            cacheHits += 1
            updateCacheMetrics()
            return cachedExercises
        }
        
        cacheMisses += 1
        updateCacheMetrics()
        
        // Load from source
        let exercises = try await loadFunction()
        
        // Cache the result
        exerciseCache[muscleName] = exercises
        
        // Update performance metrics
        let loadTime = CFAbsoluteTimeGetCurrent() - startTime
        updateLoadTimeMetrics(loadTime)
        
        return exercises
    }
    
    /// Obtiene grupos musculares del cache
    func getMuscleGroups(for view: String, loadFunction: @escaping () async throws -> [MuscleGroup]) async throws -> [MuscleGroup] {
        let cacheKey = "muscleGroups_\(view)"
        
        if let cachedGroups = muscleGroupCache[cacheKey] {
            cacheHits += 1
            updateCacheMetrics()
            return cachedGroups
        }
        
        cacheMisses += 1
        updateCacheMetrics()
        
        let groups = try await loadFunction()
        muscleGroupCache[cacheKey] = groups
        
        return groups
    }
    
    /// Cache de imágenes con lazy loading
    func getImage(for url: String, loadFunction: @escaping () async throws -> UIImage) async throws -> UIImage {
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            cacheHits += 1
            updateCacheMetrics()
            return cachedImage
        }
        
        cacheMisses += 1
        updateCacheMetrics()
        
        let image = try await imageProcessingQueue.async {
            try await loadFunction()
        }
        
        imageCache.setObject(image, forKey: url as NSString)
        return image
    }
    
    // MARK: - Background Processing
    
    /// Procesa datos en segundo plano
    func processInBackground<T>(_ work: @escaping () async throws -> T) async throws -> T {
        return try await backgroundQueue.async {
            try await work()
        }
    }
    
    /// Precarga datos en segundo plano
    func preloadData<T>(_ items: [T], processor: @escaping (T) async throws -> Void) {
        backgroundQueue.async {
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for item in items {
                        group.addTask {
                            try? await processor(item)
                        }
                    }
                }
            }
        }
    }
    
    /// Optimiza imágenes en segundo plano
    func optimizeImage(_ image: UIImage, targetSize: CGSize) async -> UIImage {
        return try! await imageProcessingQueue.async {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { context in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
    }
    
    // MARK: - Memory Management
    
    /// Limpia caches cuando hay advertencia de memoria
    private func setupMemoryWarningObserver() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    private func handleMemoryWarning() {
        clearImageCache()
        clearOldCacheEntries()
        updateMemoryUsage()
    }
    
    /// Limpia todos los caches
    func clearAllCaches() {
        exerciseCache.removeAll()
        muscleGroupCache.removeAll()
        imageCache.removeAllObjects()
        updateMemoryUsage()
    }
    
    /// Limpia solo el cache de imágenes
    func clearImageCache() {
        imageCache.removeAllObjects()
        updateMemoryUsage()
    }
    
    /// Limpia entradas antiguas del cache
    func clearOldCacheEntries() {
        // Remove old exercise cache entries (keep only last 10)
        if exerciseCache.count > 10 {
            let sortedKeys = exerciseCache.keys.sorted()
            let keysToRemove = sortedKeys.dropLast(10)
            keysToRemove.forEach { exerciseCache.removeValue(forKey: $0) }
        }
        
        // Remove old muscle group cache entries
        if muscleGroupCache.count > 5 {
            let sortedKeys = muscleGroupCache.keys.sorted()
            let keysToRemove = sortedKeys.dropLast(5)
            keysToRemove.forEach { muscleGroupCache.removeValue(forKey: $0) }
        }
    }
    
    // MARK: - Performance Metrics
    
    private func setupCacheMetrics() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMemoryUsage()
            }
            .store(in: &cancellables)
    }
    
    private func updateCacheMetrics() {
        let total = cacheHits + cacheMisses
        if total > 0 {
            cacheHitRate = Double(cacheHits) / Double(total)
        }
    }
    
    private func updateLoadTimeMetrics(_ loadTime: TimeInterval) {
        loadTimes.append(loadTime)
        
        // Keep only last 100 measurements
        if loadTimes.count > 100 {
            loadTimes.removeFirst()
        }
        
        averageLoadTime = loadTimes.reduce(0, +) / Double(loadTimes.count)
    }
    
    private func updateMemoryUsage() {
        let imageCacheSize = Double(imageCache.totalCostLimit)
        let exerciseCacheSize = Double(exerciseCache.count * 1024) // Estimate
        let muscleCacheSize = Double(muscleGroupCache.count * 512) // Estimate
        
        memoryUsage = (imageCacheSize + exerciseCacheSize + muscleCacheSize) / (1024 * 1024) // MB
    }
    
    // MARK: - Lazy Loading
    
    /// Implementa lazy loading para listas grandes
    func lazyLoadItems<T>(_ items: [T], pageSize: Int = 20) -> LazyLoadingManager<T> {
        return LazyLoadingManager(items: items, pageSize: pageSize)
    }
    
    /// Optimiza scroll performance
    func optimizeScrollPerformance<T: Identifiable>(_ items: [T]) -> OptimizedListManager<T> {
        return OptimizedListManager(items: items)
    }
}

// MARK: - Lazy Loading Manager

class LazyLoadingManager<T> {
    private let items: [T]
    private let pageSize: Int
    private var currentPage = 0
    
    init(items: [T], pageSize: Int) {
        self.items = items
        self.pageSize = pageSize
    }
    
    func loadNextPage() -> [T] {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, items.count)
        
        guard startIndex < items.count else { return [] }
        
        let pageItems = Array(items[startIndex..<endIndex])
        currentPage += 1
        
        return pageItems
    }
    
    func hasMorePages() -> Bool {
        return currentPage * pageSize < items.count
    }
    
    func reset() {
        currentPage = 0
    }
}

// MARK: - Optimized List Manager

class OptimizedListManager<T: Identifiable> {
    private let items: [T]
    private var visibleItems: [T] = []
    private let visibleRange = 10
    
    init(items: [T]) {
        self.items = items
        updateVisibleItems(for: 0)
    }
    
    func updateVisibleItems(for index: Int) {
        let startIndex = max(0, index - visibleRange / 2)
        let endIndex = min(items.count, index + visibleRange / 2)
        
        visibleItems = Array(items[startIndex..<endIndex])
    }
    
    func getVisibleItems() -> [T] {
        return visibleItems
    }
    
    func getItem(at index: Int) -> T? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
}

// MARK: - Performance Extensions

extension DispatchQueue {
    func async<T>(_ work: @escaping () async throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.async {
                Task {
                    do {
                        let result = try await work()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
} 