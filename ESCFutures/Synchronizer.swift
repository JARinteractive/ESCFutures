import Foundation

class Synchronizer {
	let queue = dispatch_queue_create("synchronization queue", DISPATCH_QUEUE_SERIAL)
	
	func run(action:()->()) {
		dispatch_sync(queue, action)
	}
	
//	deinit {
//		dispatch_release(queue)
//	}
}