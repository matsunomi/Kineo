import Foundation
import Combine

// MARK: - 极简 ViewModel
@MainActor
final class MotionViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var receivedNumber: Int = 0
    
    // MARK: - 私有属性
    private let connectivityReceiver: WatchConnectivityReceiving
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    init(connectivityReceiver: WatchConnectivityReceiving = WatchConnectivityReceiver()) {
        self.connectivityReceiver = connectivityReceiver
        print("📱 iPhone: MotionViewModel 初始化")
        setupBindings()
        startReceiving()
    }
    
    // MARK: - 公共方法
    func startReceiving() {
        print("📱 iPhone: 开始接收数据")
        connectivityReceiver.startReceiving()
    }
    
    // MARK: - 私有方法
    private func setupBindings() {
        print("📱 iPhone: 设置数据绑定")
        
        connectivityReceiver.numberPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                print("📱 iPhone: 收到数字: \(number)")
                if let numberInt = Int(number) {
                    self?.receivedNumber += numberInt
                    print("📱 iPhone: 累积数字: \(self?.receivedNumber ?? 0)")
                }
            }
            .store(in: &cancellables)
    }
} 