import XCTest
import Combine
@testable import Kineo

@MainActor
final class MotionViewModelTests: XCTestCase {
    // MARK: - Properties
    var sut: MotionViewModel!
    var mockMotionManager: MockMotionManager!
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockMotionManager = MockMotionManager()
        sut = MotionViewModel(motionManager: mockMotionManager)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockMotionManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState_ShouldHaveNoMotionData() {
        XCTAssertNil(sut.motionData)
    }
    
    // MARK: - Data Flow Tests
    func testMotionDataUpdate_ShouldUpdateViewModelWithNewData() {
        // Given
        let expectation = expectation(description: "Motion data should be updated")
        let testData = MotionData(
            acceleration: SIMD3<Double>(1.0, 2.0, 3.0),
            rotation: SIMD3<Double>(4.0, 5.0, 6.0)
        )
        
        // When
        mockMotionManager.simulateMotionData(testData)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.sut.motionData)
            XCTAssertEqual(self.sut.motionData?.acceleration.x, 1.0)
            XCTAssertEqual(self.sut.motionData?.acceleration.y, 2.0)
            XCTAssertEqual(self.sut.motionData?.acceleration.z, 3.0)
            XCTAssertEqual(self.sut.motionData?.rotation.x, 4.0)
            XCTAssertEqual(self.sut.motionData?.rotation.y, 5.0)
            XCTAssertEqual(self.sut.motionData?.rotation.z, 6.0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMotionDataRemoval_ShouldClearViewModelData() {
        // Given
        let expectation = expectation(description: "Motion data should be cleared")
        let testData = MotionData(
            acceleration: SIMD3<Double>(1.0, 2.0, 3.0),
            rotation: SIMD3<Double>(4.0, 5.0, 6.0)
        )
        
        // When
        mockMotionManager.simulateMotionData(testData)
        mockMotionManager.simulateNoMotionData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.sut.motionData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    func testMultipleDataUpdates_ShouldAlwaysReflectLatestData() {
        // Given
        let expectation = expectation(description: "Latest motion data should be reflected")
        let firstData = MotionData(
            acceleration: SIMD3<Double>(1.0, 2.0, 3.0),
            rotation: SIMD3<Double>(4.0, 5.0, 6.0)
        )
        let secondData = MotionData(
            acceleration: SIMD3<Double>(7.0, 8.0, 9.0),
            rotation: SIMD3<Double>(10.0, 11.0, 12.0)
        )
        
        // When
        mockMotionManager.simulateMotionData(firstData)
        mockMotionManager.simulateMotionData(secondData)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.motionData?.acceleration.x, 7.0)
            XCTAssertEqual(self.sut.motionData?.acceleration.y, 8.0)
            XCTAssertEqual(self.sut.motionData?.acceleration.z, 9.0)
            XCTAssertEqual(self.sut.motionData?.rotation.x, 10.0)
            XCTAssertEqual(self.sut.motionData?.rotation.y, 11.0)
            XCTAssertEqual(self.sut.motionData?.rotation.z, 12.0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 