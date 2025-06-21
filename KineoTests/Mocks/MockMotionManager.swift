import Foundation
import Combine
@testable import Kineo

final class MockMotionManager: MotionManaging {
    // MARK: - Properties
    private let motionDataSubject = CurrentValueSubject<MotionData?, Never>(nil)
    
    // MARK: - Protocol Conformance
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    func startUpdates() {
        // No-op for testing
    }
    
    func stopUpdates() {
        motionDataSubject.send(nil)
    }
    
    // MARK: - Test Support Methods
    func simulateMotionData(_ data: MotionData) {
        motionDataSubject.send(data)
    }
    
    func simulateNoMotionData() {
        motionDataSubject.send(nil)
    }
} 