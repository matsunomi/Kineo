import Foundation
import WatchConnectivity

// MARK: - 极简协议
protocol WatchConnectivitySending {
    func sendMessage(_ message: [String: Any]) async throws
}

// MARK: - 极简实现
final class WatchConnectivitySender: NSObject, WatchConnectivitySending {
    
    // MARK: - 属性
    private let session: WCSession
    
    // MARK: - 初始化
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        print("⌚️ Watch: WatchConnectivitySender 初始化")
        setupSession()
    }
    
    // MARK: - 公共方法
    func sendMessage(_ message: [String: Any]) async throws {
        print("⌚️ Watch: 尝试发送消息到 iPhone: \(message)")
        
        // 检查连接状态
        guard session.isReachable else {
            print("⌚️ Watch: ❌ iPhone 不可达")
            throw WatchConnectivityError.deviceNotReachable
        }
        
        print("⌚️ Watch: ✅ iPhone 可达，发送消息...")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message, replyHandler: { response in
                print("⌚️ Watch: ✅ 消息发送成功，iPhone 响应: \(response)")
                continuation.resume()
            }, errorHandler: { error in
                print("⌚️ Watch: ❌ 消息发送失败: \(error)")
                continuation.resume(throwing: error)
            })
        }
    }
    
    // MARK: - 私有方法
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("⌚️ Watch: ❌ WatchConnectivity 不支持")
            return
        }
        
        print("⌚️ Watch: 设置 WatchConnectivity session")
        session.delegate = self
        session.activate()
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivitySender: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("⌚️ Watch: ❌ WatchConnectivity 激活失败: \(error.localizedDescription)")
        } else {
            print("⌚️ Watch: ✅ WatchConnectivity 激活成功，状态: \(activationState.rawValue)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}

// MARK: - 错误类型
enum WatchConnectivityError: LocalizedError {
    case deviceNotReachable
    
    var errorDescription: String? {
        switch self {
        case .deviceNotReachable:
            return "iPhone is not reachable"
        }
    }
} 
