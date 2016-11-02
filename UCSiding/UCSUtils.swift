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
    internal static func getDataLink(_ link: String, headers: [String: String]?, filter: String..., checkData: @escaping (_ elements: [XMLElement]) -> Void) {
        Alamofire.request(link, headers: headers)
            .response { response in
                guard let data = response.data, response.error == nil else {
                    return print("Error: \(response.error!)")
                }
                let stringData = UCSUtils.stringFromData(data)
                if let doc = Kanna.HTML(html: stringData, encoding: String.Encoding.utf8) {
                    let elements = doc.xpath("//a | //link").filter({
                        guard let href = $0["href"] else { return false }
                        "a".contains("a")
                        return filter.contains(where: {href.contains($0)})
                    })
                    checkData(elements)
                }
        }
    }
}
