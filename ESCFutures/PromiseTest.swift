//
//  PromiseTest.swift
//  ESCFutures
//
//  Created by JARinteractive on 7/24/14.
//  Copyright (c) 2014 Escappe. All rights reserved.
//

import XCTest
import ESCFutures

func promiseResultValue<T>(result:PromiseResult<T>?) -> T? {
	let (value, _) = promiseResultTuple(result)
	return value
}

func promiseResultError<T>(result:PromiseResult<T>?) -> NSError? {
	let (_, error) = promiseResultTuple(result)
	return error
}

func promiseResultTuple<T>(result:PromiseResult<T>?) -> (T?, NSError?) {
	var promiseValue:T? = nil
	var promiseError:NSError? = nil
	if let result = result {
		switch result {
		case .success(let value):
			promiseValue = value.value
		case .failure(let error):
			promiseError = error
		}
	}
	return (promiseValue, promiseError)
}

class PromiseTest : XCTestCase {
	func testPromiseHasValueWhenSuccessIsCalled() {
		let testObject = Promise<String>()
		XCTAssertTrue(testObject.result == nil)
		
		testObject.success("Hello World")
		
		XCTAssertEqual(promiseResultValue(testObject.result)!, "Hello World")
	}
	
	func testPromiseHasInitialValueWhenSuccessIsCalled() {
		let testObject = Promise<String>()
		XCTAssertTrue(testObject.result == nil)
		
		testObject.success("Hello World")
		testObject.success("Hello Other World")
		
		XCTAssertEqual(promiseResultValue(testObject.result)!, "Hello World")
	}
	
	func testPromiseHasErrorWhenFailureIsCalled() {
		let error = NSError(domain: "2", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error);
		
		XCTAssertEqual(promiseResultError(testObject.result)!, error)
	}
	
	func testPromiseHasInitialErrorWhenFailureIsCalled() {
		let error1 = NSError(domain: "1", code: 1, userInfo: nil)
		let error2 = NSError(domain: "2", code: 2, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error1);
		testObject.failure(error2);
		
		XCTAssertEqual(promiseResultError(testObject.result)!, error1)
	}
	
	func testPromiseHasInitialErrorWhenFailureThenSuccessIsCalled() {
		let error = NSError(domain: "1", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error);
		testObject.success("33");
		
		XCTAssertEqual(promiseResultError(testObject.result)!, error)
	}
	
	func testPromiseHasInitialValueWhenSuccessThenFailureIsCalled() {
		let error = NSError(domain: "1", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.success("33");
		testObject.failure(error);
		
		XCTAssertEqual(promiseResultValue(testObject.result)!, "33")
	}
}