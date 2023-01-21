import Foundation

struct UpdateParams {
    let application: String
    let identifier: String
    let security: Data
}

protocol Updater {
    func update(_ params: UpdateParams) throws
}
