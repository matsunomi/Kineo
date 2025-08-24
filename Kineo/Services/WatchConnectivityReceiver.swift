import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivityReceiving {
    var isReachable: Bool { get }
    var isWatchPaired: Bool { get }
    var isWatchAppInstalled: Bool { get }
    var motionDataPublisher: AnyPublisher<MotionData, Never> { get }
    func startReceiving()
    func stopReceiving()
    func sendCommandToWatch(_ command: String) async throws
}

final class WatchConnectivityReceiver: NSObject, WatchConnectivityReceiving {
    // MARK: - Properties
    private let session: WCSession
    private let motionDataSubject = PassthroughSubject<MotionData, Never>()
    private let queue = DispatchQueue(label: "com.kineo.watchconnectivity.receiver", qos: .userInitiated)
    
    // MARK: - Public Interface
    var isReachable: Bool {
        let reachable = session.isReachable
        print("iPhone: 检查连接状态 - isReachable: \(reachable)")
        return reachable
    }
    
    var isWatchPaired: Bool {
        let paired = session.isPaired
        print("iPhone: 检查 Watch 配对状态 - isPaired: \(paired)")
        return paired
    }
    
    var isWatchAppInstalled: Bool {
        let installed = session.isWatchAppInstalled
        print("iPhone: 检查 Watch 应用安装状态 - isWatchAppInstalled: \(installed)")
        return installed
    }
    
    var motionDataPublisher: AnyPublisher<MotionData, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        print("iPhone: WatchConnectivityReceiver 初始化")
        setupSession()
    }
    
    // MARK: - Public Methods
    func startReceiving() {
        print("iPhone: 开始接收数据")
        guard WCSession.isSupported() else {
            print("iPhone: ❌ WatchConnectivity 不支持此设备")
            return
        }
        
        print("iPhone: ✅ WatchConnectivity 支持此设备")
        print("iPhone: 当前激活状态: \(session.activationState.rawValue)")
        
        if session.activationState != .activated {
            print("iPhone: 激活 WatchConnectivity session...")
            session.activate()
        } else {
            print("iPhone: ✅ WatchConnectivity session 已经激活")
        }
    }
    
    func stopReceiving() {
        print("iPhone: 停止接收数据")
        // WatchConnectivity 不需要显式停止
    }
    
    func sendCommandToWatch(_ command: String) async throws {
        print("iPhone: 尝试发送命令到 Watch: \(command)")
        guard session.isReachable else {
            print("iPhone: ❌ Watch 不可达")
            throw WatchConnectivityError.deviceNotReachable
        }
        
        print("iPhone: ✅ Watch 可达，发送命令...")
        let message = ["command": command]
        
        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message, replyHandler: { response in
                print("iPhone: ✅ Watch 响应命令成功: \(response)")
                continuation.resume()
            }, errorHandler: { error in
                print("iPhone: ❌ 发送命令失败: \(error)")
                continuation.resume(throwing: error)
            })
        }
    }
    
    // MARK: - Private Methods
    private func setupSession() {
        guard WCSession.isSupported() else { 
            print("iPhone: ❌ WatchConnectivity 不支持")
            return 
        }
        print("iPhone: 设置 WatchConnectivity session")
        session.delegate = self
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityReceiver: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("iPhone: ❌ WatchConnectivity 激活失败: \(error.localizedDescription)")
        } else {
            print("iPhone: ✅ WatchConnectivity 激活成功，状态: \(activationState.rawValue)")
            print("iPhone: Watch 配对状态: \(session.isPaired)")
            print("iPhone: Watch 安装状态: \(session.isWatchAppInstalled)")
            print("iPhone: Watch 可达状态: \(session.isReachable)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iPhone: ⚠️ WatchConnectivity session 变为非活跃状态")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iPhone: ⚠️ WatchConnectivity session 已停用，重新激活...")
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("iPhone: 📨 收到来自 Watch 的消息: \(message)")
        queue.async { [weak self] in
            guard let self = self,
                  let motionDataData = message["motionData"] as? Data else {
                print("iPhone: ❌ 消息格式无效")
                replyHandler(["error": "Invalid message format"])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let motionData = try decoder.decode(MotionData.self, from: motionDataData)
                
                print("iPhone: ✅ 成功解码运动数据")
                
                // 发送数据到主线程
                DispatchQueue.main.async {
                    self.motionDataSubject.send(motionData)
                }
                
                replyHandler(["success": true])
            } catch {
                print("iPhone: ❌ 解码运动数据失败: \(error)")
                replyHandler(["error": "Failed to decode motion data"])
            }
        }
    }
    
    // 监听连接状态变化
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("iPhone: 🔄 Watch 连接状态变化: \(session.isReachable ? "可达" : "不可达")")
    }
}

// MARK: - Errors
enum WatchConnectivityError: LocalizedError {
    case deviceNotReachable
    
    var errorDescription: String? {
        switch self {
        case .deviceNotReachable:
            return "Apple Watch is not reachable"
        }
    }
} 