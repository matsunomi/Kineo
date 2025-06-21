import Foundation
import WatchConnectivity
import Combine

protocol WatchConnectivitySending {
    var isReachable: Bool { get }
    func sendMotionData(_ data: MotionData) async throws
}

final class WatchConnectivitySender: NSObject, WatchConnectivitySending {
    // MARK: - Properties
    private let session: WCSession
    private let queue = DispatchQueue(label: "com.kineo.watchconnectivity", qos: .userInitiated)
    
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
    
    // MARK: - Private Methods
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivitySender: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivity activation failed: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
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