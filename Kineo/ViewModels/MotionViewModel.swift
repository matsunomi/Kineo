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