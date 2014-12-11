import XCTest
import ESCFutures

class FutureChainingTest: XCTestCase {
	let manualExecutionContext = ManualExecutionContext()

    override func setUp() {
        super.setUp()
    }
	
	func testWhenMapIsCalledANewFutureIsCreatedWithResult() {
		let testObject:Future<Int> = future(executionContext: manualExecutionContext) {
			return Success(42)
		}
		
		let collectFuture:Future<String> = testObject.collect(executionContext: manualExecutionContext) { number in
			return Success("Hello \(number)")
		}
		
		var actualResult: String? = nil
		
		collectFuture.onSuccess(executionContext: manualExecutionContext) { result in
			actualResult = result
		}
		
		manualExecutionContext.performActions();
		XCTAssertEqual(actualResult!, "Hello 42");
	}
}
