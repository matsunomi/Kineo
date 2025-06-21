import Foundation
import CoreMotion
import Combine
import Kineo

protocol WatchMotionManaging {
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> { get }
    func startUpdates() throws
    func stopUpdates()
}

final class WatchMotionManager: WatchMotionManaging {
    // ... rest of the file ...
} 