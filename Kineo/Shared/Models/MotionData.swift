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
    
    // MARK: - Computed Properties
    
    /// Acceleration magnitude in m/s²
    public var accelerationMagnitude: Double {
        sqrt(acceleration.x * acceleration.x + 
             acceleration.y * acceleration.y + 
             acceleration.z * acceleration.z)
    }
    
    /// Rotation rate magnitude in rad/s
    public var rotationMagnitude: Double {
        sqrt(rotation.x * rotation.x + 
             rotation.y * rotation.y + 
             rotation.z * rotation.z)
    }
    
    /// Rotation rate in degrees/s (more intuitive for many applications)
    public var rotationDegreesPerSecond: SIMD3<Double> {
        SIMD3<Double>(
            rotation.x * 180.0 / .pi,
            rotation.y * 180.0 / .pi,
            rotation.z * 180.0 / .pi
        )
    }
    
    /// Rotation magnitude in degrees/s
    public var rotationMagnitudeDegreesPerSecond: Double {
        rotationMagnitude * 180.0 / .pi
    }
} 