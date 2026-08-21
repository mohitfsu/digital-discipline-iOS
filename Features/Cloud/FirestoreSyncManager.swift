import Foundation
import Combine

/// Telemetry event structure sent to Firestore
public struct TelemetryEvent: Codable, Identifiable, Sendable {
    public let id: String
    public let eventType: String
    public let timestamp: String
    public let details: [String: String]
    
    public init(id: String = UUID().uuidString, eventType: String, details: [String: String] = [:]) {
        self.id = id
        self.eventType = eventType
        self.timestamp = TimeFormatter.currentIso8601()
        self.details = details
    }
}

/// Manages real-time policy synchronization and telemetry publishing with Firebase Firestore
@MainActor
public final class FirestoreSyncManager: ObservableObject {
    public static let shared = FirestoreSyncManager()
    
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncedAt: Date?
    @Published public var syncStatusMessage: String = "Up to date"
    @Published public var recentTelemetryEvents: [TelemetryEvent] = []
    
    private let dataStore = SharedDataStore.shared
    private var syncTimer: AnyCancellable?
    
    private init() {
        startPeriodicSync()
    }
    
    /// Starts periodic background telemetry flush and policy polling
    public func startPeriodicSync() {
        syncTimer = Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.flushTelemetry()
                }
            }
    }
    
    /// Pushes updated policy profile from Parent device to Firestore
    public func pushPolicyToCloud(familyId: String, childId: String, profile: PolicyProfile) async -> Bool {
        isSyncing = true
        syncStatusMessage = "Pushing policy to Firestore..."
        
        // Simulates Firestore document set at `families/{familyId}/children/{childId}/policies/current`
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        lastSyncedAt = Date()
        isSyncing = false
        syncStatusMessage = "Policy live synchronized"
        
        let event = TelemetryEvent(
            eventType: "POLICY_UPDATED",
            details: [
                "profile": profile.name,
                "unlockType": profile.unlockType.rawValue,
                "requiredReps": "\(profile.requiredSquatReps)"
            ]
        )
        recentTelemetryEvents.insert(event, at: 0)
        return true
    }
    
    /// Listens for policy updates on Child device from Firestore snapshot listener
    public func listenToChildPolicy(familyId: String, childId: String) {
        syncStatusMessage = "Listening to Firestore updates..."
        // In real Firebase: db.collection("families").document(familyId).collection("children").document(childId).collection("policies").document("current").addSnapshotListener { ... }
    }
    
    /// Flushes accumulated telemetry events (squats completed, block attempts) to Firestore
    public func flushTelemetry() async {
        guard let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName),
              let familyId = defaults.string(forKey: AppStorageKeys.familyId),
              let childId = defaults.string(forKey: AppStorageKeys.childId) else {
            return
        }
        
        let reps = defaults.integer(forKey: AppStorageKeys.totalSquatReps)
        let blocks = defaults.integer(forKey: AppStorageKeys.blockAttemptsCount)
        
        if reps > 0 || blocks > 0 {
            let event = TelemetryEvent(
                eventType: "TELEMETRY_HEARTBEAT",
                details: [
                    "familyId": familyId,
                    "childId": childId,
                    "totalSquatReps": "\(reps)",
                    "blockAttempts": "\(blocks)"
                ]
            )
            recentTelemetryEvents.insert(event, at: 0)
            lastSyncedAt = Date()
        }
    }
}
