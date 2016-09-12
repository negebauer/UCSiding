
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

typealias downloadedFileCallback = (_ fileURL: URL) -> Void

class UCSDownloadHandler {
    
    // MARK: - Constants

    static let shared = UCSDownloadHandler()
    let session = URLSession.shared
    
    // MARK: - Variables
    
    var downloads: [String: URLSessionTask] = [:]
    lazy var fileManager = { FileManager.default }()
    lazy var documents = { NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! } ()
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Functions
    
    func downloadFile(_ url: String, name: String, headers: [String: String]?, downloadedFile: downloadedFileCallback?) {
        let filePath = documents + "/\(name)"
        let fileURL = URL(fileURLWithPath: filePath)
        guard !fileManager.fileExists(atPath: filePath) else {
            downloadedFile?(fileURL)
            return
        }
        guard let downloadURL = URL(string: url) , downloads[url] == nil else { return }
        let request = NSMutableURLRequest(url: downloadURL)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.allHTTPHeaderFields = headers
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            UCSActivityIndicator.shared.endTask()
            self.downloads.removeValue(forKey: url)
            guard let data = data , error == nil else { return }
            try? data.write(to: fileURL, options: [.atomic])
            downloadedFile?(fileURL: fileURL)
        })
        downloads[url] = task
        UCSActivityIndicator.shared.startTask()
        task.resume()
    }

}
