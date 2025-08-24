import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivitySending {
    var isReachable: Bool { get }
    func sendMotionData(_ data: MotionData) async throws
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
        setupSession()
    }
    
    // MARK: - Public Interface
    var isReachable: Bool {
        session.isReachable
    }
    
    func sendMotionData(_ data: MotionData) async throws {
        guard session.isReachable else {
            throw WatchConnectivityError.deviceNotReachable
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(data)
        let message = ["motionData": data]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message, replyHandler: { _ in
                continuation.resume()
            }, errorHandler: { error in
                continuation.resume(throwing: error)
            })
        }
    }
    
    func startListeningForCommands() {
        // 开始监听来自 iPhone 的命令
        print("Watch: 开始监听来自 iPhone 的命令")
    }
    
    // MARK: - Private Methods
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }
    
    func setCommandHandler(_ handler: @escaping (String) -> Void) {
        commandHandler = handler
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivitySender: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity activation failed: \(error.localizedDescription)")
        } else {
            print("Watch: WatchConnectivity 激活成功")
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
        queue.async { [weak self] in
            guard let self = self,
                  let command = message["command"] as? String else {
                replyHandler(["error": "Invalid command format"])
                return
            }
            
            print("Watch: 收到来自 iPhone 的命令: \(command)")
            
            // 处理命令
            self.commandHandler?(command)
            
            replyHandler(["success": true, "command": command])
        }
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