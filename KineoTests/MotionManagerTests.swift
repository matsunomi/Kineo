import XCTest
import Combine
@testable import Kineo

final class MotionManagerTests: XCTestCase {
    // MARK: - Properties
    var sut: MotionManager!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = MotionManager()
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState_ShouldHaveNoMotionData() {
        let expectation = expectation(description: "Initial state should have no motion data")
        
        sut.currentMotionDataPublisher
            .sink { motionData in
                XCTAssertNil(motionData)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Device Motion Tests
    func testDeviceMotionAvailability_ShouldBeChecked() {
        XCTAssertNotNil(sut)
        // Note: We can't test the actual device motion availability as it depends on the device
    }
    
    // MARK: - Error Handling
    func testSimulatorEnvironment_ShouldHandleGracefully() {
        // Given
        let manager = MotionManager()
        
        // Then
        XCTAssertNotNil(manager)
        // Note: We can't test actual error handling in unit tests as it requires device motion
    }
} 