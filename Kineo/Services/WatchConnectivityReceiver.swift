import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivityReceiving {
    var isReachable: Bool { get }
    var motionDataPublisher: AnyPublisher<MotionData, Never> { get }
    func startReceiving()
    func stopReceiving()
}

final class WatchConnectivityReceiver: NSObject, WatchConnectivityReceiving {
    // MARK: - Properties
    private let session: WCSession
    private let motionDataSubject = PassthroughSubject<MotionData, Never>()
    private let queue = DispatchQueue(label: "com.kineo.watchconnectivity.receiver", qos: .userInitiated)
    
    // MARK: - Public Interface
    var isReachable: Bool {
        session.isReachable
    }
    
    var motionDataPublisher: AnyPublisher<MotionData, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        setupSession()
    }
    
    // MARK: - Public Methods
    func startReceiving() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity is not supported on this device")
            return
        }
        
        if session.activationState != .activated {
            session.activate()
        }
    }
    
    func stopReceiving() {
        // WatchConnectivity 不需要显式停止
    }
    
    // MARK: - Private Methods
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityReceiver: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity activation failed: \(error.localizedDescription)")
        } else {
            print("WatchConnectivity activated successfully")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WatchConnectivity session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WatchConnectivity session deactivated, reactivating...")
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        queue.async { [weak self] in
            guard let self = self,
                  let motionDataData = message["motionData"] as? Data else {
                replyHandler(["error": "Invalid message format"])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let motionData = try decoder.decode(MotionData.self, from: motionDataData)
                
                // 发送数据到主线程
                DispatchQueue.main.async {
                    self.motionDataSubject.send(motionData)
                }
                
                replyHandler(["success": true])
            } catch {
                print("Failed to decode motion data: \(error)")
                replyHandler(["error": "Failed to decode motion data"])
            }
        }
    }
} 