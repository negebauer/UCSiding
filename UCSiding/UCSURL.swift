//
//  UCSURL.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

/// Container for siding's static URLs
public struct UCSURL {
    
    public static let domain = "intrawww.ing.puc.cl"
    
    public static let main = "https://\(domain)/siding"
    
    public static let loginPath =  "/index.phtml"
    public static let loginURL =  "\(main)\(loginPath)"
    
    public static let coursesPath = "/dirdes/ingcursos/cursos/index.phtml"
    public static let coursesURL = "\(main)\(coursesPath)"
    
    public static let courseFilePath = coursesPath.replacingOccurrences(of: "index.phtml", with: "descarga.phtml")
    public static let courseFileURL = "\(main)\(courseFilePath)"
    
    public static let logoutPath =  "/logout.phtml"
    public static let logoutURL =  "\(main)\(logoutPath)"
    
    /// Append a course or file href to this url to have the course or file complete url
    internal static let courseMainURL = "\(main)/dirdes/ingcursos/cursos/"
    
    public struct CourseURL {
        
        let course: UCSCourse
        var id: String { return course.idSiding }
        
        init(course: UCSCourse) {
            self.course = course
        }
        
        fileprivate func url(_ action: String) -> String {
            return "\(coursesURL)?accion_curso=\(action)&id_curso_ic=\(id)"
        }
        
        public func fileUrl(_ file: UCSFile) -> String {
            if file.isFolder() {
                return "\(coursesURL)?id_curso_ic=\(id)&accion_curso=carpetas&acc_carp=abrir_carpeta&id_carpeta=\(file.idSidingFolder!)"
                
            } else if file.isFile() {
                return "\(courseFileURL)?id_curso_ic=\(id)&id_archivo=\(file.idSidingFile!)"
            } else {
                return ""
            }
        }

        public func news() -> String {
            return url("avisos")
        }
        
        public func program() -> String {
            return url("programa")
        }
        
        public func calendar() -> String {
            return url("calendario")
        }
        
        public func forms() -> String {
            return url("cuestionarios")
        }
        
        public func students() -> String {
            return url("alumnos")
        }
        
        public func grades() -> String {
            return url("notas")
        }
        
        public func forum() -> String {
            return url("foro")
        }
    }
}
