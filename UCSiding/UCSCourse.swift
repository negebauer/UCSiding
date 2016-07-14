//
//  UCSCourse.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

public class UCSCourse {
    
    // MARK: - Constants

    // MARK: - Variables
    
    public var id: String
    public var name: String
    public var url: String
    public var section: Int
    
    // MARK: - Init
    
    public init(id: String, name: String, url: String, section: Int) {
        self.id = id
        self.name = name
        self.url = url
        self.section = section
    }
    
    // MARK: - Functions

}