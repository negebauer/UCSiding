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
    
    // MARK: - Course info
    
    public func loadStudents(withHeaderRow: Bool = true, success: ((students: [UCSStudent]) -> Void)? = nil, failure: ((error: NSError?) -> Void)? = nil) {
        guard let headers = headers() else { return }
        UCSActivityIndicator.shared.startTask()
        let url = UCSURL.CourseURL(course: self).students()
        Alamofire.request(.GET, url, headers: headers)
            .response { (_, response, data, error) in
                guard let data = data where error == nil else {
                    failure?(error: error)
                    return print("Error: \(error!)")
                }
                let stringData = UCSUtils.stringFromData(data)
                if let doc = Kanna.HTML(html: stringData, encoding: NSUTF8StringEncoding) {
                    let table = doc.xpath("//table[@class='TablaConBordeFinoLightblue']")
                    var students = [UCSStudent]()
                    table.forEach({ element in
                        let row = element.xpath("tr").forEach({
                            var lastnameP = ""
                            var lastnameM = ""
                            var name = ""
                            var i = 0
                            func clean(string: String) -> String {
                                return string.stringByReplacingOccurrencesOfString("\r", withString: "")
                                    .stringByReplacingOccurrencesOfString("\n", withString: "")
                                    .stringByReplacingOccurrencesOfString("\t", withString: "")
                                    .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
                                    .capitalizedString
                            }
                            let cells = $0.xpath("td").forEach({
                                guard var text = $0.text else { return }
                                text = clean(text)
                                if i == 0 {
                                    lastnameP = text
                                } else if i == 1 {
                                    lastnameM = text
                                } else if i == 2 {
                                    name = text
                                }
                                i += 1
                            })
                            let student = UCSStudent(lastnameP: lastnameP, lastnameM: lastnameM, name: name)
                            students.append(student)
                        })
                    })
                    if !withHeaderRow {
                        students.removeFirst()
                    }
                    success?(students: students)
                }
                
        }
    }
    
    // MARK: - Course files
    
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
        UCSActivityIndicator.shared.startTask()
        UCSUtils.getDataLink(self.url, headers: headers, filter: UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            UCSActivityIndicator.shared.endTask()
            elements.forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
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
        UCSActivityIndicator.shared.startTask()
        UCSUtils.getDataLink(folder.url, headers: headers, filter: UCSConstant.urlIdentifierFile, UCSConstant.urlIdentifierFolder) { (elements: [XMLElement]) in
            UCSActivityIndicator.shared.endTask()
            folder.justChecked()
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFolder) ?? false }).forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let url = UCSURL.courseMainURL + href
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url, idSidingFolder: self.idSidingFolder(href))
                self.foundFolder(file, loadContents: loadContents)
            })
            elements.filter({ $0["href"]?.containsString(UCSConstant.urlIdentifierFile) ?? false }).forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let name = text
                let hrefDuplicate = "/siding/dirdes/ingcursos/cursos/"
                let url = UCSURL.courseMainURL + href.stringByReplacingOccurrencesOfString(hrefDuplicate, withString: "")
                let file = UCSFile(course: self, filename: name, path: folder.pathCompleted(), url: url, idSidingFile: self.idSidingFile(href))
                self.foundFile(file)
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
            parentFolders[0].foundChild(newFile)
        } else {
            _mainFiles.append(newFile)
        }
        _files.append(newFile)
        delegate?.foundFile(self, file: newFile)
    }
    
    private func isFileNew(newFile: UCSFile) -> Bool {
        guard !_files.contains({ file in file.url == newFile.url }) else { return false }
        return true
    }
    
    // MARK: - File helpers
    
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