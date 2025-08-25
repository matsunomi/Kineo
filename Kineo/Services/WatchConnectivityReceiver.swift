import Foundation
import WatchConnectivity
import Combine

// MARK: - 极简协议
protocol WatchConnectivityReceiving {
    var numberPublisher: AnyPublisher<String, Never> { get }
    func startReceiving()
}

// MARK: - 极简实现
final class WatchConnectivityReceiver: NSObject, WatchConnectivityReceiving {
    
    // MARK: - 属性
    private let session: WCSession
    private let numberSubject = PassthroughSubject<String, Never>()
    
    var numberPublisher: AnyPublisher<String, Never> {
        numberSubject.eraseToAnyPublisher()
    }
    
    // MARK: - 初始化
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        print("📱 iPhone: WatchConnectivityReceiver 初始化")
        setupSession()
    }
    
    // MARK: - 公共方法
    func startReceiving() {
        print("📱 iPhone: 开始接收数据")
        
        guard WCSession.isSupported() else {
            print("📱 iPhone: ❌ WatchConnectivity 不支持此设备")
            return
        }
        
        print("📱 iPhone: ✅ WatchConnectivity 支持此设备")
        
        if session.activationState != .activated {
            print("📱 iPhone: 激活 WatchConnectivity session...")
            session.activate()
        } else {
            print("📱 iPhone: ✅ WatchConnectivity session 已经激活")
        }
    }
    
    // MARK: - 私有方法
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("📱 iPhone: ❌ WatchConnectivity 不支持")
            return
        }
        
        print("📱 iPhone: 设置 WatchConnectivity session")
        session.delegate = self
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityReceiver: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("📱 iPhone: ❌ WatchConnectivity 激活失败: \(error.localizedDescription)")
        } else {
            print("📱 iPhone: ✅ WatchConnectivity 激活成功，状态: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📱 iPhone: ⚠️ WatchConnectivity session 变为非活跃状态")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("📱 iPhone: ⚠️ WatchConnectivity session 已停用，重新激活...")
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("📱 iPhone: 📨 收到来自 Watch 的消息: \(message)")
        
        if let number = message["number"] as? String {
            print("📱 iPhone: ✅ 收到数字: \(number)")
            numberSubject.send(number)
            replyHandler(["success": true, "number": number])
        } else {
            print("📱 iPhone: ❌ 消息格式无效")
            replyHandler(["error": "Invalid message format"])
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("📱 iPhone: 🔄 Watch 连接状态变化: \(session.isReachable ? "可达" : "不可达")")
    }
} 