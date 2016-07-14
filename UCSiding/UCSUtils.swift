//
//  UCSUtils.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Foundation

internal struct UCSUtils {
    
    internal static func stringFromData(data: NSData) -> String {
        let str = String(data: data, encoding: NSASCIIStringEncoding) ?? ""
        return str
    }
}