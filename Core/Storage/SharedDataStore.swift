import Foundation
import Combine

/// Centralized data store synchronized via App Group UserDefaults
@MainActor
public final class SharedDataStore: ObservableObject {
    public static let shared = SharedDataStore()
    
    private let defaults: UserDefaults?
    
    @Published public var hasCompletedOnboarding: Bool {
        didSet {
            defaults?.set(hasCompletedOnboarding, forKey: AppStorageKeys.hasCompletedOnboarding)
        }
    }
    
    @Published public var activeProfile: PolicyProfile {
        didSet {
            saveActiveProfile()
        }
    }
    
    @Published public var savedProfiles: [PolicyProfile] = [] {
        didSet {
            saveProfilesList()
        }
    }
    
    @Published public var geofences: [GeofenceZone] = [] {
        didSet {
            saveGeofences()
        }
    }
    
    @Published public var totalSquatReps: Int = 0
    @Published public var totalBreathingSessions: Int = 0
    @Published public var blockAttemptsCount: Int = 0
    @Published public var dailyUnlockCount: Int = 0
    @Published public var isShieldEnforced: Bool = false
    @Published public var isAntiTamperEnabled: Bool = true
    
    private init() {
        self.defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName)
        self.hasCompletedOnboarding = defaults?.bool(forKey: AppStorageKeys.hasCompletedOnboarding) ?? false
        
        // Initialize default profile if none exists
        let defaultProfile = PolicyProfile(
            type: .selfDiscipline,
            name: "🧘 Self-Discipline Mode",
            description: "Break doomscrolling loops with 30s physical and mindful friction.",
            unlockType: .squats,
            requiredSquatReps: 10,
            temporaryUnlockMinutes: 10,
            isStrictAntiTamperEnabled: false,
            schedules: [
                ScheduleModel(
                    title: "Focus Hours",
                    startHour: 9,
                    startMinute: 0,
                    endHour: 18,
                    endMinute: 0,
                    daysOfWeekBitmask: 0b0111110, // Mon-Fri
                    isEnabled: true
                )
            ]
        )
        self.activeProfile = defaultProfile
        
