import Foundation
import Combine

/// Dynamic Escalation Engine that increases friction level based on recent attempt frequency
@MainActor
public final class DynamicEscalationEngine: ObservableObject {
    public static let shared = DynamicEscalationEngine()
    
    @Published public var consecutiveAttemptCount: Int = 0
    @Published public var lastAttemptDate: Date?
    
    private let windowMinutes: Double = 30.0
    private let attemptsKey = "digitaldiscipline.escalation.attempts"
    private let lastDateKey = "digitaldiscipline.escalation.last_date"
    private let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName)
    
    private init() {
        loadState()
    }
    
    private func loadState() {
        self.consecutiveAttemptCount = defaults?.integer(forKey: attemptsKey) ?? 0
        if let timestamp = defaults?.double(forKey: lastDateKey), timestamp > 0 {
            self.lastAttemptDate = Date(timeIntervalSince1970: timestamp)
        }
    }
    
    /// Records a distraction attempt and returns the escalated intervention
    public func recordDistractionAttemptAndGetIntervention() -> InterventionType {
        let now = Date()
        
        if let last = lastAttemptDate, now.timeIntervalSince(last) > (windowMinutes * 60) {
            // Window reset
            consecutiveAttemptCount = 1
        } else {
            consecutiveAttemptCount += 1
        }
        
        lastAttemptDate = now
        defaults?.set(consecutiveAttemptCount, forKey: attemptsKey)
        defaults?.set(now.timeIntervalSince1970, forKey: lastDateKey)
        
        return currentEscalationIntervention
    }
    
    /// Determines the active intervention based on escalation tier
    public var currentEscalationIntervention: InterventionType {
        switch consecutiveAttemptCount {
        case 0, 1:
            // Level 1: Mindful Pause & Breathing
            return .boxBreathing
        case 2:
            // Level 2: Physical Movement & Calisthenics
            return .squats
        default:
            // Level 3+: Cognitive Executive Control
            return .stroopTest
        }
    }
    
    public var currentEscalationLevelName: String {
        switch consecutiveAttemptCount {
        case 0, 1:
            return "Level 1: Mindful Pause"
        case 2:
            return "Level 2: Physical Calisthenics"
        default:
            return "Level 3: Cognitive Executive Control"
        }
    }
    
    public func resetEscalation() {
        consecutiveAttemptCount = 0
        lastAttemptDate = nil
        defaults?.removeObject(forKey: attemptsKey)
        defaults?.removeObject(forKey: lastDateKey)
    }
}
