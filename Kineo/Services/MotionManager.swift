import Foundation
import CoreMotion
import Combine

protocol MotionManaging {
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> { get }
    func startUpdates()
    func stopUpdates()
}

final class MotionManager: MotionManaging {
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    private let motionDataSubject = CurrentValueSubject<MotionData?, Never>(nil)
    
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init() {
        // Don't start updates automatically
    }
    
    // MARK: - Public Methods
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, error == nil else {
                print("Error getting motion data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
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
            
            self?.motionDataSubject.send(motionData)
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionDataSubject.send(nil)
    }
    
    deinit {
        stopUpdates()
    }
} 