import Foundation

struct KeychainWritterAdapter: Writter {
    typealias Reference = UnsafeMutablePointer<CFTypeRef?>
    typealias Operation = (CFDictionary, Reference?) -> OSStatus
    var write: Operation = SecItemAdd
    
    func write(_ params: WritterParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecValueData.asString: params.secure.asAnyObject
        ]
        
        let status = write(query as CFDictionary, nil)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }
    }
}
