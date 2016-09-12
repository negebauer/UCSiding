//
//  UCSFile.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

public protocol UCSFileDelegate {
    func downloadProgress(_ progress: Float)
    func downloadFinished(_ fileURL: URL)
}

/// A file or folder found in a Siding course
open class UCSFile {
    
    // MARK: - Constants
    
    fileprivate let _course: UCSCourse
    open lazy var course: UCSCourse = { return self._course }()
    /// The path of the folder that contains this file
    open let path: String
    open let name: String
    open let url: String
    
    fileprivate var checked = false
    open var isChecked: Bool { return checked }
    
    open var idSidingFolder: String?
    open var idSidingFile: String?
    
    fileprivate var _childs: [UCSFile] = []
    open var childs: [UCSFile] { return _childs }
    
    // MARK: - Variables
    
    open var delegate: UCSFileDelegate?
    
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
    
    open func justChecked() {
        checked = true
    }
    
    open func pathCompleted() -> String {
        return "\(path)/\(name)"
    }
    
    open func foundChild(_ child: UCSFile) {
        guard !_childs.contains(where: { file in file.url == child.url }) else { return }
        _childs.append(child)
    }
    
    open func isChildOf(_ folder: UCSFile) -> Bool {
        return folder.isParentOf(self)
    }
    
    open func isParentOf(_ file: UCSFile) -> Bool {
        guard isFolder() else { return false }
        return pathCompleted() == file.path
    }
    
    open func download(_ headers: [String: String]?, delegate: UCSFileDelegate?) {
        guard isFile() else { return }
        self.delegate = delegate
        UCSDownloadHandler.shared.downloadFile(url, name: name, headers: headers, downloadedFile: delegate?.downloadFinished)
    }
    
    // MARK: - Helpers
    
    open func isFile() -> Bool {
        return url.contains(UCSConstant.urlIdentifierFile)
    }
    
    open func isFolder() -> Bool {
        return !isFile()
    }
    
    open func fileExtension() -> String {
        let separated = name.components(separatedBy: ".")
        guard let last = separated.last else { return "NO_EXTENSION" }
        return last.uppercased()
    }
    
}

// MARK - CustomStringConvertible comply
extension UCSFile: CustomStringConvertible {
    public var description: String {
        return "(\(isFolder() ? "F" : "f")) \(name)\n\(path)\n\(url)"
    }
}
