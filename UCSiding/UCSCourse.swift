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
    func foundFile(_ course: UCSCourse, file: UCSFile)
    func foundMainFiles(_ course: UCSCourse, files: [UCSFile])
    func foundFolderFiles(_ course: UCSCourse, folder: UCSFile, files: [UCSFile])
}

open class UCSCourse {
    
    // MARK: - Constants

    // MARK: - Variables
    
    open var id: String
    open var idSiding: String
    open var name: String
    open var url: String
    open var section: Int
    
    fileprivate var _files: [UCSFile] = []
    open var files: [UCSFile] { return _files }
    fileprivate var _mainFiles: [UCSFile] = []
    open var mainFiles: [UCSFile] { return _mainFiles }
    
    open weak var delegate: UCSCourseDelegate?
    
    // MARK: - Init
    
    public init(id: String, idSiding: String, name: String, url: String, section: Int) {
        self.id = id
        self.idSiding = idSiding
        self.name = name
        self.url = url
        self.section = section
    }
    
    // MARK: - Course info
    
    open func loadStudents(_ withHeaderRow: Bool = true, success: ((_ students: [UCSStudent]) -> Void)? = nil, failure: ((_ error: NSError?) -> Void)? = nil) {
        guard let headers = headers() else { return }
        UCSActivityIndicator.shared.startTask()
        let url = UCSURL.CourseURL(course: self).students()
        Alamofire.request(.GET, url, headers: headers)
            .response { (_, response, data, error) in
                guard let data = data , error == nil else {
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
                            func clean(_ string: String) -> String {
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
    open func loadFiles() {
        loadFolders(loadContents: true)
    }
    
    /// Loads the files in the **main page** of the course. Calls `foundMainFiles(_)` when done
    open func loadMainFiles() {
        loadFolders(loadContents: false)
    }
    
    /// Loads the files in the provided folder.
    /// Calls `foundFolderFiles(_)` when done. Doesn't do anything if provided `UCSFile` isn't a folder (`isFolder()`)
    open func loadFolderFiles(_ folder: UCSFile) {
        guard folder.isFolder() else { return }
        loadFolderFiles(folder, loadContents: false)
    }
    
    fileprivate func loadFolders(loadContents: Bool) {
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
    
    fileprivate func foundFolder(_ folder: UCSFile, loadContents: Bool) {
        UCSQueue.serial({
            guard self.isFileNew(folder) else { return }
            self.foundNewFile(folder)
            if loadContents {
                self.loadFolderFiles(folder, loadContents: loadContents)
            }
        })
    }
    
    fileprivate func loadFolderFiles(_ folder: UCSFile, loadContents: Bool) {
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
    
    fileprivate func foundFile(_ newFile: UCSFile) {
        UCSQueue.serial({
            guard self.isFileNew(newFile) else { return }
            self.foundNewFile(newFile)
            newFile.justChecked()
        })
    }
    
    fileprivate func foundNewFile(_ newFile: UCSFile) {
        let parentFolders = _files.filter({ $0.isParentOf(newFile) })
        if parentFolders.count > 0 {
            parentFolders[0].foundChild(newFile)
        } else {
            _mainFiles.append(newFile)
        }
        _files.append(newFile)
        delegate?.foundFile(self, file: newFile)
    }
    
    fileprivate func isFileNew(_ newFile: UCSFile) -> Bool {
        guard !_files.contains(where: { file in file.url == newFile.url }) else { return false }
        return true
    }
    
    // MARK: - File helpers
    
    fileprivate func idSidingFolder(_ href: String) -> String {
        return href.components(separatedBy: "id_carpeta=")[1].components(separatedBy: "&")[0]
    }
    
    fileprivate func idSidingFile(_ href: String) -> String {
        return href.components(separatedBy: "id_archivo=")[1].components(separatedBy: "&")[0]
    }
    
    // MARK: - Helpers
    
    open func pathForChildren() -> String {
        return "\(id) \(name)"
    }
    
    fileprivate func headers() -> [String: String]? {
        return delegate?.session.headers()
    }
    
    open func numberOfFiles() -> (total: Int, files: Int, folders: Int) {
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
