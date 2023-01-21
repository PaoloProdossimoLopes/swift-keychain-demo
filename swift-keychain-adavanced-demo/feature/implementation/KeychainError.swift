import Foundation

enum KeychainError: Error {
    case notFound
    case invalidItemFormat
    case unexpected(OSStatus)
}
