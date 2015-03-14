import XCTest
import ESCFutures

class FuturePerformanceTest: XCTestCase {
	func testFuturePerformance() {
		self.measureBlock() {
			var completionCount = 0
			for futureCount in 0..<1000 {
				let aFuture:Future<Int> = future {
					return Success(1)
				}
				
				aFuture.onSuccess { result in
					completionCount++;
					//completionCount = completionCount + result //can result in same number twice under high load
				}
			}

			let success = waitUntil(60.0) {completionCount == 1000}
			XCTAssertTrue(success)
        }
    }
}
