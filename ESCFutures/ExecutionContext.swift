import Foundation

public protocol ExecutionContext {
	func run(()->())
}

public struct GCDExecutionContext : ExecutionContext {
	let queue:dispatch_queue_t
	public init(dispatchQueue:dispatch_queue_t) {
		queue = dispatchQueue
	}
	public func run(action:()->()) {
		dispatch_async(queue, action)
	}
}

public struct NSOperationQueueExecutionContext : ExecutionContext {
	let queue:NSOperationQueue
	public init(operationQueue:NSOperationQueue) {
		queue = operationQueue
	}
	public func run(action:()->()) {
		queue.addOperation(NSBlockOperation(block: action))
	}
}

public func BackgroundExecutionContext() -> ExecutionContext {
	return GCDExecutionContext(dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
}

public func MainExecutionContext() -> ExecutionContext {
	return GCDExecutionContext(dispatchQueue: dispatch_get_main_queue())
}