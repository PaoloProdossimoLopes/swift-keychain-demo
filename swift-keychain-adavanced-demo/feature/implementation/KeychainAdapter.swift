import Foundation

struct KeychainAdapter {
    private typealias QueryParams = [String: AnyObject]
}

private extension KeychainAdapter {
    enum Error: Swift.Error {
        case notFound
        case invalidItemFormat
        case unexpected(OSStatus)
    }
}

extension KeychainAdapter: WritterSecureClient {
    func write(_ params: WritterParams) throws {
        let query: QueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecValueData.asString: params.secure.asAnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecItemNotFound else {
            throw Error.notFound
        }
        
        guard status == errSecSuccess else {
            throw Error.unexpected(status)
        }
    }
}

extension KeychainAdapter: ReaderSecureClient {
    func read(_ params: ReadParams) throws -> ReadResult {
        let query: QueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecMatchLimit.asString: kSecMatchLimitOne,
            kSecReturnData.asString: kCFBooleanTrue
        ]
        
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        
        guard status != errSecItemNotFound else {
            throw Error.notFound
        }
        
        guard status == errSecSuccess else {
            throw Error.unexpected(status)
        }
        
        guard let security = itemCopy as? Data else {
            throw Error.invalidItemFormat
        }
        
        return ReadResult(secure: security)
    }
}

extension KeychainAdapter: DeleterSecureClient {
    func delete(_ params: DeleteParams) throws {
        let query: QueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw Error.unexpected(status)
        }
    }
}

extension KeychainAdapter: UpdaterSecureClient {
    func update(_ params: DeleteParams) throws {
        let query: QueryParams = [
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
            throw Error.notFound
        }
        
        guard status == errSecSuccess else {
            throw Error.unexpected(status)
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
