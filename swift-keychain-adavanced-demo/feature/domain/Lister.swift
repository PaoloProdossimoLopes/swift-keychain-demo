import Foundation

struct ListParams {
    let application: String
}

struct ListResult {
    let application: String
    let identifier: String
    let security: String
}

protocol Lister {
    func list(_ params: ListParams) throws -> [ListResult]
}
