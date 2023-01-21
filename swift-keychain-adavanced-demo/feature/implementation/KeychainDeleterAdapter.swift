import Foundation

struct KeychainDeleterAdapter: Deleter {
    
    typealias Operation = (CFDictionary) -> OSStatus
    var delete: Operation = SecItemDelete
    
    func delete(_ params: DeleteParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword
        ]
        
        let status = delete(query as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
    }
}
