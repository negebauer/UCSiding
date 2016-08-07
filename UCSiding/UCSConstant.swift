//
//  UCSConstant.swift
//  Pods
//
//  Created by Nicolás Gebauer on 14-07-16.
//
//

internal struct UCSConstant {
    
    internal static let bundleId: String = {
        return NSBundle.mainBundle().bundleIdentifier ?? "com.negebauer.ucsiding"
    }()
    
    internal static let urlIdentifierFolder = "vista.phtml"
    internal static let urlIdentifierFile = "descarga.phtml"
}