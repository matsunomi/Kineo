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
    private let connectivitySender: WatchConnectivitySending
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(motionManager: WatchMotionManaging = WatchMotionManager(), 
         connectivitySender: WatchConnectivitySending = WatchConnectivitySender()) {
        self.motionManager = motionManager
        self.connectivitySender = connectivitySender
        setupBindings()
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
        
        return try await withCheckedThrowingContinuation { continuation in
            connectivitySender.sendMessage(message, replyHandler: { response in
                print("Watch: 数字发送成功，iPhone 响应: \(response)")
                continuation.resume()
            }, errorHandler: { error in
                print("Watch: 数字发送失败: \(error)")
                continuation.resume(throwing: error)
            })
        }
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
    
    private func updateConnectionStatus() {
        isConnected = connectivitySender.isReachable
    }
} 