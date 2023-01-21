import Foundation

struct UpdateParams {
    let application: String
    let identifier: String
}

protocol UpdaterSecureClient {
    func update(_ params: DeleteParams) throws
}
