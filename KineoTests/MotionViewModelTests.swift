import XCTest
import Combine
@testable import Kineo

@MainActor
final class MotionViewModelTests: XCTestCase {
    // MARK: - Properties
    var sut: MotionViewModel!
    var mockConnectivityReceiver: MockWatchConnectivityReceiver!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockConnectivityReceiver = MockWatchConnectivityReceiver()
        sut = MotionViewModel(connectivityReceiver: mockConnectivityReceiver)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockConnectivityReceiver = nil
        cancellables = []
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_init_shouldSetInitialState() {
        // Then
        XCTAssertNil(sut.currentMotionData)
        XCTAssertFalse(sut.isReceivingData)
        XCTAssertEqual(sut.connectionStatus, .disconnected)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_startReceiving_shouldCallConnectivityReceiverAndUpdateState() {
        // When
        sut.startReceiving()
        
        // Then
        XCTAssertTrue(mockConnectivityReceiver.startReceivingCalled)
        XCTAssertTrue(sut.isReceivingData)
        XCTAssertEqual(sut.connectionStatus, .connecting)
    }
    
    func test_stopReceiving_shouldUpdateState() {
        // Given
        sut.startReceiving()
        
        // When
        sut.stopReceiving()
        
        // Then
        XCTAssertFalse(sut.isReceivingData)
        XCTAssertEqual(sut.connectionStatus, .disconnected)
    }
    
    func test_whenMotionDataReceived_shouldUpdateCurrentMotionData() {
        // Given
        let expectedMotionData = MotionData(
            acceleration: SIMD3<Double>(1.0, 2.0, 3.0),
            rotation: SIMD3<Double>(0.1, 0.2, 0.3)
        )
        
        // When
        mockConnectivityReceiver.simulateMotionData(expectedMotionData)
        
        // Then
        XCTAssertEqual(sut.currentMotionData, expectedMotionData)
        XCTAssertEqual(sut.connectionStatus, .connected)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_whenConnectionStatusChanges_shouldUpdateConnectionStatus() {
        // Given
        sut.startReceiving()
        
        // When
        mockConnectivityReceiver.simulateReachabilityChange(false)
        
        // Then
        // Wait for the timer to update connection status
        let expectation = XCTestExpectation(description: "Connection status updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.connectionStatus, .disconnected)
        XCTAssertEqual(sut.errorMessage, "Apple Watch 连接断开")
    }
}

// MARK: - Mock WatchConnectivityReceiver
class MockWatchConnectivityReceiver: WatchConnectivityReceiving {
    var isReachable: Bool = true
    var startReceivingCalled = false
    var motionDataSubject = PassthroughSubject<MotionData, Never>()
    
    var motionDataPublisher: AnyPublisher<MotionData, Never> {
        motionDataSubject.eraseToAnyPublisher()
    }
    
    func startReceiving() {
        startReceivingCalled = true
    }
    
    func stopReceiving() {
        // Mock implementation
    }
    
    // MARK: - Testing Helpers
    func simulateMotionData(_ data: MotionData) {
        motionDataSubject.send(data)
    }
    
    func simulateReachabilityChange(_ reachable: Bool) {
        isReachable = reachable
    }
} 