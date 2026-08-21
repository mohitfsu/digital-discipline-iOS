import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

/// DeviceActivityMonitor extension running in an isolated background process to toggle shields atomically
public class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()
    private let appGroupName = "group.com.digitaldiscipline.app"
    
    public override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("DeviceActivityMonitor: intervalDidStart for \(activity.rawValue)")
        
        // Enforce application and category shields
        applyStoredShields()
    }
    
    public override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("DeviceActivityMonitor: intervalDidEnd for \(activity.rawValue)")
        
        // Clear shields upon schedule completion
        clearShields()
    }
    
    public override func eventDidReachThreshold(for activity: DeviceActivityName, event: DeviceActivityEvent.Name) {
        super.eventDidReachThreshold(for: activity, event: event)
        print("DeviceActivityMonitor: eventDidReachThreshold for \(event.rawValue)")
        
        // Apply immediate lock when daily threshold is exhausted
        applyStoredShields()
    }
    
    public override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("DeviceActivityMonitor: 5-minute schedule warning for \(activity.rawValue)")
    }
    
    private func applyStoredShields() {
        guard let defaults = UserDefaults(suiteName: appGroupName),
              let data = defaults.data(forKey: "digitaldiscipline.selected_activity") else {
            return
        }
        
        do {
            let selection = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            
            // Apply Application Shields
            store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            
            // Apply Category Shields
            if !selection.categoryTokens.isEmpty {
                store.shield.applicationCategories = .specific(selection.categoryTokens)
                store.shield.webDomainCategories = .specific(selection.categoryTokens)
            }
            
            // Apply Anti-Tamper rules
            store.application.denyAppRemoval = true
            store.dateAndTime.requireAutomaticDateAndTime = true
            store.account.lockAccounts = true
            
            // Record block event
            let blockAttempts = defaults.integer(forKey: "digitaldiscipline.telemetry.block_attempts")
            defaults.set(blockAttempts + 1, forKey: "digitaldiscipline.telemetry.block_attempts")
            
        } catch {
            print("Failed to decode activity selection in DeviceActivity extension: \(error)")
        }
    }
    
    private func clearShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
    }
}
