//
//  UCSUtils.swift
//  Pods
//
//  Created by Nicolás Gebauer on 13-07-16.
//
//

import Alamofire
import Kanna

internal struct UCSUtils {
    
    internal static func stringFromData(data: NSData) -> String {
        let str = String(data: data, encoding: NSASCIIStringEncoding) ?? ""
        return str
    }
    
    /**
     Executes a `GET` on the provided `link` and parses the returned `html` for links (`href`).
     
     - returns: An array of elements that match the provided filters
     */
    internal static func getDataLink(link: String, headers: [String: String]?, filter: String..., checkData: (elements: [XMLElement]) -> Void) {
        Alamofire.request(.GET, link, headers: headers)
            .response { (_, response, data, error) in
                guard let data = data where error == nil else {
                    return print("Error: \(error!)")
                }
                let stringData = UCSUtils.stringFromData(data)
                if let doc = Kanna.HTML(html: stringData, encoding: NSUTF8StringEncoding) {
                    let elements = doc.xpath("//a | //link").filter({
                        guard let href = $0["href"] else { return false }
                        return filter.contains({ href.containsString($0) })
                    })
                    checkData(elements: elements)
                }
        }
    }
}