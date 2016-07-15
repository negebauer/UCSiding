//
//  UCSCourses.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

public protocol UCSCoursesDelegate: class {
    func coursesFound(ucsCourses: UCSCourses, courses: [UCSCourse])
    func courseFoundFile(ucsCourses: UCSCourses, courses: [UCSCourse], course: UCSCourse, file: UCSFile)
}

/// Reads the courses in the Siding and allows interaction with them
public class UCSCourses: UCSCourseDelegate {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    private var _session: UCSSession
    public var session: UCSSession { return _session }
    
    private var _courses: [UCSCourse] = []
    public var courses: [UCSCourse] { return _courses }
    
    public weak var delegate: UCSCoursesDelegate?
    
    // MARK: - Init
    
    public init(session: UCSSession, delegate: UCSCoursesDelegate? = nil) {
        _session = session
        self.delegate = delegate
    }
    
    // MARK: - Courses scrapping
    
    /// Scraps the Siding to obtain the list of current courses for the current session
    public func loadCourses() {
        clearCourses()
        UCSUtils.getDataLink(UCSURL.coursesURL, headers: session.headers(), filter: "id_curso") { (elements: [XMLElement]) in
            elements.forEach({
                guard let text = $0.text, let href = $0["href"] else { return }
                let split = text.stringByReplacingOccurrencesOfString("s.", withString: "").componentsSeparatedByString(" ")
                let splitIdSiding = href.componentsSeparatedByString("id_curso_ic=")
                guard let section = Int(split[1]) where split.count >= 3 && splitIdSiding.count >= 2 else { return }
                let id = split[0]
                let idSiding = splitIdSiding[1]
                let name = split[2...(split.count - 1)].joinWithSeparator(" ")
                let url = UCSURL.courseMainURL + href
                let course = UCSCourse(id: id, idSiding: idSiding, name: name, url: url, section: section)
                self.foundCourse(course)
            })
            self.delegate?.coursesFound(self, courses: self.courses)
        }
    }
    
    /// Adds the provided `course` if it wasn't registered before
    private func foundCourse(course: UCSCourse) {
        guard getCourse(id: course.id) == nil else { return }
        _courses.append(course)
    }
    
    /// Clears the current loaded courses
    public func clearCourses() {
        _courses = []
    }
    
    // MARK: - Course scrapping
    
    /**
     Search for files in all `courses`.
    
     `UCSCourses` sets itself as the delegate of each course to notify on each file discovery
     */
    public func loadCoursesFiles() {
        courses.forEach({ course in
            course.delegate = self
            course.loadFiles()
        })
    }
    
    // MARK: - UCSCourseDelegate methods
    
    public func foundFile(course: UCSCourse, file: UCSFile) {
        delegate?.courseFoundFile(self, courses: courses, course: course, file: file)
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
    
    // MARK: - Helpers
    
    public func files() -> [UCSFile] {
        return Array(courses.map({ $0.files }).flatten())
    }
    
    public func numberOfFiles() -> Int {
        return coursesCount() + courses.map({ $0.files.count }).reduce(0, combine: +)
    }
    
    public func numberOfCheckedFiles() -> Int {
        return courses.count + courses.map({ $0.files.filter({ $0.isChecked }).count }).reduce(0, combine: +)
    }
    
    /**
     Updates the current session. You should update the courses data after calling this method
     - parameter session:     A valid `UCSSession`
     */
    public func updateSession(session: UCSSession) {
        _session = session
        clearCourses()
    }
}