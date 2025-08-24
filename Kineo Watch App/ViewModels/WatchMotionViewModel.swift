import Foundation
import Combine
import SwiftUI

@MainActor
final class WatchMotionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentMotionData: MotionData?
    @Published var isUpdating = false
    @Published var errorMessage: String?
    @Published var isConnected = false
    
    // MARK: - Private Properties
    private let motionManager: WatchMotionManaging
    private let connectivitySender: any WatchConnectivitySending
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: WatchMotionManaging = WatchMotionManager(), 
         connectivitySender: any WatchConnectivitySending = WatchConnectivitySender()) {
        self.motionManager = motionManager
        self.connectivitySender = connectivitySender
        setupBindings()
        setupCommandHandling()
    }
    
    // MARK: - Public Methods
    func startUpdates() {
        do {
            try motionManager.startUpdates()
            isUpdating = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopUpdates() {
        motionManager.stopUpdates()
        isUpdating = false
        currentMotionData = nil
    }
    
    func sendNumberToiPhone(_ number: String) async throws {
        guard connectivitySender.isReachable else {
            throw WatchConnectivityError.deviceNotReachable
        }
        let message = ["number": number]
        try await connectivitySender.sendMessage(message)
        print("Watch: 数字发送成功")
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        motionManager.currentMotionDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] motionData in
                self?.currentMotionData = motionData
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
    
    private func setupCommandHandling() {
        // 设置命令处理器
        if let sender = connectivitySender as? WatchConnectivitySender {
            sender.setCommandHandler { [weak self] command in
                self?.handleCommand(command)
            }
        }
    }
    
    private func handleCommand(_ command: String) {
        print("Watch: 处理来自 iPhone 的命令: \(command)")
        
        switch command {
        case "startTracking":
            print("Watch: 收到开始追踪命令")
            startUpdates()
            
        case "stopTracking":
            print("Watch: 收到停止追踪命令")
            stopUpdates()
            
        default:
            print("Watch: 未知命令: \(command)")
        }
    }
    
    private func updateConnectionStatus() {
        isConnected = connectivitySender.isReachable
    }
} 

