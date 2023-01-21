import Foundation

typealias KeychainQueryParams = [String: AnyObject]
struct KeychainAdapter {
    
    private let witter: WritterSecureClient
    private let reader: ReaderSecureClient
    private let updater: UpdaterSecureClient
    private let deleter: DeleterSecureClient
    
    init(witter: WritterSecureClient, reader: ReaderSecureClient, updater: UpdaterSecureClient, deleter: DeleterSecureClient) {
        self.witter = witter
        self.reader = reader
        self.updater = updater
        self.deleter = deleter
    }
}

extension KeychainAdapter: WritterSecureClient {
    func write(_ params: WritterParams) throws {
        try witter.write(params)
    }
}

extension KeychainAdapter: ReaderSecureClient {
    func read(_ params: ReadParams) throws -> ReadResult {
        try reader.read(params)
    }
}

extension KeychainAdapter: UpdaterSecureClient {
    func update(_ params: DeleteParams) throws {
        try updater.update(params)
    }
}

extension KeychainAdapter: DeleterSecureClient {
    func delete(_ params: DeleteParams) throws {
        try deleter.delete(params)
    }
    
}

enum KeychainError: Swift.Error {
    case notFound
    case invalidItemFormat
    case unexpected(OSStatus)
}

final class KeychainWritterAdapter: WritterSecureClient {
    func write(_ params: WritterParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecValueData.asString: params.secure.asAnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
    }
}

final class KeychainReaderAdapter: ReaderSecureClient {
    func read(_ params: ReadParams) throws -> ReadResult {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecMatchLimit.asString: kSecMatchLimitOne,
            kSecReturnData.asString: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
        
        guard let security = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return ReadResult(secure: security)
    }
}

final class KeychainDeleterAdapter: DeleterSecureClient {
    func delete(_ params: DeleteParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
    }
}

final class KeychainUpdaterAdapter: UpdaterSecureClient {
    func update(_ params: DeleteParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData.asString: params.security.asAnyObject
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
    }
}

private extension String {
    var asAnyObject: AnyObject {
        self as AnyObject
    }
    
    var asData: Data? {
        data(using: .utf8)
    }
}

private extension Data {
    var asAnyObject: AnyObject {
        self as AnyObject
    }
}

private extension CFString {
    var asString: String {
        self as String
    }
    
    var asAnyObject: AnyObject {
        self as AnyObject
    }
}
