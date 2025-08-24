import Foundation
import CoreMotion
import Combine

protocol WatchMotionManaging {
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> { get }
    func startUpdates() throws
    func stopUpdates()
    func setupCommandHandling()
}

final class WatchMotionManager: WatchMotionManaging {
    // MARK: - Properties
    private let motionManager = CMMotionManager()
    private let motionDataSubject = CurrentValueSubject<MotionData?, Never>(nil)
    private let connectivitySender: WatchConnectivitySending
    private var lastSentData: MotionData?
    private let sendThreshold: Double = 0.1 // 只有当数据变化超过阈值时才发送
    
    var currentMotionDataPublisher: AnyPublisher<MotionData?, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(connectivitySender: WatchConnectivitySending = WatchConnectivitySender()) {
        self.connectivitySender = connectivitySender
        setupMotionManager()
        setupCommandHandling()
    }
    
    // MARK: - Public Interface
    func startUpdates() throws {
        guard motionManager.isDeviceMotionAvailable else {
            throw MotionError.deviceMotionNotAvailable
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0 // 降低到30Hz以减少功耗
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
            
            // 智能发送：只有当数据变化显著时才发送到iPhone
            if self.shouldSendData(motionData) {
                self.sendDataToiPhone(motionData)
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionDataSubject.send(nil)
        lastSentData = nil
    }
    
    func setupCommandHandling() {
        // 设置命令处理器
        if let sender = connectivitySender as? WatchConnectivitySender {
            sender.setCommandHandler { [weak self] command in
                self?.handleCommand(command)
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
    }
    
    private func shouldSendData(_ newData: MotionData) -> Bool {
        guard let lastData = lastSentData else {
            return true // 第一次发送
        }
        
        // 检查加速度变化
        let accelerationDiff = abs(newData.accelerationMagnitude - lastData.accelerationMagnitude)
        let rotationDiff = abs(newData.rotationMagnitude - lastData.rotationMagnitude)
        
        return accelerationDiff > sendThreshold || rotationDiff > sendThreshold
    }
    
    private func sendDataToiPhone(_ data: MotionData) {
        guard connectivitySender.isReachable else {
            print("iPhone is not reachable, skipping data send")
            return
        }
        
        Task {
            do {
                try await connectivitySender.sendMotionData(data)
                lastSentData = data
            } catch {
                print("Failed to send motion data to iPhone: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleCommand(_ command: String) {
        switch command {
        case "startTracking":
            print("Watch: 收到开始追踪命令")
            do {
                try startUpdates()
            } catch {
                print("Watch: 启动传感器失败: \(error)")
            }
            
        case "stopTracking":
            print("Watch: 收到停止追踪命令")
            stopUpdates()
            
        default:
            print("Watch: 未知命令: \(command)")
        }
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