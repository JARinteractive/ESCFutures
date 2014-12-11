//
//  PromiseTest.swift
//  ESCFutures
//
//  Created by JARinteractive on 7/24/14.
//  Copyright (c) 2014 Escappe. All rights reserved.
//

import XCTest
import ESCFutures

class PromiseTest : XCTestCase {
	func testPromiseHasValueWhenSuccessIsCalled() {
		let testObject = Promise<String>()
		XCTAssertNil(testObject.value)
		
		testObject.success("Hello World")
		
		XCTAssertEqual(testObject.value!, "Hello World")
	}
	
	func testPromiseHasInitialValueWhenSuccessIsCalled() {
		let testObject = Promise<String>()
		XCTAssertNil(testObject.value)
		
		testObject.success("Hello World")
		testObject.success("Hello Other World")
		
		XCTAssertEqual(testObject.value!, "Hello World")
	}
	
	func testPromiseHasErrorWhenFailureIsCalled() {
		let error = NSError(domain: "2", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error);
		
		XCTAssertNil(testObject.value)
		XCTAssertEqual(testObject.error!, error)
	}
	
	func testPromiseHasInitialErrorWhenFailureIsCalled() {
		let error1 = NSError(domain: "1", code: 1, userInfo: nil)
		let error2 = NSError(domain: "2", code: 2, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error1);
		testObject.failure(error2);
		
		XCTAssertNil(testObject.value)
		XCTAssertEqual(testObject.error!, error1)
	}
	
	func testPromiseHasInitialErrorWhenFailureThenSuccessIsCalled() {
		let error = NSError(domain: "1", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.failure(error);
		testObject.success("33");
		
		XCTAssertNil(testObject.value)
		XCTAssertEqual(testObject.error!, error)
	}
	
	func testPromiseHasInitialValueWhenSuccessTHenFailureIsCalled() {
		let error = NSError(domain: "1", code: 1, userInfo: nil)
		let testObject = Promise<String>()
		
		testObject.success("33");
		testObject.failure(error);
		
		XCTAssertEqual(testObject.value!, "33")
		XCTAssertNil(testObject.error)
	}
}