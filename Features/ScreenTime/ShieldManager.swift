import Foundation
import ManagedSettings
import FamilyControls
import Combine

/// Core controller interfacing directly with Apple's ManagedSettings framework
@MainActor
public final class ShieldManager: ObservableObject {
    public static let shared = ShieldManager()
    
    private let store = ManagedSettingsStore()
    private let dataStore = SharedDataStore.shared
    
    @Published public var activitySelection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveActivitySelection()
        }
    }
    
    @Published public var isShieldCurrentlyActive: Bool = false
    
    private init() {
        loadActivitySelection()
    }
    
    /// Loads stored FamilyActivitySelection from shared App Group
    public func loadActivitySelection() {
        guard let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName),
              let data = defaults.data(forKey: AppStorageKeys.activitySelectionData) else {
            return
        }
        
        do {
            let decoded = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            self.activitySelection = decoded
        } catch {
            print("Failed to decode FamilyActivitySelection: \(error)")
        }
    }
    
    /// Saves FamilyActivitySelection to shared App Group container
    public func saveActivitySelection() {
        guard let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName) else { return }
        do {
            let encoded = try PropertyListEncoder().encode(activitySelection)
            defaults.set(encoded, forKey: AppStorageKeys.activitySelectionData)
        } catch {
            print("Failed to encode FamilyActivitySelection: \(error)")
        }
    }
    
    /// Activates OS-level Shield for all selected applications and categories
    public func enforceShields() {
        guard !dataStore.isTemporaryUnlockActive() else {
            print("Temporary unlock is active. Skipping immediate shield enforcement.")
            return
        }
        
        // Apply Application Shields
        store.shield.applications = activitySelection.applicationTokens.isEmpty ? nil : activitySelection.applicationTokens
        
        // Apply Category Shields
        if !activitySelection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(activitySelection.categoryTokens)
            store.shield.webDomainCategories = .specific(activitySelection.categoryTokens)
        } else {
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
        }
        
        // Apply Anti-Tamper Policies if enabled in active profile
        applyAntiTamperPolicies(enabled: dataStore.isAntiTamperEnabled)
        
        isShieldCurrentlyActive = true
        dataStore.setShieldEnforced(true)
    }
    
    /// Removes application shields immediately
    public func clearShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
        
        isShieldCurrentlyActive = false
        dataStore.setShieldEnforced(false)
    }
    
    /// Temporarily lifts shield protection for the given duration after a workout or parent approval
    public func grantTemporaryUnlock(durationMinutes: Int) {
        clearShields()
        dataStore.recordUnlockGranted(durationMinutes: durationMinutes)
        
        // Schedule re-enforcement after duration
        Task {
            try? await Task.sleep(nanoseconds: UInt64(durationMinutes * 60) * 1_000_000_000)
            await MainActor.run {
                if !self.dataStore.isTemporaryUnlockActive() {
                    self.enforceShields()
                }
            }
        }
    }
    
    /// Configures anti-removal, date & time lockout, and iCloud account sign-out restrictions
    public func applyAntiTamperPolicies(enabled: Bool) {
        if enabled {
            // Anti-Uninstall Lockout: Prevents deleting the app from iOS Home Screen
            store.application.denyAppRemoval = true
            
            // Anti-Clock Tamper: Forces automatic time to prevent bypassing schedules
            store.dateAndTime.requireAutomaticDateAndTime = true
            
            // Account Lockout: Prevents modifying or signing out of iCloud
            store.account.lockAccounts = true
        } else {
            store.application.denyAppRemoval = false
            store.dateAndTime.requireAutomaticDateAndTime = false
            store.account.lockAccounts = false
        }
    }
}
