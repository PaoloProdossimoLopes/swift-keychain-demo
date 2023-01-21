import Foundation

final class KeychainUpdaterAdapter: Updater {
    typealias Operation = (CFDictionary, CFDictionary) -> OSStatus
    var update: Operation = SecItemUpdate
    
    func update(_ params: UpdateParams) throws {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecAttrAccount.asString: params.identifier.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData.asString: params.security.asAnyObject
        ]
        
        let status = update(
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
