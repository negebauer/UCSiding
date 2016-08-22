
//
//  UCSDownloadHandler.swift
//  Pods
//
//  Created by Nicolás Gebauer on 22-08-16.
//
//

import Foundation

enum HTTPMethod: String {
    case GET, POST
}

typealias updateProgressCallback = (progress: Float) -> Void
typealias downloadedFileCallback = (path: String) -> Void

struct UCSDownloadData {
    let filePath: String
    let updateProgress: updateProgressCallback?
    let downloadedFile: downloadedFileCallback?
    init(filePath: String, updateProgress: updateProgressCallback?, downloadedFile: downloadedFileCallback?) {
        self.filePath = filePath
        self.updateProgress = updateProgress
        self.downloadedFile = downloadedFile
    }
}

class UCSDownloadHandler: NSObject {
    
    // MARK: - Constants

    static let shared = UCSDownloadHandler()
    
    // MARK: - Variables
    
    var tasks: [NSURLSessionDownloadTask: UCSDownloadData] = [:]
    
    lazy var fileManager = { return NSFileManager() }()
    lazy var session: NSURLSession = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("UCSDownloadHandler")
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    lazy var documentDirectoryPath: String = {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return path[0]
    }()
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    // MARK: - Functions
    
    func downloadFile(url: String, filePath: String, headers: [String: String]?, updateProgress: updateProgressCallback?, downloadedFile: downloadedFileCallback?) {
        guard let url = NSURL(string: url) else { return }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = headers
        let task = session.downloadTaskWithRequest(request)
        tasks[task] = UCSDownloadData(filePath: filePath, updateProgress: updateProgress, downloadedFile: downloadedFile)
        task.resume()
    }

}

// MARK: - NSURLSessionDelegate comply
extension UCSDownloadHandler: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        tasks[downloadTask]?.updateProgress?(progress: progress)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        guard let task = tasks[downloadTask] else { return }
        let filePathAppend = documentDirectoryPath.stringByAppendingString(task.filePath)
        let fileURL = NSURL(fileURLWithPath: filePathAppend)
        guard let filePath = fileURL.path else { return }
        
        if fileManager.fileExistsAtPath(filePath) {
            task.downloadedFile?(path: filePath)
        } else {
            do {
                try fileManager.moveItemAtURL(location, toURL: fileURL)
                task.downloadedFile?(path: filePath)
            } catch {
                print("Couldn't move file")
            }
        }
    }
}