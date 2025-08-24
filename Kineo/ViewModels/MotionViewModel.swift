import Foundation
import Combine
import SwiftUI

@MainActor
final class MotionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentMotionData: MotionData?
    @Published var isReceivingData = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var errorMessage: String?
    @Published var isWatchTracking = false
    @Published var isWatchPaired = false
    @Published var isWatchAppInstalled = false
    @Published var receivedNumber: String?
    
    // MARK: - Private Properties
    private let connectivityReceiver: WatchConnectivityReceiving
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(connectivityReceiver: WatchConnectivityReceiving = WatchConnectivityReceiver()) {
        self.connectivityReceiver = connectivityReceiver
        setupBindings()
    }
    
    // MARK: - Public Methods
    func startReceiving() {
        connectivityReceiver.startReceiving()
        isReceivingData = true
        connectionStatus = .connecting
    }
    
    func stopReceiving() {
        isReceivingData = false
        connectionStatus = .disconnected
    }
    
    func startWatchTracking() {
        Task {
            do {
                try await connectivityReceiver.sendCommandToWatch("startTracking")
                isWatchTracking = true
                errorMessage = nil
            } catch {
                errorMessage = "启动 Watch 追踪失败: \(error.localizedDescription)"
            }
        }
    }
    
    func stopWatchTracking() {
        Task {
            do {
                try await connectivityReceiver.sendCommandToWatch("stopTracking")
                isWatchTracking = false
                errorMessage = nil
            } catch {
                errorMessage = "停止 Watch 追踪失败: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // 监听来自 Watch 的运动数据
        connectivityReceiver.motionDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] motionData in
                self?.currentMotionData = motionData
                self?.connectionStatus = .connected
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
        
        // 监听来自 Watch 的数字数据
        connectivityReceiver.numberPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                self?.receivedNumber = number
                self?.connectionStatus = .connected
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
        
        // 监听连接状态变化
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateConnectionStatus()
            }
            .store(in: &cancellables)
    }
    
    private func updateConnectionStatus() {
        let isReachable = connectivityReceiver.isReachable
        
        if isReceivingData && isReachable {
            connectionStatus = .connected
        } else if isReceivingData && !isReachable {
            connectionStatus = .disconnected
            errorMessage = "Apple Watch 连接断开"
        }
        
        // 更新 Watch 状态信息
        if let receiver = connectivityReceiver as? WatchConnectivityReceiver {
            isWatchPaired = receiver.isWatchPaired
            isWatchAppInstalled = receiver.isWatchAppInstalled
        }
    }
}

// MARK: - Connection Status
enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    
    var displayText: String {
        switch self {
        case .disconnected:
            return "未连接"
        case .connecting:
            return "连接中..."
        case .connected:
            return "已连接"
        }
    }
    
    var color: Color {
        switch self {
        case .disconnected:
            return .red
        case .connecting:
            return .orange
        case .connected:
            return .green
        }
    }
} 