import Foundation

struct ReadParams {
    let application: String
    let identifier: String
}

struct ReadResult {
    let secure: Data
}

protocol Reader {
    func read(_ params: ReadParams) throws -> ReadResult
}
