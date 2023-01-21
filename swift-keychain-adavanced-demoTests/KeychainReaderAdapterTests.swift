import XCTest
@testable import swift_keychain_adavanced_demo

final class KeychainReaderAdapterTests: XCTestCase {
    func test_onInit_noPerformsWriteOperation() {
        var operationCounter = 0
        _ = makeSUT(onRead: { _, _ in
            operationCounter += 1
        })
        
        XCTAssertEqual(operationCounter, 0)
    }
    
    func test_onRead_withParams_callListOnce() {
        var operationCounter = 0
        let params = makeParams()
        let (sut, _) = makeSUT(onRead: { _, _ in
            operationCounter += 1
        })
        
        _ = try? sut.read(params)
        
        XCTAssertEqual(operationCounter, 1)
    }
    
    func test_onRead_withParams_callsWithCorrectParams() {
        let application = "any application"
        let identifier = "any identifier"
        let params = makeParams(application: application, identifier: identifier)
        var receivedParams: Params?
        let (sut, _) = makeSUT(onRead: { params, _ in
            receivedParams = params
        })
        
        _ = try? sut.read(params)
        
        XCTAssertEqual(receivedParams?[kSecClass] as? String, kSecClassGenericPassword as String)
        XCTAssertEqual(receivedParams?[kSecAttrService] as? String, application)
        XCTAssertEqual(receivedParams?[kSecAttrAccount] as? String, identifier)
        XCTAssertEqual(receivedParams?[kSecReturnData] as? Bool, true)
    }
    
    func test_onRead_withParams_callsWithNoReference() {
        let params = makeParams()
        var referenceReceived: Reference?
        let (sut, _) = makeSUT(onRead: { _, reference in
            referenceReceived = reference
        })
        
        _ = try? sut.read(params)
        
        XCTAssertNotNil(referenceReceived)
    }
    
    func test_onRead_resturnsItemNotFound_delieversNotFoundError() {
        let (sut, _) = makeSUT(status: errSecItemNotFound)
        let params = makeParams()
        
        var receivedError: Error?
        do {
            _ = try sut.read(params)
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
    
    func test_onRead_resturnsSuccess_noDelieversAnyError() {
        let (sut, _) = makeSUT(status: errSecSuccess)
        let params = makeParams(application: "test.example.com", identifier: "tester 0")
        
        var result: ReadResult!
        do {
            result = try sut.read(params)
        } catch let error {
            XCTFail("Expect receive an success but got \(error) instead")
        }
        
        let recievedScure = String(decoding: result.secure, as: UTF8.self)
        XCTAssertEqual(recievedScure, "tester password 0")
    }
    
    func test_onRead_resturnsInternalError_noDelieversUnexpectedErrorWithRealError() {
        assertUnexpectedError(on: errSecInternalError)
    }
    
    func test_onRead_resturnsBadRequestError_noDelieversUnexpectedErrorAssociatedBadRequest() {
        assertUnexpectedError(on: errSecBadReq)
    }
    
    func test_onRead_resturnsMemoryError_noDelieversUnexpectedErrorAssociatedMemory() {
        assertUnexpectedError(on: errSecMemoryError)
    }
    
    func test_onRead_resturnsDuplicateItemError_noDelieversUnexpectedErrorAssociatedDuplicateItem() {
        assertUnexpectedError(on: errSecDuplicateItem)
    }
}

private extension KeychainReaderAdapterTests {
    
    typealias Reference = UnsafeMutablePointer<CFTypeRef?>
    typealias Params = NSDictionary
    
    private func makeSUT(
        status error: OSStatus = errSecItemNotFound,
        onRead: @escaping (Params, Reference?) -> Void = { _, _ in }
    ) -> (KeychainReaderAdapter, KeychainListerFaker) {
        let keychain = KeychainListerFaker()
        let sut =  KeychainReaderAdapter { params, reference in
            keychain.read(params, reference)
            onRead(params, reference)
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
            try _ = sut.read(params)
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
    ) -> ReadParams {
        ReadParams(application: application, identifier: identifier)
    }
    
    private final class KeychainListerFaker {
        var storage: [NSDictionary] = [
            KeychainListerFaker.makeDict(number: 0),
            KeychainListerFaker.makeDict(number: 1),
            KeychainListerFaker.makeDict(number: 2)
        ]
        
        func read(_ param: Params, _ reference: Reference?) {
            let filteredDict = storage.first {
                $0[kSecAttrAccount] as! String == param[kSecAttrAccount] as! String
            }
            let securyData = filteredDict?[kSecValueData]
            reference?.initialize(to: securyData as CFTypeRef)
        }
        
        static func makeDict(number: Int) -> NSDictionary {
            NSDictionary(dictionaryLiteral:
                (kSecAttrService, "test.example.com"),
                (kSecAttrAccount, "tester \(number)"),
                (kSecValueData, Data("tester password \(number)".utf8))
            )
        }
    }
}