        loadAllData()
    }
    
    public func loadAllData() {
        guard let defaults = defaults else { return }
        
        self.hasCompletedOnboarding = defaults.bool(forKey: AppStorageKeys.hasCompletedOnboarding)
        
        // Load active profile
        if let data = defaults.data(forKey: AppStorageKeys.activeProfile),
           let profile = try? JSONDecoder().decode(PolicyProfile.self, from: data) {
            self.activeProfile = profile
        }
        
        // Load saved profiles
        if let data = defaults.data(forKey: AppStorageKeys.savedProfiles),
           let profiles = try? JSONDecoder().decode([PolicyProfile].self, from: data) {
            self.savedProfiles = profiles
        } else {
            self.savedProfiles = [self.activeProfile]
        }
        
        // Load geofences
        if let data = defaults.data(forKey: AppStorageKeys.geofences),
           let zones = try? JSONDecoder().decode([GeofenceZone].self, from: data) {
            self.geofences = zones
        } else {
            // Default sample geofences
            self.geofences = [
                GeofenceZone(
                    name: "Office HQ",
                    latitude: 37.7749,
                    longitude: -122.4194,
                    radiusMeters: 150.0,
                    preset: .office,
                    assignedProfileType: .corporate
                ),
                GeofenceZone(
                    name: "Central Library",
                    latitude: 37.7790,
                    longitude: -122.4180,
                    radiusMeters: 100.0,
                    preset: .library,
                    assignedProfileType: .deepWork
                )
            ]
        }
        
        // Load metrics
        self.totalSquatReps = defaults.integer(forKey: AppStorageKeys.totalSquatReps)
        self.totalBreathingSessions = defaults.integer(forKey: AppStorageKeys.totalBreathingSessions)
        self.blockAttemptsCount = defaults.integer(forKey: AppStorageKeys.blockAttemptsCount)
        self.dailyUnlockCount = defaults.integer(forKey: AppStorageKeys.dailyUnlockCount)
        self.isShieldEnforced = defaults.bool(forKey: AppStorageKeys.isShieldEnforced)
        self.isAntiTamperEnabled = defaults.object(forKey: AppStorageKeys.antiTamperEnabled) as? Bool ?? true
    }
    
    private func saveActiveProfile() {
        guard let defaults = defaults else { return }
        if let data = try? JSONEncoder().encode(activeProfile) {
            defaults.set(data, forKey: AppStorageKeys.activeProfile)
        }
    }
    
    private func saveProfilesList() {
        guard let defaults = defaults else { return }
        if let data = try? JSONEncoder().encode(savedProfiles) {
            defaults.set(data, forKey: AppStorageKeys.savedProfiles)
        }
    }
    
    private func saveGeofences() {
        guard let defaults = defaults else { return }
        if let data = try? JSONEncoder().encode(geofences) {
            defaults.set(data, forKey: AppStorageKeys.geofences)
        }
    }
    
    public func recordSquatRepsCompleted(_ count: Int) {
        totalSquatReps += count
        defaults?.set(totalSquatReps, forKey: AppStorageKeys.totalSquatReps)
    }
    
    public func recordBreathingSessionCompleted() {
        totalBreathingSessions += 1
        defaults?.set(totalBreathingSessions, forKey: AppStorageKeys.totalBreathingSessions)
    }
    
    public func recordBlockAttempt() {
        blockAttemptsCount += 1
        defaults?.set(blockAttemptsCount, forKey: AppStorageKeys.blockAttemptsCount)
    }
    
    public func recordUnlockGranted(durationMinutes: Int) {
        dailyUnlockCount += 1
        defaults?.set(dailyUnlockCount, forKey: AppStorageKeys.dailyUnlockCount)
        
        let expiry = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        defaults?.set(expiry.timeIntervalSince1970, forKey: AppStorageKeys.temporaryUnlockExpiry)
        defaults?.set(durationMinutes, forKey: AppStorageKeys.temporaryUnlockGrantedMinutes)
    }
    
    public func isTemporaryUnlockActive() -> Bool {
        guard let defaults = defaults else { return false }
        let expiryTimestamp = defaults.double(forKey: AppStorageKeys.temporaryUnlockExpiry)
        guard expiryTimestamp > 0 else { return false }
        return Date().timeIntervalSince1970 < expiryTimestamp
    }
    
    public func remainingUnlockSeconds() -> Int {
        guard let defaults = defaults else { return 0 }
        let expiryTimestamp = defaults.double(forKey: AppStorageKeys.temporaryUnlockExpiry)
        let diff = expiryTimestamp - Date().timeIntervalSince1970
        return max(0, Int(diff))
    }
    
    public func revokeTemporaryUnlock() {
        defaults?.removeObject(forKey: AppStorageKeys.temporaryUnlockExpiry)
        defaults?.removeObject(forKey: AppStorageKeys.temporaryUnlockGrantedMinutes)
    }
    
    public func setShieldEnforced(_ enforced: Bool) {
        self.isShieldEnforced = enforced
        defaults?.set(enforced, forKey: AppStorageKeys.isShieldEnforced)
    }
    
    public func setAntiTamperEnabled(_ enabled: Bool) {
        self.isAntiTamperEnabled = enabled
        defaults?.set(enabled, forKey: AppStorageKeys.antiTamperEnabled)
    }
    
    public func completeOnboarding() {
        self.hasCompletedOnboarding = true
        defaults?.set(true, forKey: AppStorageKeys.hasCompletedOnboarding)
    }
    
    public func resetOnboarding() {
        self.hasCompletedOnboarding = false
        defaults?.set(false, forKey: AppStorageKeys.hasCompletedOnboarding)
    }
}
