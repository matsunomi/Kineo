import Foundation

// MARK: - 极简 Watch ViewModel
@MainActor
final class WatchMotionViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var clickCount: Int = 0
    
    // MARK: - 私有属性
    private let connectivitySender: any WatchConnectivitySending
    
    // MARK: - 初始化
    init(connectivitySender: any WatchConnectivitySending = WatchConnectivitySender()) {
        self.connectivitySender = connectivitySender
        print("⌚️ Watch: WatchMotionViewModel 初始化")
    }
    
    // MARK: - 公共方法
    func sendNumberToiPhone(_ number: String) async throws {
        print("⌚️ Watch: 准备发送数字: \(number)")
        
        let message = ["number": number]
        try await connectivitySender.sendMessage(message)
        
        clickCount += 1
        print("⌚️ Watch: 数字发送成功，点击次数: \(clickCount)")
    }
} 

