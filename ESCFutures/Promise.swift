//
//  Promise.swift
//  ESCFutures
//
//  Created by JARinteractive on 7/24/14.
//  Copyright (c) 2014 Escappe. All rights reserved.
//

public class Box<T> {
	public let value:T
	init(_ theValue:T) {
		value = theValue
	}
}

public enum PromiseResult<T> {
	case success(Box<T>)
	case failure(NSError)
}

public class Promise<T> {
	public private(set) var result: PromiseResult<T>? = nil
	public let future: Future<T> = Future()
	
//	public var value: T? { get { return promiseResult? == .success ? promiseResult. } }
//	public var error: NSError? { get { return promiseResult?.error } }
	
	public init() {}
	
	public func success(value: T) {
		self.complete(.success(Box(value)))
	}
	
	public func failure(error: NSError) {
		self.complete(.failure(error))
	}
	
	public func complete(result: PromiseResult<T>) {
		if (self.result == nil) {
			self.result = result
			future.complete(result)
		}
	}
}