import XCTest
@testable import swift_keychain_adavanced_demo

final class KeychainDeleterAdapterTests: XCTestCase {
    func test_onInit_noPerformsdeleteOperation() {
        var operationCounter = 0
        _ = makeSUT(onDelete: { _ in
            operationCounter += 1
        })
        
        XCTAssertEqual(operationCounter, 0)
    }
    
    func test_onDelete_withParams_calldeleteOnce() {
        var operationCounter = 0
        let params = makeParams()
        let sut = makeSUT(onDelete: { _ in
            operationCounter += 1
        })
        
        try? sut.delete(params)
        
        XCTAssertEqual(operationCounter, 1)
    }
    
    func test_onDelete_withParams_callsWithCorrectParams() {
        let application = "any application"
        let identifier = "any identifier"
        let params = makeParams(
            application: application,
            identifier: identifier
        )
        var receivedParams: Params?
        let sut = makeSUT(onDelete: { params in
            receivedParams = params
        })
        
        try? sut.delete(params)
        
        XCTAssertEqual(receivedParams?[kSecAttrService] as? String, application)
        XCTAssertEqual(receivedParams?[kSecAttrAccount] as? String, identifier)
        XCTAssertEqual(receivedParams?[kSecClass] as? String, kSecClassGenericPassword as String)
    }
    
    func test_onDelete_resturnsItemNotFound_delieversNotFoundError() {
        let sut = makeSUT(status: errSecItemNotFound)
        let params = makeParams()
        
        var receivedError: Error?
        do {
            try sut.delete(params)
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
    
    func test_onDelete_resturnsSuccess_noDelieversAnyError() {
        let sut = makeSUT(status: errSecSuccess)
        
        let params = makeParams()
        
        do {
            try sut.delete(params)
        } catch let error {
            XCTFail("Expect receive an success but got \(error) instead")
        }
    }
    
    func test_onDelete_resturnsInternalError_noDelieversUnexpectedErrorWithRealError() {
        assertUnexpectedError(on: errSecInternalError)
    }
    
    func test_onDelete_resturnsBadRequestError_noDelieversUnexpectedErrorAssociatedBadRequest() {
        assertUnexpectedError(on: errSecBadReq)
    }
    
    func test_onDelete_resturnsMemoryError_noDelieversUnexpectedErrorAssociatedMemory() {
        assertUnexpectedError(on: errSecMemoryError)
    }
    
    func test_onDelete_resturnsDuplicateItemError_noDelieversUnexpectedErrorAssociatedDuplicateItem() {
        assertUnexpectedError(on: errSecDuplicateItem)
    }
}

private extension KeychainDeleterAdapterTests {
    
    typealias Reference = UnsafeMutablePointer<CFTypeRef?>
    typealias Params = NSDictionary
    
    func makeSUT(
        status error: OSStatus = errSecItemNotFound,
        onDelete: @escaping (Params) -> Void = { _ in }
    ) -> KeychainDeleterAdapter {
        return KeychainDeleterAdapter { params in
            onDelete(params)
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
            try sut.delete(params)
            XCTFail("Expect receive an unexpactedError but all working", file: file, line: line)
        } catch let KeychainError.unexpected(receivedError) {
            XCTAssertEqual(receivedError, expectedStatus, file: file, line: line)
        } catch let error {
            XCTFail("Expect receive an unexpactedError but got \(error) instead", file: file, line: line)
        }
    }
    
    func makeParams(
        application: String = "any_default_application",
        identifier: String = "any_default_identifier"
    ) -> DeleteParams {
        DeleteParams(
            application: application,
            identifier: identifier
        )
    }
}
