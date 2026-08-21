import Foundation
import Combine

/// Pairing payload stored in Firestore at `pairingCodes/{code}`
public struct PairingCodePayload: Codable, Sendable {
    public let code: String
    public let familyId: String
    public let parentUserId: String
    public let createdAt: Date
    public let expiresAt: Date
    
    public var isExpired: Bool {
        Date() > expiresAt
    }
}

/// Generates and redeems 6-character family pairing codes
@MainActor
public final class PairingManager: ObservableObject {
    public static let shared = PairingManager()
    
    @Published public var activePairingCode: String?
    @Published public var codeExpiresAt: Date?
    @Published public var isPaired: Bool = false
    @Published public var linkedFamilyId: String?
    @Published public var linkedChildId: String?
    @Published public var isParentMode: Bool = true
    @Published public var pairingError: String?
    
    private let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName)
    
    private init() {
        loadPairingState()
    }
    
    public func loadPairingState() {
        self.isPaired = defaults?.bool(forKey: AppStorageKeys.isPaired) ?? false
        self.linkedFamilyId = defaults?.string(forKey: AppStorageKeys.familyId)
        self.linkedChildId = defaults?.string(forKey: AppStorageKeys.childId)
        self.isParentMode = defaults?.object(forKey: AppStorageKeys.isParentMode) as? Bool ?? true
        self.activePairingCode = defaults?.string(forKey: AppStorageKeys.pairingCode)
    }
    
    /// Generates a new 6-character pairing code valid for 15 minutes (Parent Device)
    public func generatePairingCode(familyId: String, parentId: String) -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Excludes confusing 0/O, 1/I
        let code = String((0..<6).map { _ in chars.randomElement()! })
        let expiresAt = Date().addingTimeInterval(15 * 60)
        
        self.activePairingCode = code
        self.codeExpiresAt = expiresAt
        
        defaults?.set(code, forKey: AppStorageKeys.pairingCode)
        defaults?.set(familyId, forKey: AppStorageKeys.familyId)
        defaults?.set(true, forKey: AppStorageKeys.isParentMode)
        
        return code
    }
    
    /// Redeems 6-character code on Child Device and links family workspace
    public func redeemPairingCode(_ enteredCode: String) async -> Bool {
        pairingError = nil
        let sanitized = enteredCode.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard sanitized.count == 6 else {
            pairingError = "Pairing code must be 6 characters."
            return false
        }
        
        // Simulating cloud lookup in Firestore `pairingCodes/{code}`
        try? await Task.sleep(nanoseconds: 700_000_000)
        
        let assignedFamilyId = "fam_\(sanitized.prefix(4).lowercased())"
        let generatedChildId = "child_\(UUID().uuidString.prefix(8).lowercased())"
        
        self.isPaired = true
        self.linkedFamilyId = assignedFamilyId
        self.linkedChildId = generatedChildId
        self.isParentMode = false
        
        defaults?.set(true, forKey: AppStorageKeys.isPaired)
        defaults?.set(assignedFamilyId, forKey: AppStorageKeys.familyId)
        defaults?.set(generatedChildId, forKey: AppStorageKeys.childId)
        defaults?.set(false, forKey: AppStorageKeys.isParentMode)
        
        HapticFeedbackManager.shared.workoutCompleted()
        return true
    }
    
    /// Unpairs device from family workspace
    public func unpairDevice() {
        defaults?.removeObject(forKey: AppStorageKeys.isPaired)
        defaults?.removeObject(forKey: AppStorageKeys.familyId)
        defaults?.removeObject(forKey: AppStorageKeys.childId)
        defaults?.removeObject(forKey: AppStorageKeys.pairingCode)
        
        self.isPaired = false
        self.linkedFamilyId = nil
        self.linkedChildId = nil
        self.activePairingCode = nil
    }
}
