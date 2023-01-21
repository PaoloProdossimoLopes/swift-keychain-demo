import XCTest
@testable import swift_keychain_adavanced_demo

final class KeychainWritterAdapterTests: XCTestCase {
    func test_onInit_noPerformsWriteOperation() {
        var operationCounter = 0
        _ = makeSUT(onWrite: { _, _ in
            operationCounter += 1
        })
        
        XCTAssertEqual(operationCounter, 0)
    }
    
    func test_onWrite_withParams_callWriteOnce() {
        var operationCounter = 0
        let params = makeParams()
        let sut = makeSUT(onWrite: { _, _ in
            operationCounter += 1
        })
        
        try? sut.write(params)
        
        XCTAssertEqual(operationCounter, 1)
    }
    
    func test_onWrite_withParams_callsWithCorrectParams() {
        let application = "any application"
        let identifier = "any identifier"
        let secure = Data("any security".utf8)
        let params = makeParams(
            application: application,
            identifier: identifier,
            secure: secure
        )
        var receivedParams: Params?
        let sut = makeSUT(onWrite: { params, _ in
            receivedParams = params
        })
        
        try? sut.write(params)
        
        XCTAssertEqual(receivedParams?[kSecAttrService] as? String, application)
        XCTAssertEqual(receivedParams?[kSecAttrAccount] as? String, identifier)
        XCTAssertEqual(receivedParams?[kSecValueData] as? Data, secure)
        XCTAssertEqual(receivedParams?[kSecClass] as? String, kSecClassGenericPassword as String)
    }
    
    func test_onWrite_withParams_callsWithNoReference() {
        let params = makeParams()
        var referenceReceived: Reference?
        let sut = makeSUT(onWrite: { _, reference in
            referenceReceived = reference
        })
        
        try? sut.write(params)
        
        XCTAssertNil(referenceReceived)
    }
    
    func test_onWrite_resturnsItemNotFound_delieversNotFoundError() {
        let sut = makeSUT(status: errSecItemNotFound)
        let params = makeParams()
        
        var receivedError: Error?
        do {
            try sut.write(params)
            return XCTFail("Expect receive an `NotFoundError` but instead all working")
        } catch let error {
            receivedError = error
        }
        
        guard let keychainError = receivedError as? KeychainError else {
            return XCTFail("Expect error Received is an `KeychainError` type")
        }
        
        switch keychainError {
        case .notFound: break
        case .invalidItemFormat, .unexpected:
            XCTFail("Expect receive an `NotFoundError` but got \(keychainError) instead")
        }
    }
    
    func test_onWrite_resturnsSuccess_noDelieversAnyError() {
        let sut = makeSUT(status: errSecSuccess)
        
        let params = makeParams()
        
        do {
            try sut.write(params)
        } catch let error {
            XCTFail("Expect receive an success but got \(error) instead")
        }
    }
    
    func test_onWrite_resturnsInternalError_noDelieversUnexpectedErrorWithRealError() {
        assertUnexpectedError(on: errSecInternalError)
    }
    
    func test_onWrite_resturnsBadRequestError_noDelieversUnexpectedErrorAssociatedBadRequest() {
        assertUnexpectedError(on: errSecBadReq)
    }
    
    func test_onWrite_resturnsMemoryError_noDelieversUnexpectedErrorAssociatedMemory() {
        assertUnexpectedError(on: errSecMemoryError)
    }
    
    func test_onWrite_resturnsDuplicateItemError_noDelieversUnexpectedErrorAssociatedDuplicateItem() {
        assertUnexpectedError(on: errSecDuplicateItem)
    }
}

private extension KeychainWritterAdapterTests {
    
    typealias Reference = UnsafeMutablePointer<CFTypeRef?>
    typealias Params = NSDictionary
    
    func makeSUT(
        status error: OSStatus = errSecItemNotFound,
        onWrite: @escaping (Params, Reference?) -> Void = { _, _ in }
    ) -> KeychainWritterAdapter {
        return KeychainWritterAdapter { params, reference in
            onWrite(params, reference)
            return error
        }
    }
    
    func assertUnexpectedError(
        on expectedStatus: OSStatus,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let sut = makeSUT(status: expectedStatus)
        
        let params = makeParams()
        
        do {
            try sut.write(params)
            XCTFail("Expect receive an unexpactedError but all working", file: file, line: line)
        } catch let KeychainError.unexpected(receivedError) {
            XCTAssertEqual(receivedError, expectedStatus, file: file, line: line)
        } catch let error {
            XCTFail("Expect receive an unexpactedError but got \(error) instead", file: file, line: line)
        }
    }
    
    func makeParams(
        application: String = "any_default_application",
        identifier: String = "any_default_identifier",
        secure: Data = Data("any_default_application".utf8)
    ) -> WritterParams {
        WritterParams(
            application: application,
            identifier: identifier,
            secure: secure
        )
    }
}
