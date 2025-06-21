import Foundation

public struct MotionData: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let acceleration: SIMD3<Double>
    public let rotation: SIMD3<Double>
    
    public init(id: UUID = UUID(), timestamp: Date = Date(), acceleration: SIMD3<Double>, rotation: SIMD3<Double>) {
        self.id = id
        self.timestamp = timestamp
        self.acceleration = acceleration
        self.rotation = rotation
    }
} 