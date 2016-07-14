//
//  UCSCourses.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

public protocol UCSCoursesDelegate {
    
}

/// Reads the courses in the Siding and allows interaction with them
public class UCSCourses {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    private var session: UCSSession
    private var courses: [UCSCourse] = []
    
    public var delegate: UCSCoursesDelegate?
    
    // MARK: - Init
    
    public init(session: UCSSession, delegate: UCSCoursesDelegate? = nil) {
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Functions
    
    /// Scraps the Siding to obtain the list of current courses for the current session
    public func loadCourses() {
        
    }
    
    /// Clears the current loaded courses
    public func clearCourses() {
        courses = []
    }
    
    // MARK: - Courses get
    
    /// Gets a course by it's id, such as `IIC2233`
    public func getCourse(id id: String) -> UCSCourse? {
        let filter: (UCSCourse) -> Bool = { course in course.id == id }
        return getCourse(filter)
    }
    
    /// Gets a course by it's name, such as `Programación Avanzada`
    public func getCourse(name name: String) -> UCSCourse? {
        let filter: (UCSCourse) -> Bool = { course in course.name == name }
        return getCourse(filter)
    }
    
    private func getCourse(filter: (UCSCourse) -> Bool) -> UCSCourse? {
        guard courses.contains(filter) else {
            return nil
        }
        return courses.filter(filter)[0]    }
    
    /**
     Gets a course by it's index in the `courses` array.
     To be used, for example, when displaying courses in a table.
     */
    public func getCourse(index: Int) -> UCSCourse? {
        guard coursesCount() > index else {
            return nil
        }
        return courses[index]
    }
    
    public func coursesCount() -> Int {
        return courses.count
    }
    
    /**
     Updates the current session. You should update the courses data after calling this method
     - parameter session:     A valid `UCSSession`
     */
    public func updateSession(session: UCSSession) {
        self.session = session
        clearCourses()
    }
    
}