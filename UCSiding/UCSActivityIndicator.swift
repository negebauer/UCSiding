//
//  ActivityIndicator.swift
//  Wifi UC
//
//  Created by Nicolás Gebauer on 29-02-16.
//  Copyright © 2016 Nicolás Gebauer. All rights reserved.
//

import UIKit

internal class UCSActivityIndicator {
    
    // MARK: - Constants
    
    static let shared = UCSActivityIndicator()
    let application = UIApplication.sharedApplication()
    
    // MARK: - Variables
    
    var taskCount = 0
    var networkActivityIndicatorVisible: Bool {
        get {
            return application.networkActivityIndicatorVisible
        } set (visible) {
            application.networkActivityIndicatorVisible = visible
        }
    }
    
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