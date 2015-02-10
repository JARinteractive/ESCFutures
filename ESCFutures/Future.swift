import Foundation

public func Success<T>(value: T) -> PromiseResult<T> {
	return PromiseResult(value: value, error: nil);
}

public func Failure<T>(error: NSError) -> PromiseResult<T> {
	return PromiseResult(value: nil, error: error);
}

public func future<T>(executionContext context: ExecutionContext = DefaultFutureExecutionContext(), action: ()->PromiseResult<T>) -> Future<T> {
	let promise = Promise<T>();
	context.run {
		let result = action()
		if let value = result.value {
			promise.success(value)
		} else if let error = result.error {
			promise.failure(error);
		}
	}
	return promise.future
}

public func future<T: Any>(executionContext context: ExecutionContext = DefaultFutureExecutionContext(), action: ()->(T)) -> Future<T> {
	return future(executionContext: DefaultFutureExecutionContext(), { return Success(action()) })
}

public class Future<T: Any> {
	private var successCallbacks:[FutureCallback<T>] = []
	private var failureCallbacks:[FutureCallback<NSError>] = []
	private var result:(value: T?, error: NSError?)?
	private let sync = Synchronizer()
	
	init() {}
	
	func complete(promiseResult: PromiseResult<T>) {
		result = (promiseResult.value, promiseResult.error)
		self.maybeRunCallbacks()
	}
	
	public func collect<U: Any>(executionContext context: ExecutionContext = DefaultFutureExecutionContext(), action: (T)->PromiseResult<U>) -> Future<U> {
		let promise = Promise<U>();
		
		self.onSuccess(executionContext: context) { thisResult in
			let result = action(thisResult)
			if let value = result.value {
				promise.success(value)
			} else if let error = result.error {
				promise.failure(error)
			}
		}
		
		return promise.future
	}
	
	public func collect<U: Any>(executionContext context: ExecutionContext = DefaultFutureExecutionContext(), action: (T)->U) -> Future<U> {
		return collect(executionContext: context, action: { thisResult in return Success(action(thisResult)) } )
	}
	
	public func isComplete() -> Bool { return result != nil ? true : false }
	
	public func value() -> T? { return result?.value }
	
	public func onSuccess(callback:(T)->()) { self.onSuccess(executionContext: MainExecutionContext(), callback: callback) }
	
	public func onFailure(callback:(NSError)->()) { self.onFailure(executionContext: MainExecutionContext(), callback: callback) }
	
	public func onSuccess(#executionContext: ExecutionContext, callback:(T)->()) {
		let successCallback = FutureCallback(callback: callback, executionContext: executionContext)
		sync.run {
			self.successCallbacks.append(successCallback)
		}
		maybeRunCallbacks()
	}
	
	public func onFailure(#executionContext: ExecutionContext, callback:(NSError)->()) {
		let failureCallback = FutureCallback(callback: callback, executionContext: executionContext)
		sync.run {
			self.failureCallbacks.append(failureCallback)
		}
		maybeRunCallbacks()
	}
	
	private func maybeRunCallbacks() {
		if let futureResult = result {
			let callbacks = clearAndReturnCallbacks()
			if let error = futureResult.error {
				RunFutureCallbacks(callbacks.failureCallbacks, error)
			} else if let value = futureResult.value {
				RunFutureCallbacks(callbacks.successCallbacks, value)
			}
		}
	}
	
	private func clearAndReturnCallbacks() -> (successCallbacks:[FutureCallback<T>], failureCallbacks:[FutureCallback<NSError>]) {
		var callbacks:([FutureCallback<T>], [FutureCallback<NSError>])?
		sync.run {
			callbacks = (self.successCallbacks, self.failureCallbacks);
			self.successCallbacks.removeAll()
			self.failureCallbacks.removeAll()
		}
		return callbacks!
	}
}

private func RunFutureCallbacks<T: Any>(callbacks:Array<FutureCallback<T>>, parameter:T) {
	for callback in callbacks {
		callback.executionContext.run {
			callback.callback(parameter)
		}
	}
}

private struct FutureCallback<T: Any> {
	let callback:(T)->()
	let executionContext:ExecutionContext
}

private func DefaultFutureExecutionContext() -> ExecutionContext {
	struct SingletonCaptor {
		static let instance : NSOperationQueueExecutionContext = {
			let operationQueue = NSOperationQueue()
			operationQueue.maxConcurrentOperationCount = 4
			return NSOperationQueueExecutionContext(operationQueue: operationQueue)
			}()
	}
	return SingletonCaptor.instance
}