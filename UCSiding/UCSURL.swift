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
    public static let loginURL =  "\(main)/index.phtml"
    
    public static let coursesPath = "/dirdes/ingcursos/cursos/vista.phtml"
    public static let coursesURL = "\(main)/dirdes/ingcursos/cursos/vista.phtml"
    
    public static let logoutPath =  "/logout.phtml"
    public static let logoutURL =  "\(main)/logout.phtml"
}