import Foundation

final class KeychainReaderAdapter: Reader {
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
