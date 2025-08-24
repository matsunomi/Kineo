import Foundation
import Combine
import SwiftUI

@MainActor
final class WatchMotionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentMotionData: MotionData?
    @Published var isUpdating = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let motionManager: WatchMotionManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: WatchMotionManaging = WatchMotionManager()) {
        self.motionManager = motionManager
        setupBindings()
    }
    
    // MARK: - Public Methods
    func startUpdates() {
        do {
            try motionManager.startUpdates()
            isUpdating = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopUpdates() {
        motionManager.stopUpdates()
        isUpdating = false
        currentMotionData = nil
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        motionManager.currentMotionDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] motionData in
                self?.currentMotionData = motionData
            }
            .store(in: &cancellables)
    }
} 