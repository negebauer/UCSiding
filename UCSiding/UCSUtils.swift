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
    
    internal static func stringFromData(_ data: Data) -> String {
        let str = String(data: data, encoding: String.Encoding.ascii) ?? ""
        return str
    }
    
    /**
     Executes a `GET` on the provided `link` and parses the returned `html` for links (`href`).
     
     - returns: An array of elements that match the provided filters
     */
    internal static func getDataLink(_ link: String, headers: [String: String]?, filter: String..., checkData: (_ elements: [XMLElement]) -> Void) {
        Alamofire.request(.GET, link, headers: headers)
            .response { (_, response, data, error) in
                guard let data = data, error == nil else {
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
