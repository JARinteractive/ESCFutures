import Foundation
import XCTest
import ESCFutures

func waitUntil(checkSuccess:()->Bool) -> Bool {
	return  waitUntil(1.0, checkSuccess)
}

func waitUntil(timeout: Double, checkSuccess:()->Bool) -> Bool {
	let startDate = NSDate()
	var success = false
	while !success && abs(startDate.timeIntervalSinceNow) < timeout {
		NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.01))
		success = checkSuccess()
	}
	return success
}

class ManualExecutionContext : ExecutionContext {
	var actions:[(() -> ())] = []
	
	func run(runAction: () -> ()) {
		actions.append(runAction)
	}
	
	func performActions() {
		let runningActions = actions
		actions.removeAll()
		for action in runningActions {
			action()
		}
		if actions.count > 0 {
			performActions()
		}
	}
}

class FutureTest:XCTestCase {
	let manualExecutionContext = ManualExecutionContext()
	
	func testWhenFutureCompletesThenValueIsPopulated() {
		let testObject:Future<Int> = future {
			XCTAssertFalse(NSThread.isMainThread())
			NSThread.sleepForTimeInterval(0.025)
			return Success(42)
		}
		
		XCTAssert(waitUntil { testObject.isComplete() })
		XCTAssertEqual(testObject.value()!, 42)
	}
	
	func testWhenFutureCompletesThenSuccessCallbackIsPopulated() {
		var actualResult: Int? = nil
		let testObject:Future<Int> = future {
			NSThread.sleepForTimeInterval(0.025)
			return Success(42)
		}
		
		testObject.onSuccess { result in
			XCTAssertTrue(NSThread.isMainThread())
			actualResult = result
		}
		
		XCTAssert(waitUntil { actualResult != nil })
		XCTAssertEqual(actualResult!, 42);
	}
	
	func testWhenFutureCompletesWithErrorThenFailureCallbackIsCalled() {
		let error = NSError()
		var actualError: NSError? = nil
		
		let testObject:Future<Int> = future(executionContext:BackgroundExecutionContext()) {
			NSThread.sleepForTimeInterval(0.025)
			return Failure(error)
		}
		
		testObject.onFailure { error in
			actualError = error;
		}
		
		XCTAssert(waitUntil { actualError != nil })
		XCTAssertEqual(actualError!, error)
	}
	
	func testWhenSuccessCallbackIsAddedAfterCompletionItIsRun() {
		var actualResult: Int? = nil
		let testObject:Future<Int> = future() {
			NSThread.sleepForTimeInterval(0.025)
			return Success(42)
		}
		
		XCTAssert(waitUntil { testObject.isComplete() })
		
		testObject.onSuccess { result in
			actualResult = result
		}
		XCTAssert(waitUntil { actualResult != nil })
		XCTAssertEqual(actualResult!, 42);
	}
	
	func testWhenFailureCallbackIsAddedAfterCompletionItIsRun() {
		let error = NSError()
		var actualError: NSError? = nil
		
		let testObject:Future<Int> = future(executionContext:BackgroundExecutionContext()) {
			NSThread.sleepForTimeInterval(0.025)
			return Failure(error)
		}
		
		XCTAssert(waitUntil { testObject.isComplete() })
		
		testObject.onFailure { error in
			actualError = error;
		}
		XCTAssert(waitUntil { actualError != nil })
		XCTAssertEqual(actualError!, error)
	}
	
	func testWhenExecutionContextIsSpecifiedThenItIsUsed() {
		var actualResult: Int? = nil
		let testObject:Future<Int> = future(executionContext: manualExecutionContext) {
			return Success(42)
		}
		XCTAssertNil(testObject.value());
		manualExecutionContext.performActions();
		XCTAssertEqual(testObject.value()!, 42);
		
		testObject.onSuccess(executionContext: manualExecutionContext) { result in
			actualResult = result
		}
		
		XCTAssertNil(actualResult);
		manualExecutionContext.performActions();
		XCTAssertEqual(actualResult!, 42);
	}
}