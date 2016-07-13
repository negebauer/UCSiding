//
//  UCSURL.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

public struct UCSURL {
    
    public static let domain = "intrawww.ing.puc.cl"
    private static let main = "https://\(domain)/siding"
    public static let login =  "\(main)/index.phtml"
    public static let courses = "\(main)/dirdes/ingcursos/cursos/vista.phtml"
}