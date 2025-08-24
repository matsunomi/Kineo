import Foundation
import Combine

@MainActor
final class MotionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var motionData: MotionData?
    @Published private(set) var isUpdating = false
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let motionManager: MotionManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: MotionManaging = MotionManager()) {
        self.motionManager = motionManager
        setupBindings()
    }
    
    // MARK: - Public Interface
    func startUpdates() {
        motionManager.startUpdates()
        isUpdating = true
        error = nil
    }
    
    func stopUpdates() {
        motionManager.stopUpdates()
        isUpdating = false
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        motionManager.currentMotionDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] motionData in
                self?.motionData = motionData
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Testing Support
    #if DEBUG
    func simulateMotionData(_ data: MotionData) {
        motionData = data
    }
    #endif
} 