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
public class UCSSession {
    
    // MARK: - Constants

    private let username: String
    private let password: String
    
    private let loginFailString = "Los espacios que vienen a continuación son para lograr que esta celda ocupe la mayor cantidad de espacio posible dentro de la tabla."
    
    // MARK: - Variables
    
    private var cookies: [NSHTTPCookie] = []
    
    private var loginRequest: Request?
    private var logoutRequest: Request?
    
    // MARK: - Init
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    // MARK: - Login & Logout
    
    public func login(success: (() -> Void)? = nil, failure: ((error: NSError?) -> Void)? = nil) {
        let params: [String: String] = [
            "login": username,
            "passwd": password,
            "sw": "",
            "sh": "",
            "cd": ""
        ]
        loginRequest = Alamofire.request(.POST, UCSURL.loginURL, parameters: params, encoding: .URL)
            .response { request, response, data, error in
                self.loginRequest = nil
                guard let data = data, let response = response where error == nil else {
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
    
    public func logout(callback: (() -> Void)? = nil) {
        logoutRequest = Alamofire.request(.GET, UCSURL.logoutURL).response { _, _, _, _ in
            self.logoutRequest = nil
            callback?()
        }
    }
    
    public func cancelLogin() {
        loginRequest?.cancel()
    }
    
    public func cancelLogout() {
        logoutRequest?.cancel()
    }
    
    // MARK: - Helpers
    
    public func headers() -> [String: String] {
        return NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
    }
}