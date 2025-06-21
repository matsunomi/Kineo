import Foundation
import CoreMotion
import Combine

protocol WatchMotionManaging {
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> { get }
    func startUpdates() throws
    func stopUpdates()
}

final class WatchMotionManager: WatchMotionManaging {
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    private let motionDataSubject = CurrentValueSubject<MotionData?, Never>(nil)
    private let connectivitySender: WatchConnectivitySending
    
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(connectivitySender: WatchConnectivitySending = WatchConnectivitySender()) {
        self.connectivitySender = connectivitySender
        setupMotionManager()
    }
    
    // MARK: - Public Interface
    func startUpdates() throws {
        guard motionManager.isDeviceMotionAvailable else {
            throw MotionError.deviceMotionNotAvailable
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50Hz
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Motion update error: \(error.localizedDescription)")
                return
            }
            
            guard let motion = motion else { return }
            
            let motionData = MotionData(
                acceleration: SIMD3<Double>(
                    motion.userAcceleration.x,
                    motion.userAcceleration.y,
                    motion.userAcceleration.z
                ),
                rotation: SIMD3<Double>(
                    motion.rotationRate.x,
                    motion.rotationRate.y,
                    motion.rotationRate.z
                )
            )
            
            self.motionDataSubject.send(motionData)
            
            // Send data to iPhone if reachable
            if self.connectivitySender.isReachable {
                Task {
                    try? await self.connectivitySender.sendMotionData(motionData)
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionDataSubject.send(nil)
    }
    
    // MARK: - Private Methods
    private func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
    }
}

// MARK: - Errors
enum MotionError: LocalizedError {
    case deviceMotionNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .deviceMotionNotAvailable:
            return "Device motion is not available"
        }
    }
} 