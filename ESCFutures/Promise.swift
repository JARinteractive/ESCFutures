//
//  Promise.swift
//  ESCFutures
//
//  Created by JARinteractive on 7/24/14.
//  Copyright (c) 2014 Escappe. All rights reserved.
//

public struct PromiseResult<T> {
	var value:T?
	var error:NSError?
}

public class Promise<T> {
	var promiseResult: PromiseResult<T>? = nil
	public let future: Future<T> = Future()
	
	public var value: T? { get { return promiseResult?.value } }
	public var error: NSError? { get { return promiseResult?.error } }
	
	public init() {}
	
	public func success(value: T) {
		if (promiseResult == nil) {
			let result = PromiseResult(value: value, error: nil)
			promiseResult = result
			future.complete(result)
		}
	}
	
	public func failure(error: NSError) {
		if (promiseResult == nil) {
			let result = PromiseResult<T>(value: nil, error: error)
			promiseResult = result
			future.complete(result)
		}
	}
}