import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivitySending {
    var isReachable: Bool { get }
    func sendMotionData(_ data: MotionData) async throws
    func sendMessage(_ message: [String: Any]) async throws
    func startListeningForCommands()
}

final class WatchConnectivitySender: NSObject, WatchConnectivitySending {
    // MARK: - Properties
    private let session: WCSession
    private let queue = DispatchQueue(label: "com.kineo.watchconnectivity", qos: .userInitiated)
    private var commandHandler: ((String) -> Void)?
    
    // MARK: - Initialization
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        print("Watch: WatchConnectivitySender 初始化")
        setupSession()
    }
    
    // MARK: - Public Interface
    var isReachable: Bool {
        let reachable = session.isReachable
        print("Watch: 检查连接状态 - isReachable: \(reachable)")
        return reachable
    }
    
    func sendMotionData(_ data: MotionData) async throws {
        print("Watch: 尝试发送运动数据到 iPhone")
        guard session.isReachable else {
            print("Watch: ❌ iPhone 不可达")
            throw WatchConnectivityError.deviceNotReachable
        }
        
        print("Watch: ✅ iPhone 可达，发送运动数据...")
        let encoder = JSONEncoder()
        let data = try encoder.encode(data)
        let message = ["motionData": data]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message, replyHandler: { response in
                print("Watch: ✅ 运动数据发送成功，iPhone 响应: \(response)")
                continuation.resume()
            }, errorHandler: { error in
                print("Watch: ❌ 运动数据发送失败: \(error)")
                continuation.resume(throwing: error)
            })
        }
    }
    
    func sendMessage(_ message: [String: Any]) async throws {
        print("Watch: 尝试发送消息到 iPhone: \(message)")
        guard session.isReachable else {
            print("Watch: ❌ iPhone 不可达")
            throw WatchConnectivityError.deviceNotReachable
        }
        
        print("Watch: ✅ iPhone 可达，发送消息...")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message, replyHandler: { response in
                print("Watch: ✅ 消息发送成功，iPhone 响应: \(response)")
                continuation.resume()
            }, errorHandler: { error in
                print("Watch: ❌ 消息发送失败: \(error)")
                continuation.resume(throwing: error)
            })
        }
    }
    
    func startListeningForCommands() {
        print("Watch: 开始监听来自 iPhone 的命令")
    }
    
    // MARK: - Private Methods
    private func setupSession() {
        guard WCSession.isSupported() else { 
            print("Watch: ❌ WatchConnectivity 不支持")
            return 
        }
        print("Watch: 设置 WatchConnectivity session")
        session.delegate = self
        session.activate()
    }
    
    func setCommandHandler(_ handler: @escaping (String) -> Void) {
        commandHandler = handler
        print("Watch: 命令处理器已设置")
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivitySender: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch: ❌ WatchConnectivity 激活失败: \(error.localizedDescription)")
        } else {
            print("Watch: ✅ WatchConnectivity 激活成功，状态: \(activationState.rawValue)")
            print("Watch: iPhone 可达状态: \(session.isReachable)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    // 接收来自 iPhone 的命令
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Watch: 📨 收到来自 iPhone 的消息: \(message)")
        queue.async { [weak self] in
            guard let self = self,
                  let command = message["command"] as? String else {
                print("Watch: ❌ 命令格式无效")
                replyHandler(["error": "Invalid command format"])
                return
            }
            
            print("Watch: ✅ 收到命令: \(command)")
            
            // 处理命令
            self.commandHandler?(command)
            
            replyHandler(["success": true, "command": command])
        }
    }
    
    // 监听连接状态变化
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch: 🔄 iPhone 连接状态变化: \(session.isReachable ? "可达" : "不可达")")
    }
}

// MARK: - Errors
enum WatchConnectivityError: LocalizedError {
    case deviceNotReachable
    
    var errorDescription: String? {
        switch self {
        case .deviceNotReachable:
            return "iPhone is not reachable"
        }
    }
} 
