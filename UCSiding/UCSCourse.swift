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
    func foundMainFiles(course: UCSCourse, files: [UCSFile])
    func foundFolderFiles(course: UCSCourse, folder: UCSFile, files: [UCSFile])
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
    private var _mainFiles: [UCSFile] = []
    public var mainFiles: [UCSFile] { return _mainFiles }
    
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
    
    /// Loads **all** files belonging to this course and calls `foundFile(_)` for **each** file
    public func loadFiles() {
        loadFolders(loadContents: true)
    }
    
    /// Loads the files in the **main page** of the course. Calls `foundMainFiles(_)` when done
    public func loadMainFiles() {
        loadFolders(loadContents: false)
    }
    
    /// Loads the files in the provided folder.
    /// Calls `foundFolderFiles(_)` when done. Doesn't do anything if provided `UCSFile` isn't a folder (`isFolder()`)
    public func loadFolderFiles(folder: UCSFile) {
        guard folder.isFolder() else { return }
        loadFolderFiles(folder, loadContents: false)
    }
    
    private func loadFolders(loadContents loadContents: Bool) {
        guard let headers = headers() else { return }
        UCSUtils.getDataLink(self.url, headers: headers, filter: UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            elements.forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
                print("Found main folder \(name)")
                let file = UCSFile(course: self, filename: name, path: self.pathForChildren(), url: url, idSidingFolder: self.idSidingFolder(href))
                self.foundFolder(file, loadContents: loadContents)
            })
            UCSQueue.serial({
                self.delegate?.foundMainFiles(self, files: self._mainFiles)
            })
        }
    }
    
    private func foundFolder(folder: UCSFile, loadContents: Bool) {
        UCSQueue.serial({
            guard self.isFileNew(folder) else { return }
            self.foundNewFile(folder)
            if loadContents {
                self.loadFolderFiles(folder, loadContents: loadContents)
            }
        })
    }
    
    private func loadFolderFiles(folder: UCSFile, loadContents: Bool) {
        guard let headers = headers() else { return }
        UCSUtils.getDataLink(folder.url, headers: headers, filter: UCSConstant.urlIdentifierFile, UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            folder.justChecked()
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFolder) ?? false }).forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url, idSidingFolder: self.idSidingFolder(href))
                self.foundFolder(file, loadContents: loadContents)
                print("Found folder file \(name)")
            })
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFile) ?? false }).forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let hrefDuplicate = "/siding/dirdes/ingcursos/cursos/"
                let url = UCSURL.courseMainURL + href.stringByReplacingOccurrencesOfString(hrefDuplicate, withString: "")
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url, idSidingFile: self.idSidingFile(href))
                self.foundFile(file)
                print("Found folder folder \(name)")
            })
            UCSQueue.serial({
                let files = self._files.filter({ $0.isChildOf(folder) })
                self.delegate?.foundFolderFiles(self, folder: folder, files: files)
            })
        }
    }
    
    private func foundFile(newFile: UCSFile) {
        UCSQueue.serial({
            guard self.isFileNew(newFile) else { return }
            self.foundNewFile(newFile)
            newFile.justChecked()
        })
    }
    
    private func foundNewFile(newFile: UCSFile) {
        let parentFolders = _files.filter({ $0.isParentOf(newFile) })
        if parentFolders.count > 0 {
            print("Found Child: \(newFile.name) is child of \(parentFolders[0].name)")
            parentFolders[0].foundChild(newFile)
        } else {
            print("Found Main: \(newFile.name)")
            _mainFiles.append(newFile)
        }
        _files.append(newFile)
        delegate?.foundFile(self, file: newFile)
    }
    
    private func isFileNew(newFile: UCSFile) -> Bool {
        guard !_files.contains({ file in file.url == newFile.url }) else { return false }
        return true
    }
    
    private func idSidingFolder(href: String) -> String {
        return href.componentsSeparatedByString("id_carpeta=")[1].componentsSeparatedByString("&")[0]
    }
    
    private func idSidingFile(href: String) -> String {
        return href.componentsSeparatedByString("id_archivo=")[1].componentsSeparatedByString("&")[0]
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