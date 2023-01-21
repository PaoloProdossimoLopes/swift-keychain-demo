import Foundation

protocol WritterSecureClient {
    func write(_ params: WritterParams) throws
}

struct WritterParams {
    let application: String
    let identifier: String
    let secure: Data
}

