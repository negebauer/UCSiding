//
//  UCSFile.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

/// A file or folder found in a Siding course
public class UCSFile {
    
    // MARK: - Constants
    
    public let course: UCSCourse
    public let path: String
    public let name: String
    
    // MARK: - Variables
    
    // MARK: - Init
    
    public init(course: UCSCourse, filename name: String, path: String) {
        self.course = course
        self.path = path
        self.name = name
    }
    
    // MARK: - Helpers
    
    public func isFile() -> Bool {
        let split = name.componentsSeparatedByString(".")
        if split.count > 1 && split[(split.count ?? 1) - 1].characters.count < 5 {
            return true
        }
        return false
    }
    
    public func isFolder() -> Bool {
        return !isFile()
    }
    
}