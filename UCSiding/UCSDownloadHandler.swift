
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

typealias downloadedFileCallback = (fileURL: NSURL) -> Void

class UCSDownloadHandler {
    
    // MARK: - Constants

    static let shared = UCSDownloadHandler()
    let session = NSURLSession.sharedSession()
    
    // MARK: - Variables
    
    var downloads: [String: NSURLSessionTask] = [:]
    lazy var fileManager = { NSFileManager.defaultManager() }()
    lazy var documents = { NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! } ()
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Functions
    
    func downloadFile(url: String, name: String, headers: [String: String]?, downloadedFile: downloadedFileCallback?) {
        let filePath = documents.stringByAppendingString("/\(name)")
        let fileURL = NSURL(fileURLWithPath: filePath)
        guard !fileManager.fileExistsAtPath(filePath) else {
            downloadedFile?(fileURL: fileURL)
            return
        }
        guard let downloadURL = NSURL(string: url) where downloads[url] == nil else { return }
        let request = NSMutableURLRequest(URL: downloadURL)
        request.HTTPMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = headers
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            UCSActivityIndicator.shared.endTask()
            self.downloads.removeValueForKey(url)
            guard let data = data where error == nil else { return }
            data.writeToURL(fileURL, atomically: true)
            downloadedFile?(fileURL: fileURL)
        })
        downloads[url] = task
        UCSActivityIndicator.shared.startTask()
        task.resume()
    }

}