import SwiftUI
import Combine

final class MotionViewModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var motionData: MotionData?
    @Published private(set) var isUpdating = false
    private let motionManager: any MotionManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: any MotionManaging = MotionManager()) {
        self.motionManager = motionManager
        setupBindings()
    }
    
    // MARK: - Public Methods
    func startUpdates() {
        motionManager.startUpdates()
        isUpdating = true
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