//
//  UCSURL.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

/// Container for siding's URLs
public struct UCSURL {
    
    public static let domain = "intrawww.ing.puc.cl"
    
    public static let main = "https://\(domain)/siding"
    
    public static let loginPath =  "/index.phtml"
    public static let loginURL =  "\(main)\(loginPath)"
    
    public static let coursesPath = "/dirdes/ingcursos/cursos/index.phtml"
    public static let coursesURL = "\(main)\(coursesPath)"
    
    public static let logoutPath =  "/logout.phtml"
    public static let logoutURL =  "\(main)\(logoutPath)"
    
    /// Append a course or file href to this url to have the course or file complete url
    internal static let courseMainURL = "\(main)/dirdes/ingcursos/cursos/"
}