//
//  UCSSession.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

/// UCSiding Session
open class UCSSession {
    
    // MARK: - Constants

    fileprivate let username: String
    fileprivate let password: String
    
    fileprivate let loginFailString = "Los espacios que vienen a continuación son para lograr que esta celda ocupe la mayor cantidad de espacio posible dentro de la tabla."
    
    // MARK: - Variables
    
    fileprivate var cookies: [HTTPCookie] = []
    
    fileprivate var loginRequest: Request?
    fileprivate var logoutRequest: Request?
    
    // MARK: - Init
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    // MARK: - Login & Logout
    
    open func login(_ success: (() -> Void)? = nil, failure: ((_ error: NSError?) -> Void)? = nil) {
        let params: [String: String] = [
            "login": username,
            "passwd": password,
            "sw": "",
            "sh": "",
            "cd": ""
        ]
        UCSActivityIndicator.shared.startTask()
        loginRequest = Alamofire.request(.POST, UCSURL.loginURL, parameters: params, encoding: .URL)
            .response { request, response, data, error in
                UCSActivityIndicator.shared.endTask()
                self.loginRequest = nil
                guard let data = data, let response = response, error == nil else {
                    failure?(error: error)
                    return
                }
                let html = UCSUtils.stringFromData(data)
                guard !html.containsString(self.loginFailString) else {
                    failure?(error: nil)
                    return
                }
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields as! [String: String], forURL: NSURL(string: UCSURL.domain)!)
                self.cookies.appendContentsOf(cookies)
                success?()
        }
    }
    
    open func logout(_ callback: (() -> Void)? = nil) {
        UCSActivityIndicator.shared.startTask()
        logoutRequest = Alamofire.request(.GET, UCSURL.logoutURL).response { _, _, _, _ in
            UCSActivityIndicator.shared.endTask()
            self.logoutRequest = nil
            callback?()
        }
    }
    
    open func cancelLogin() {
        loginRequest?.cancel()
    }
    
    open func cancelLogout() {
        logoutRequest?.cancel()
    }
    
    // MARK: - Helpers
    
    open func headers() -> [String: String] {
        return HTTPCookie.requestHeaderFields(with: cookies)
    }
}
