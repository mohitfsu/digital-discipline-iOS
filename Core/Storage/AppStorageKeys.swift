import Foundation

/// Centralized storage keys for UserDefaults and App Group shared suite
public enum AppStorageKeys {
    public static let appGroupName = "group.com.digitaldiscipline.app"
    
    public static let activeProfile = "digitaldiscipline.active_profile"
    public static let savedProfiles = "digitaldiscipline.saved_profiles"
    public static let activeSchedules = "digitaldiscipline.schedules"
    public static let geofences = "digitaldiscipline.geofences"
    public static let activitySelectionData = "digitaldiscipline.selected_activity"
    public static let isShieldEnforced = "digitaldiscipline.is_shield_enforced"
    public static let antiTamperEnabled = "digitaldiscipline.anti_tamper_enabled"
    
    public static let temporaryUnlockExpiry = "digitaldiscipline.temporary_unlock_expiry"
    public static let temporaryUnlockGrantedMinutes = "digitaldiscipline.temporary_unlock_granted_minutes"
    
    public static let totalSquatReps = "digitaldiscipline.telemetry.total_squats"
    public static let totalBreathingSessions = "digitaldiscipline.telemetry.total_breathing_sessions"
    public static let blockAttemptsCount = "digitaldiscipline.telemetry.block_attempts"
    public static let dailyUnlockCount = "digitaldiscipline.telemetry.daily_unlocks"
    
    public static let pairingCode = "digitaldiscipline.cloud.pairing_code"
    public static let familyId = "digitaldiscipline.cloud.family_id"
    public static let childId = "digitaldiscipline.cloud.child_id"
    public static let isPaired = "digitaldiscipline.cloud.is_paired"
    public static let isParentMode = "digitaldiscipline.cloud.is_parent_mode"
    
    public static let lastKnownLocationLat = "digitaldiscipline.location.lat"
    public static let lastKnownLocationLng = "digitaldiscipline.location.lng"
    public static let activeGeofenceId = "digitaldiscipline.location.active_geofence_id"
}
