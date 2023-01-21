import Foundation

struct DeleteParams {
    let application: String
    let identifier: String
    let security: String
}

protocol DeleterSecureClient {
    func delete(_ params: DeleteParams) throws
}
