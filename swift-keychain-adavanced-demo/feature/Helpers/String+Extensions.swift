import Foundation

extension String {
    var asAnyObject: AnyObject {
        self as AnyObject
    }
    
    var asData: Data? {
        data(using: .utf8)
    }
}
