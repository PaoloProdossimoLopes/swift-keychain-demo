import Foundation

struct UpdateParams {
    let application: String
    let identifier: String
    let security: String
}

protocol Updater {
    func update(_ params: UpdateParams) throws
}
