import Foundation

typealias KeychainQueryParams = [String: AnyObject]
struct KeychainAdapter {
    
    private let witter: Writter
    private let reader: Reader
    private let updater: Updater
    private let deleter: Deleter
    private let lister: Lister
    
    init(
        witter: Writter,
        reader: Reader,
        updater: Updater,
        deleter: Deleter,
        lister: Lister
    ) {
        self.witter = witter
        self.reader = reader
        self.updater = updater
        self.deleter = deleter
        self.lister = lister
    }
}

extension KeychainAdapter: Writter {
    func write(_ params: WritterParams) throws {
        try witter.write(params)
    }
}

extension KeychainAdapter: Reader {
    func read(_ params: ReadParams) throws -> ReadResult {
        try reader.read(params)
    }
}

extension KeychainAdapter: Updater {
    func update(_ params: UpdateParams) throws {
        try updater.update(params)
    }
}

extension KeychainAdapter: Deleter {
    func delete(_ params: DeleteParams) throws {
        try deleter.delete(params)
    }
}

extension KeychainAdapter: Lister {
    func list(_ params: ListParams) throws -> [ListResult] {
        try lister.list(params)
    }
}
