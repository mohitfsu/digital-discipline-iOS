import Foundation
import CryptoKit

/// Manages parent PIN configuration, cryptographic SHA-256 verification, and rate-limited lockout
public final class ParentPinManager: Sendable {
    public static let shared = ParentPinManager()
    
    private let pinHashKey = "digitaldiscipline.parent.pin.hash"
    private let pinSaltKey = "digitaldiscipline.parent.pin.salt"
    private let failedAttemptsKey = "digitaldiscipline.pin.failed_attempts"
    private let lockoutUntilKey = "digitaldiscipline.pin.lockout_until"
    
    private let keychain = KeychainManager.shared
    
    private init() {}
    
    public var isPinSet: Bool {
        return keychain.load(key: pinHashKey) != nil
    }
    
    /// Sets a new 4 to 6-digit parent PIN with a unique cryptographically secure salt
    @discardableResult
    public func setPin(_ pin: String) -> Bool {
        guard pin.count >= 4 && pin.count <= 6, pin.allSatisfy(\.isNumber) else {
            return false
        }
        
        let salt = UUID().uuidString
        let hash = computeHash(pin: pin, salt: salt)
        
        let savedSalt = keychain.save(key: pinSaltKey, string: salt)
        let savedHash = keychain.save(key: pinHashKey, data: hash)
        
        if savedSalt && savedHash {
            resetFailedAttempts()
            return true
        }
        return false
    }
    
    /// Verifies the entered PIN against the salted SHA-256 hash with lockout protection
    public func verifyPin(_ enteredPin: String) -> PinVerificationResult {
        if let lockoutDate = getLockoutExpiry(), lockoutDate > Date() {
            let remainingSeconds = Int(lockoutDate.timeIntervalSince(Date()))
            return .lockedOut(remainingSeconds: remainingSeconds)
        }
        
        guard let salt = keychain.loadString(key: pinSaltKey),
              let storedHash = keychain.load(key: pinHashKey) else {
            return .pinNotConfigured
        }
        
        let computedHash = computeHash(pin: enteredPin, salt: salt)
        
        if computedHash == storedHash {
            resetFailedAttempts()
            return .success
        } else {
            let attempts = recordFailedAttempt()
            if attempts >= 5 {
                let lockoutSeconds = 300 // 5 minutes
                setLockout(duration: TimeInterval(lockoutSeconds))
                return .lockedOut(remainingSeconds: lockoutSeconds)
            } else if attempts >= 3 {
                let lockoutSeconds = 60 // 1 minute
                setLockout(duration: TimeInterval(lockoutSeconds))
                return .lockedOut(remainingSeconds: lockoutSeconds)
            }
            return .invalidPin(attemptsRemaining: max(0, 5 - attempts))
        }
    }
    
    private func computeHash(pin: String, salt: String) -> Data {
        let combined = "\(salt):\(pin)"
        let digest = SHA256.hash(data: Data(combined.utf8))
        return Data(digest)
    }
    
    private func recordFailedAttempt() -> Int {
        let current = UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.integer(forKey: failedAttemptsKey) ?? 0
        let updated = current + 1
        UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.set(updated, forKey: failedAttemptsKey)
        return updated
    }
    
    private func resetFailedAttempts() {
        UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.set(0, forKey: failedAttemptsKey)
        UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.removeObject(forKey: lockoutUntilKey)
    }
    
    private func setLockout(duration: TimeInterval) {
        let expiry = Date().addingTimeInterval(duration)
        UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.set(expiry.timeIntervalSince1970, forKey: lockoutUntilKey)
    }
    
    public func getLockoutExpiry() -> Date? {
        let timestamp = UserDefaults(suiteName: "group.com.digitaldiscipline.app")?.double(forKey: lockoutUntilKey) ?? 0
        guard timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
}

public enum PinVerificationResult: Equatable, Sendable {
    case success
    case invalidPin(attemptsRemaining: Int)
    case lockedOut(remainingSeconds: Int)
    case pinNotConfigured
}
