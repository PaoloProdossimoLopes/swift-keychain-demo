import XCTest
@testable import swift_keychain_adavanced_demo

final class KeychainUpdaterAdapterTests: XCTestCase {
    func test_onInit_noPerformsupdateOperation() {
        var operationCounter = 0
        _ = makeSUT(onUpdate: { _, _ in
            operationCounter += 1
        })
        
        XCTAssertEqual(operationCounter, 0)
    }
    
    func test_onUpdate_withParams_callupdateOnce() {
        var operationCounter = 0
        let params = makeParams()
        let sut = makeSUT(onUpdate: { _, _ in
            operationCounter += 1
        })
        
        try? sut.update(params)
        
        XCTAssertEqual(operationCounter, 1)
    }
    
    func test_onUpdate_withParams_callsWithCorrectParams() {
        let application = "any application"
        let identifier = "any identifier"
        let secure = Data("any security".utf8)
        let params = makeParams(
            application: application,
            identifier: identifier,
            secure: secure
        )
        var receivedParams: Params?
        var receivedAttributes: Params?
        let sut = makeSUT(onUpdate: { params, attributes in
            receivedParams = params
            receivedAttributes = attributes
        })
        
        try? sut.update(params)
        
        XCTAssertEqual(receivedParams?[kSecAttrService] as? String, application)
        XCTAssertEqual(receivedParams?[kSecAttrAccount] as? String, identifier)
        XCTAssertEqual(receivedParams?[kSecClass] as? String, kSecClassGenericPassword as String)
        XCTAssertEqual(receivedAttributes?[kSecValueData] as? Data, secure)
    }
    
    func test_onUpdate_resturnsItemNotFound_delieversNotFoundError() {
        let sut = makeSUT(status: errSecItemNotFound)
        let params = makeParams()
        
        var receivedError: Error?
        do {
            try sut.update(params)
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
    
    func test_onUpdate_resturnsSuccess_noDelieversAnyError() {
        let sut = makeSUT(status: errSecSuccess)
        
        let params = makeParams()
        
        do {
            try sut.update(params)
        } catch let error {
            XCTFail("Expect receive an success but got \(error) instead")
        }
    }
    
    func test_onUpdate_resturnsInternalError_noDelieversUnexpectedErrorWithRealError() {
        assertUnexpectedError(on: errSecInternalError)
    }
    
    func test_onUpdate_resturnsBadRequestError_noDelieversUnexpectedErrorAssociatedBadRequest() {
        assertUnexpectedError(on: errSecBadReq)
    }
    
    func test_onUpdate_resturnsMemoryError_noDelieversUnexpectedErrorAssociatedMemory() {
        assertUnexpectedError(on: errSecMemoryError)
    }
    
    func test_onUpdate_resturnsDuplicateItemError_noDelieversUnexpectedErrorAssociatedDuplicateItem() {
        assertUnexpectedError(on: errSecDuplicateItem)
    }
}

private extension KeychainUpdaterAdapterTests {
    
    typealias Reference = CFDictionary
    typealias Params = NSDictionary
    
    func makeSUT(
        status error: OSStatus = errSecItemNotFound,
        onUpdate: @escaping (Params, Reference?) -> Void = { _, _ in }
    ) -> KeychainUpdaterAdapter {
        return KeychainUpdaterAdapter { params, reference in
            onUpdate(params, reference)
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
            try sut.update(params)
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
    ) -> UpdateParams {
        
        UpdateParams(
            application: application,
            identifier: identifier,
            security: secure
        )
    }
}
