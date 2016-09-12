//
//  UCSQueue.swift
//  Pods
//
//  Created by Nicolás Gebauer on 14-07-16.
//
//

internal struct UCSQueue {
    
    static fileprivate let serialQueue = DispatchQueue(label: UCSConstant.bundleId + ".serialQueue", attributes: [])
    
    /// A custom background serial queue
    static internal func serial(_ block: @escaping () -> Void) {
        serialQueue.async(execute: {
            block()
        })
    }
}
