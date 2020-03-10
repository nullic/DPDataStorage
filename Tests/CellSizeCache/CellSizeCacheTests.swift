import XCTest
@testable import CellSizeCache
@testable import DataSource

class CellSizeCacheTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInvalidate() {
        let controller = DPArrayController(delegate: nil)
        let array = [TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2")]
        
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()
        
        let cache = CellSizeCache(container: controller)
        let indexPath = IndexPath(indexes: [0, 0])
        
        XCTAssert(cache[indexPath] == nil)
        cache[indexPath] = .zero
        XCTAssert(cache[indexPath] == .zero)
        
        cache.invalidate()
        XCTAssert(cache[indexPath] == nil)
    }
    
    func testInsertItems() {
        let controller = DPArrayController(delegate: nil)
        let array = [TestObject(section: "1", value: "3"), TestObject(section: "1", value: "1"), TestObject(section: "1", value: "2")]
        
        controller.startUpdating()
        controller.setObjects(array, atSection: 0)
        controller.endUpdating()

        let cache = CellSizeCache(container: controller)
        let indexPath = IndexPath(indexes: [0, 0])

        cache[indexPath] = .zero
        XCTAssert(cache[indexPath] == .zero)
        
        controller.startUpdating()
        cache.startUpdating()
        
        controller.insertSection(at: 0)
        cache.insertSection(at: 0)
        
        controller.insert(TestObject(section: "0", value: "0"), atIndextPath: indexPath)
        cache.insert(at: indexPath)
        
        cache.endUpdating()
        controller.endUpdating()
        
        XCTAssert(cache[indexPath] == nil)
        XCTAssert(cache[IndexPath(indexes: [1, 0])] == .zero)
    }
}
