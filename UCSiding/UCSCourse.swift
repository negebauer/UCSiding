//
//  UCSCourse.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

public protocol UCSCourseDelegate: class {
    var session: UCSSession { get }
    func foundFile(course: UCSCourse, file: UCSFile)
}

public class UCSCourse {
    
    // MARK: - Constants

    // MARK: - Variables
    
    public var id: String
    public var idSiding: String
    public var name: String
    public var url: String
    public var section: Int
    
    private var _files: [UCSFile] = []
    public var files: [UCSFile] { return _files }
    
    public weak var delegate: UCSCourseDelegate?
    
    // MARK: - Init
    
    public init(id: String, idSiding: String, name: String, url: String, section: Int) {
        self.id = id
        self.idSiding = idSiding
        self.name = name
        self.url = url
        self.section = section
    }
    
    // MARK: - Functions
    
    public func loadFiles() {
        loadFolders()
    }
    
    private func loadFolders() {
        guard let headers = headers() else { return }
        UCSUtils.getDataLink(self.url, headers: headers, filter: UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            elements.forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
                let file = UCSFile(course: self, filename: name, path: self.pathForChildren(), url: url)
                self.foundFolder(file)
            })
        }
    }
    
    private func foundFolder(folder: UCSFile) {
        UCSQueue.serial({
            guard self.isFileNew(folder) else { return }
            self._files.append(folder)
            self.loadFolderFiles(folder)
            self.delegate?.foundFile(self, file: folder)
        })
    }
    
    private func loadFolderFiles(folder: UCSFile) {
        guard let headers = headers() else { return }
        UCSUtils.getDataLink(folder.url, headers: headers, filter: UCSConstant.urlIdentifierFile, UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            folder.justChecked()
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFolder) ?? false }).forEach({
                // TODO: Get Siding ID
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url)
                self.foundFolder(file)
            })
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFile) ?? false }).forEach({
                // TODO: Get Siding ID
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let hrefDuplicate = "/siding/dirdes/ingcursos/cursos/"
                let url = UCSURL.courseMainURL + href.stringByReplacingOccurrencesOfString(hrefDuplicate, withString: "")
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url)
                self.foundFile(file)
            })
        }
    }
    
    private func foundFile(newFile: UCSFile) {
        UCSQueue.serial({
            guard self.isFileNew(newFile) else { return }
            self._files.append(newFile)
            newFile.justChecked()
            self.delegate?.foundFile(self, file: newFile)
        })
    }
    
    private func isFileNew(newFile: UCSFile) -> Bool {
        guard !self._files.contains({ file in file.url == newFile.url }) else { return false }
        return true
    }
    
    // MARK: - Helpers
    
    public func pathForChildren() -> String {
        return "\(id) \(name)"
    }
    
    private func headers() -> [String: String]? {
        return delegate?.session.headers()
    }
    
    public func numberOfFiles() -> (total: Int, files: Int, folders: Int) {
        let filesC = files.filter({ $0.isFile() }).count
        let folders = files.filter({ $0.isFolder() }).count
        let total = filesC + folders + 1
        return (total, filesC, folders)
    }
}

extension UCSCourse: CustomStringConvertible {
    public var description: String {
        return "\(id) \(section) \(name)"
    }
}