import Foundation

enum MockMotionData {
    static let sample = MotionData(
        acceleration: SIMD3<Double>(0.1, 0.2, 0.3),
        rotation: SIMD3<Double>(0.4, 0.5, 0.6)
    )
    
    static let samples = [
        MotionData(acceleration: SIMD3<Double>(0.1, 0.2, 0.3), rotation: SIMD3<Double>(0.4, 0.5, 0.6)),
        MotionData(acceleration: SIMD3<Double>(0.2, 0.3, 0.4), rotation: SIMD3<Double>(0.5, 0.6, 0.7)),
        MotionData(acceleration: SIMD3<Double>(0.3, 0.4, 0.5), rotation: SIMD3<Double>(0.6, 0.7, 0.8))
    ]
} 