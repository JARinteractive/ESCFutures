import XCTest
import ESCFutures

class FuturePerformanceTest: XCTestCase {
	func testPerformanceExample() {
		self.measureBlock() {
			var completionCount = 0
			for futureCount in 0..<1000 {
				let aFuture:Future<Int> = future {
					return Success(1)
				}
				
				aFuture.onSuccess { result in
					completionCount = completionCount + result
				}
			}

			XCTAssert(waitUntil(60.0) { return completionCount == 1000 })
        }
    }
}
