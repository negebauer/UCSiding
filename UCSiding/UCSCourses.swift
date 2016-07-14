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
    func coursesFound(courses: [UCSCourse])
}

/// Reads the courses in the Siding and allows interaction with them
public class UCSCourses {
    
    // MARK: - Constants
    
    // MARK: - Variables
    
    private var session: UCSSession
    
    private var _courses: [UCSCourse] = []
    public var courses: [UCSCourse] { return _courses }
    
    public var delegate: UCSCoursesDelegate?
    
    // MARK: - Init
    
    public init(session: UCSSession, delegate: UCSCoursesDelegate? = nil) {
        self.session = session
        self.delegate = delegate
    }
    
    // MARK: - Functions
    
    /// Scraps the Siding to obtain the list of current courses for the current session
    public func loadCourses() {
        clearCourses()
        getData(UCSURL.coursesURL, filter: "id_curso") { (elements: [XMLElement]) in
            elements.forEach({
                print($0.text)
                guard let text = $0.text, let href = $0["href"] else { return }
                let split = text.stringByReplacingOccurrencesOfString("s.", withString: "").componentsSeparatedByString(" ")
                guard let section = Int(split[1]) where split.count >= 3 else { return }
                let id = split[0]
                let name = split[2...(split.count - 1)].joinWithSeparator(" ")
                let url = UCSURL.courseMainURL + href
                let course = UCSCourse(id: id, name: name, url: url, section: section)
                print(course)
            })
        }
    }
    
    /// Clears the current loaded courses
    public func clearCourses() {
        _courses = []
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
    
    /**
     Updates the current session. You should update the courses data after calling this method
     - parameter session:     A valid `UCSSession`
     */
    public func updateSession(session: UCSSession) {
        self.session = session
        clearCourses()
    }
 
    private func getData(link: String, filter: String..., checkData: (elements: [XMLElement]) -> Void) {
        Alamofire.request(.GET, link, headers: session.headers())
            .response { (_, response, data, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    let stringData = data != nil ? UCSUtils.stringFromData(data!) : ""
                    if let doc = Kanna.HTML(html: stringData, encoding: NSUTF8StringEncoding) {
                        let elements = doc.xpath("//a | //link").filter({
                            let href = $0["href"]
                            return href != nil && filter.contains({ href!.containsString($0) })
                        })
                        checkData(elements: elements)
                    }
                }
        }
    }
}