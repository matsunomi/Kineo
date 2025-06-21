import XCTest
import Combine
@testable import Kineo

final class WatchMotionManagerTests: XCTestCase {
    // MARK: - Properties
    private var sut: WatchMotionManagerTests
    private var mockConnectivitySender: MockWatchConnectivitySender!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockConnectivitySender = MockWatchConnectivitySender()
        sut = WatchMotionManagerTests(connectivitySender: mockConnectivitySender)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockConnectivitySender = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitialState_ShouldHaveNoMotionData() {
        // Given
        let expectation = expectation(description: "Initial state should be nil")
        
        // When
        sut.currentMotionDataPublisher
            .sink { motionData in
                // Then
                XCTAssertNil(motionData)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStartUpdates_WhenDeviceMotionNotAvailable_ShouldThrowError() {
        // Given
        mockConnectivitySender.isReachable = false
        
        // When/Then
        XCTAssertThrowsError(try sut.startUpdates()) { error in
            XCTAssertEqual(error as? MotionError, .deviceMotionNotAvailable)
        }
    }
    
    func testStopUpdates_ShouldClearMotionData() {
        // Given
        let expectation = expectation(description: "Motion data should be cleared")
        expectation.expectedFulfillmentCount = 2
        
        var receivedValues: [MotionData?] = []
        
        sut.currentMotionDataPublisher
            .sink { motionData in
                receivedValues.append(motionData)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        try? sut.startUpdates()
        sut.stopUpdates()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues.count, 2)
        XCTAssertNil(receivedValues.last)
    }
}

// MARK: - Mocks
private class MockWatchConnectivitySender: WatchConnectivitySending {
    var isReachable: Bool = true
    
    func sendMotionData(_ data: MotionData) async throws {
        // No-op for testing
    }
} 
