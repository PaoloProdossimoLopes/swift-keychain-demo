import Foundation

struct WritterParams {
    let application: String
    let identifier: String
    let secure: Data
}

protocol Writter {
    func write(_ params: WritterParams) throws
}
