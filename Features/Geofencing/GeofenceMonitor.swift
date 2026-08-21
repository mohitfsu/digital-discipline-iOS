import Foundation
import CoreLocation
import UserNotifications
import Combine

/// Background Geofence monitor managing circular perimeters and automated profile switching
@MainActor
public final class GeofenceMonitor: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = GeofenceMonitor()
    
    @Published public var activeGeofenceZone: GeofenceZone?
    
    private let locationManager = CLLocationManager()
    private let dataStore = SharedDataStore.shared
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    /// Synchronizes monitored regions with the currently saved geofences
    public func synchronizeGeofences() {
        // Stop previous regions
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        
        let zones = dataStore.geofences.filter { $0.isEnabled }
        for zone in zones {
            let region = zone.circularRegion
            locationManager.startMonitoring(for: region)
            print("Started geofence monitoring for zone: \(zone.name) (radius: \(zone.radiusMeters)m)")
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    nonisolated public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circular = region as? CLCircularRegion else { return }
        let regionId = circular.identifier
        
        Task { @MainActor in
            guard let matchedZone = self.dataStore.geofences.first(where: { $0.id == regionId }) else {
                return
            }
            
            self.activeGeofenceZone = matchedZone
            UserDefaults(suiteName: AppStorageKeys.appGroupName)?.set(matchedZone.id, forKey: AppStorageKeys.activeGeofenceId)
            
            // Auto-apply matched zone profile
            ProfileTemplateManager.shared.applyPresetType(matchedZone.assignedProfileType)
            ShieldManager.shared.enforceShields()
            
            self.sendLocalNotification(
                title: "📍 Entered Geofence: \(matchedZone.name)",
                body: "Switched to \(matchedZone.assignedProfileType.displayName). Distraction shields are now active."
            )
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circular = region as? CLCircularRegion else { return }
        let regionId = circular.identifier
        
        Task { @MainActor in
            guard let matchedZone = self.dataStore.geofences.first(where: { $0.id == regionId }) else {
                return
            }
            
            if self.activeGeofenceZone?.id == matchedZone.id {
                self.activeGeofenceZone = nil
                UserDefaults(suiteName: AppStorageKeys.appGroupName)?.removeObject(forKey: AppStorageKeys.activeGeofenceId)
            }
            
            self.sendLocalNotification(
                title: "📍 Exited Geofence: \(matchedZone.name)",
                body: "Leaving designated zone. Policy restrictions adjusted."
            )
        }
    }
    
    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
