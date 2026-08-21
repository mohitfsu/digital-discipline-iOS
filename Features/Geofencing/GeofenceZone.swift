import Foundation
import CoreLocation

/// Preset categories for quick 1-tap geofence configuration
public enum GeofencePreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case office = "OFFICE"
    case school = "SCHOOL"
    case library = "LIBRARY"
    case custom = "CUSTOM"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .office: return "🏢 Office HQ"
        case .school: return "👨‍👩‍👧 School Campus"
        case .library: return "📚 City Library"
        case .custom: return "⚡ Custom Zone"
        }
    }
    
    public var defaultRadius: Double {
        switch self {
        case .office: return 150.0
        case .school: return 300.0
        case .library: return 100.0
        case .custom: return 200.0
        }
    }
    
    public var defaultProfile: ProfileType {
        switch self {
        case .office: return .corporate
        case .school: return .family
        case .library: return .deepWork
        case .custom: return .custom
        }
    }
}

/// Geofence zone configuration model
public struct GeofenceZone: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var radiusMeters: Double
    public var preset: GeofencePreset
    public var assignedProfileType: ProfileType
    public var isEnabled: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 150.0,
        preset: GeofencePreset = .office,
        assignedProfileType: ProfileType = .corporate,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.preset = preset
        self.assignedProfileType = assignedProfileType
        self.isEnabled = isEnabled
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var circularRegion: CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: radiusMeters,
            identifier: id
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}
