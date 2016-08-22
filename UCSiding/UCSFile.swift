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
    
    private let _course: UCSCourse
    public lazy var course: UCSCourse = { return self._course }()
    /// The path of the folder that contains this file
    public let path: String
    public let name: String
    public let url: String
    
    private var checked = false
    public var isChecked: Bool { return checked }
    
    public var idSidingFolder: String?
    public var idSidingFile: String?
    
    private var _childs: [UCSFile] = []
    public var childs: [UCSFile] { return _childs }
    
    // MARK: - Variables
    
    // MARK: - Init
    
    public init(course: UCSCourse, filename name: String, path: String, url: String, idSidingFolder: String? = nil, idSidingFile: String? = nil) {
        _course = course
        self.path = path
        self.name = name
        self.url = url
        self.idSidingFolder = idSidingFolder
        self.idSidingFile = idSidingFile
    }
    
    // MARK: - Functions
    
    public func justChecked() {
        checked = true
    }
    
    public func pathCompleted() -> String {
        return "\(path)/\(name)"
    }
    
    public func foundChild(child: UCSFile) {
        guard !_childs.contains({ file in file.url == child.url }) else { return }
        _childs.append(child)
    }
    
    public func isChildOf(folder: UCSFile) -> Bool {
        return folder.isParentOf(self)
    }
    
    public func isParentOf(file: UCSFile) -> Bool {
        guard isFolder() else { return false }
        return pathCompleted() == file.path
    }
    
    // MARK: - Helpers
    
    public func isFile() -> Bool {
        return url.containsString(UCSConstant.urlIdentifierFile)
    }
    
    public func isFolder() -> Bool {
        return !isFile()
    }
    
    public func fileExtension() -> String {
        let separated = name.componentsSeparatedByString(".")
        guard let last = separated.last else { return "NO_EXTENSION" }
        return last.uppercaseString
    }
    
}

extension UCSFile: CustomStringConvertible {
    public var description: String {
        return "(\(isFolder() ? "F" : "f")) \(name)\n\(path)\n\(url)"
    }
}