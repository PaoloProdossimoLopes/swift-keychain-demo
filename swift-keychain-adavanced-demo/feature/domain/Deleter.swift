import Foundation

struct DeleteParams {
    let application: String
    let identifier: String
    let security: String
}

protocol Deleter {
    func delete(_ params: DeleteParams) throws
}
