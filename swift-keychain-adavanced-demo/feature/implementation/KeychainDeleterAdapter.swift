import Foundation

final class KeychainDeleterAdapter: Deleter {
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
