import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivityReceiving {
    var isReachable: Bool { get }
    var isWatchPaired: Bool { get }
    var isWatchAppInstalled: Bool { get }
    var motionDataPublisher: AnyPublisher<MotionData, Never> { get }
    var numberPublisher: AnyPublisher<String, Never> { get }
    func startReceiving()
    func stopReceiving()
    func sendCommandToWatch(_ command: String) async throws
}

final class WatchConnectivityReceiver: NSObject, WatchConnectivityReceiving {
    // MARK: - Properties
    private let session: WCSession
    private let motionDataSubject = PassthroughSubject<MotionData, Never>()
    private let numberSubject = PassthroughSubject<String, Never>()
    private let queue = DispatchQueue(label: "com.kineo.watchconnectivity.receiver", qos: .userInitiated)
    
    // MARK: - Public Interface
    var isReachable: Bool {
        let reachable = session.isReachable
        let activationState = session.activationState.rawValue
        print("iPhone: 检查连接状态 - isReachable: \(reachable), 激活状态: \(activationState)")
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
    
    var numberPublisher: AnyPublisher<String, Never> {
        numberSubject.eraseToAnyPublisher()
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
        
        // 打印当前状态
        print("iPhone: 当前状态 - 配对: \(session.isPaired), 安装: \(session.isWatchAppInstalled), 可达: \(session.isReachable)")
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
            
            // 激活成功后，检查状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("iPhone: 🔍 激活后状态检查 - 配对: \(session.isPaired), 安装: \(session.isWatchAppInstalled), 可达: \(session.isReachable)")
            }
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
        print("iPhone: 🔍 消息类型: \(message.keys)")
        
        queue.async { [weak self] in
            guard let self = self else { 
                print("iPhone: ❌ self 已释放")
                replyHandler(["error": "Self deallocated"])
                return 
            }
            
            // 处理运动数据
            if let motionDataData = message["motionData"] as? Data {
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
            // 处理数字数据
            else if let number = message["number"] as? String {
                print("iPhone: ✅ 收到数字: \(number)")
                
                // 发送数据到主线程
                DispatchQueue.main.async {
                    self.numberSubject.send(number)
                }
                
                replyHandler(["success": true, "number": number])
            }
            else {
                print("iPhone: ❌ 消息格式无效，消息内容: \(message)")
                replyHandler(["error": "Invalid message format"])
            }
        }
    }
    
    // 监听连接状态变化
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("iPhone: 🔄 Watch 连接状态变化: \(session.isReachable ? "可达" : "不可达")")
        print("iPhone: 🔍 状态变化时 - 配对: \(session.isPaired), 安装: \(session.isWatchAppInstalled)")
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