//
//  ActivityIndicator.swift
//  Wifi UC
//
//  Created by Nicolás Gebauer on 29-02-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

#if os(iOS)
    import UIKit
#endif

internal class UCSActivityIndicator {
    
    // MARK: - Constants
    
    static let shared = UCSActivityIndicator()
    
    #if os(iOS)
    let application = UIApplication.shared
    #endif
    
    // MARK: - Variables
    
    var taskCount = 0
    
    #if os(iOS)
    var networkActivityIndicatorVisible: Bool {
        get {
            return application.isNetworkActivityIndicatorVisible
        } set (visible) {
            application.isNetworkActivityIndicatorVisible = visible
        }
    }
    #endif
    
    #if !os(iOS)
    var networkActivityIndicatorVisible = false
    #endif
    
    // MARK: - Init
    
    // MARK: - Functions
    
    func startTask() {
        taskCount += 1
        updateIndicator()
    }
    
    func endTask() {
        guard taskCount > 0 else {
            return print("WARNING: Ending a network task when there a no tasks")
        }
        taskCount -= 1
        updateIndicator()
    }
    
    func updateIndicator() {
        if taskCount > 0 {
            if !networkActivityIndicatorVisible {
                networkActivityIndicatorVisible = !networkActivityIndicatorVisible
            }
        } else if taskCount == 0 {
            if networkActivityIndicatorVisible {
                networkActivityIndicatorVisible = !networkActivityIndicatorVisible
            }
        }
    }
    
}
