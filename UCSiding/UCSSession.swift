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
    
    open func login(_ success: (() -> Void)? = nil, failure: ((_ error: Error?) -> Void)? = nil) {
        let params: [String: Any]? = [
            "login": username,
            "passwd": password,
            "sw": "",
            "sh": "",
            "cd": ""
        ]
        UCSActivityIndicator.shared.startTask()
        Alamofire.request("https://httpbin.org/delete", method: .delete)
        loginRequest = Alamofire.request(UCSURL.loginURL, method: .post, parameters: params)
            .response { response in
                UCSActivityIndicator.shared.endTask()
                self.loginRequest = nil
                guard let data = response.data, response.error == nil else {
                    failure?(response.error)
                    return
                }
                let html = UCSUtils.stringFromData(data)
                guard !html.contains(self.loginFailString) else {
                    failure?(nil)
                    return
                }
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.response?.allHeaderFields as! [String: String], for: URL(string: UCSURL.domain)!)
                self.cookies.append(contentsOf: cookies)
                success?()
        }
    }
    
    open func logout(_ callback: (() -> Void)? = nil) {
        UCSActivityIndicator.shared.startTask()
        logoutRequest = Alamofire.request(UCSURL.logoutURL).response { response in
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
