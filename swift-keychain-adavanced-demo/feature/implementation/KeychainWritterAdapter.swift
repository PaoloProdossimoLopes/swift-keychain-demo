import Foundation

final class KeychainWritterAdapter: Writter {
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
