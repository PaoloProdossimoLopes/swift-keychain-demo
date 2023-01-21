import Foundation

protocol ReaderSecureClient {
    func read(_ params: ReadParams) throws -> ReadResult
}

struct ReadParams {
    let application: String
    let identifier: String
}

struct ReadResult {
    let secure: Data
}
