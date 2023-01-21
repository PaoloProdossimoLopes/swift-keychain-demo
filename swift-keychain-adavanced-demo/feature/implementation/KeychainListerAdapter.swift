import Foundation

final class KeychainListerAdapter: Lister {
    
    func list(_ params: ListParams) throws -> [ListResult] {
        let query: KeychainQueryParams = [
            kSecAttrService.asString: params.application.asAnyObject,
            kSecClass.asString: kSecClassGenericPassword,
            kSecReturnAttributes.asString: true as AnyObject,
            kSecMatchLimit.asString: 5 as AnyObject,
            kSecReturnData.asString: true as AnyObject
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpected(status)
        }

        print("Operation finished with status: \(status)")
        let array = result as! [NSDictionary]
        
        let params = array.map { dic in
            let application = dic[kSecAttrService] as! String
            let identifier = dic[kSecAttrAccount] as! String
            let securityData = dic[kSecValueData] as! Data
            let security = String(data: securityData, encoding: .utf8)!
            return ListResult(
                application: application,
                identifier: identifier,
                security: security
            )
        }
        
        return params
    }
}
