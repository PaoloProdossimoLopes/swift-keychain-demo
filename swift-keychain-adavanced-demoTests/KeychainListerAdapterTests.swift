import XCTest
@testable import swift_keychain_adavanced_demo

final class KeychainListerAdapterTests: XCTestCase {
    func test_onInit_noPerformsWriteOperation() {
        var operationCounter = 0
        _ = makeSUT(onList: { _, _ in
            operationCounter += 1
        })
        
        XCTAssertEqual(operationCounter, 0)
    }
    
    func test_onWrite_withParams_callListOnce() {
        var operationCounter = 0
        let params = makeParams()
        let (sut, _) = makeSUT(onList: { _, _ in
            operationCounter += 1
        })
        
        _ = try? sut.list(params)
        
        XCTAssertEqual(operationCounter, 1)
    }
    
    func test_onWrite_withParams_callsWithCorrectParams() {
        let application = "any application"
        let params = makeParams(application: application)
        var receivedParams: Params?
        let (sut, _) = makeSUT(onList: { params, _ in
            receivedParams = params
        })
        
        _ = try? sut.list(params)
        
        XCTAssertEqual(receivedParams?[kSecClass] as? String, kSecClassGenericPassword as String)
        XCTAssertEqual(receivedParams?[kSecAttrService] as? String, application)
        XCTAssertEqual(receivedParams?[kSecReturnAttributes] as? Bool, true)
        XCTAssertEqual(receivedParams?[kSecReturnData] as? Bool, true)
        XCTAssertEqual(receivedParams?[kSecMatchLimit] as? Int, 5)

    }
    
    func test_onWrite_withParams_callsWithNoReference() {
        let params = makeParams()
        var referenceReceived: Reference?
        let (sut, _) = makeSUT(onList: { _, reference in
            referenceReceived = reference
        })
        
        _ = try? sut.list(params)
        
        XCTAssertNotNil(referenceReceived)
    }
    
    func test_onWrite_resturnsItemNotFound_delieversNotFoundError() {
        let (sut, _) = makeSUT(status: errSecItemNotFound)
        let params = makeParams()
        
        var receivedError: Error?
        do {
            _ = try sut.list(params)
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
        let (sut, _) = makeSUT(status: errSecSuccess)
        let params = makeParams()
        
        var result: [ListResult]?
        do {
            result = try sut.list(params)
        } catch let error {
            XCTFail("Expect receive an success but got \(error) instead")
        }
        
        XCTAssertEqual(result?.count, 3)
        
        assertResult(result, at: 0)
        assertResult(result, at: 1)
        assertResult(result, at: 2)
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

private extension KeychainListerAdapterTests {
    
    typealias Reference = UnsafeMutablePointer<CFTypeRef?>
    typealias Params = NSDictionary
    
    private func makeSUT(
        status error: OSStatus = errSecItemNotFound,
        onList: @escaping (Params, Reference?) -> Void = { _, _ in }
    ) -> (KeychainListerAdapter, KeychainListerFaker) {
        let keychain = KeychainListerFaker()
        let sut =  KeychainListerAdapter { params, reference in
            keychain.list(params, reference)
            onList(params, reference)
            return error
        }
        return (sut, keychain)
    }
    
    func assertUnexpectedError(
        on expectedStatus: OSStatus,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let (sut, _) = makeSUT(status: expectedStatus)
        
        let params = makeParams()
        
        do {
            try _ = sut.list(params)
            XCTFail("Expect receive an unexpactedError but all working", file: file, line: line)
        } catch let KeychainError.unexpected(receivedError) {
            XCTAssertEqual(receivedError, expectedStatus, file: file, line: line)
        } catch let error {
            XCTFail("Expect receive an unexpactedError but got \(error) instead", file: file, line: line)
        }
    }
    
    func makeParams(application: String = "any_default_application") -> ListParams {
        ListParams(application: application)
    }
    
    private final class KeychainListerFaker {
        var storage: [NSDictionary] = [
            KeychainListerFaker.makeDict(number: 0),
            KeychainListerFaker.makeDict(number: 1),
            KeychainListerFaker.makeDict(number: 2)
        ]
        
        func list(_ param: Params, _ reference: Reference?) {
            reference?.initialize(to: storage as CFTypeRef)
        }
        
        static func makeDict(number: Int) -> NSDictionary {
            NSDictionary(dictionaryLiteral:
                (kSecAttrService, "test.example.com"),
                (kSecAttrAccount, "tester \(number)"),
                (kSecValueData, Data("tester password \(number)".utf8))
            )
        }
    }
    
    func assertResult(
        _ result: [ListResult]?, at index: Int,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertEqual(result?[index].application, "test.example.com", file: file, line: line)
        XCTAssertEqual(result?[index].identifier, "tester \(index)", file: file, line: line)
        XCTAssertEqual(result?[index].security, "tester password \(index)", file: file, line: line)
    }
}
