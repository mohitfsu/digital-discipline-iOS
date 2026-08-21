import Foundation
import CoreLocation
import Combine

/// Central CoreLocation manager handling GPS fixes and authorization
@MainActor
public final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationManager()
    
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var currentLocation: CLLocation?
    @Published public var isLocating: Bool = false
    @Published public var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    public func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Requests a single one-shot location fix for "Use Current Location"
    public func requestCurrentLocation() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            requestAuthorization()
            return
        }
        
        isLocating = true
        errorMessage = nil
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLoc = locations.last
        Task { @MainActor in
            self.isLocating = false
            if let loc = lastLoc {
                self.currentLocation = loc
                
                // Save last known location to App Group
                UserDefaults(suiteName: AppStorageKeys.appGroupName)?.set(loc.coordinate.latitude, forKey: AppStorageKeys.lastKnownLocationLat)
                UserDefaults(suiteName: AppStorageKeys.appGroupName)?.set(loc.coordinate.longitude, forKey: AppStorageKeys.lastKnownLocationLng)
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let desc = error.localizedDescription
        Task { @MainActor in
            self.isLocating = false
            self.errorMessage = "Location fix failed: \(desc)"
            print("Location manager error: \(desc)")
        }
    }
}
