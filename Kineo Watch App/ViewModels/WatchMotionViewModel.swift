import Foundation
import Combine

@MainActor
final class WatchMotionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var motionData: MotionData?
    @Published private(set) var isUpdating = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let motionManager: WatchMotionManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: WatchMotionManaging = WatchMotionManager()) {
        self.motionManager = motionManager
        setupBindings()
    }
    
    // MARK: - Public Interface
    func startUpdates() {
        do {
            try motionManager.startUpdates()
            isUpdating = true
            error = nil
        } catch {
            self.error = error
        }
    }
    
    func stopUpdates() {
        motionManager.stopUpdates()
        isUpdating = false
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        motionManager.currentMotionDataPublisher
            .receive(on: DispatchQueue.main)
            // Throttle updates to prevent UI flickering
            // Update UI at most every 200ms (5Hz) instead of 50Hz
            .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] motionData in
                self?.motionData = motionData
            }
            .store(in: &cancellables)
    }
} 