//
//  UCSQueue.swift
//  Pods
//
//  Created by Nicolás Gebauer on 14-07-16.
//
//

internal struct UCSQueue {
    
    static private let serialQueue = dispatch_queue_create(UCSConstant.bundleId + ".serialQueue", DISPATCH_QUEUE_SERIAL)
    
    /// A custom background serial queue
    static internal func serial(block: () -> Void) {
        dispatch_async(serialQueue, {
            block()
        })
    }
}