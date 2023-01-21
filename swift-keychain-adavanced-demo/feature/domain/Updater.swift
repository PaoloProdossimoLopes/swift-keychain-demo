import Foundation

struct UpdateParams {
    let application: String
    let identifier: String
}

protocol Updater {
    func update(_ params: DeleteParams) throws
}
