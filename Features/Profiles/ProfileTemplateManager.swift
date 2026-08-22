import Foundation
import SwiftUI

/// Preset factory and switcher for Digital Discipline policy profiles
@MainActor
public final class ProfileTemplateManager: ObservableObject {
    public static let shared = ProfileTemplateManager()
    
    private let dataStore = SharedDataStore.shared
    
    private init() {}
    
    /// Predefined Self-Discipline Profile
    public static var selfDisciplineTemplate: PolicyProfile {
        PolicyProfile(
            type: .selfDiscipline,
            name: "🧘 Self-Discipline Habit Reset",
            description: "Breaks compulsive dopamine doomscrolling loops with 30s physical, mindful, and cognitive friction.",
            unlockType: .squats,
            requiredSquatReps: 10,
            temporaryUnlockMinutes: 5,
            isStrictAntiTamperEnabled: false,
            schedules: [
                ScheduleModel(
                    title: "Active Hours",
                    startHour: 9,
                    startMinute: 0,
                    endHour: 22,
                    endMinute: 0,
                    daysOfWeekBitmask: 0b1111111 // Every day
                )
            ]
        )
    }
    
    /// Predefined Corporate / Office Profile
    public static var corporateTemplate: PolicyProfile {
        PolicyProfile(
            type: .corporate,
            name: "🏢 Office HQ Focus",
            description: "Enforces strict working hours (9:00 AM – 5:00 PM, Mon-Fri). Social and entertainment apps are shielded.",
            unlockType: .squats,
            requiredSquatReps: 10,
            temporaryUnlockMinutes: 10,
            isStrictAntiTamperEnabled: true,
            schedules: [
                ScheduleModel(
                    title: "Business Hours",
                    startHour: 9,
                    startMinute: 0,
                    endHour: 17,
                    endMinute: 0,
                    daysOfWeekBitmask: 0b0111110 // Mon-Fri
                )
            ]
        )
    }
    
    /// Predefined Family & Parenting Profile
    public static var familyTemplate: PolicyProfile {
        PolicyProfile(
            type: .family,
            name: "👨‍👩‍👧 Family & Study Discipline",
            description: "Restricts gaming during school & study hours. Requires 30s breathing or physical exercise to earn screen time.",
            unlockType: .squats,
            requiredSquatReps: 15,
            temporaryUnlockMinutes: 15,
            isStrictAntiTamperEnabled: true,
            schedules: [
                ScheduleModel(
                    title: "School Hours",
                    startHour: 8,
                    startMinute: 0,
                    endHour: 14,
                    endMinute: 0,
                    daysOfWeekBitmask: 0b0111110
                ),
                ScheduleModel(
                    title: "Evening Study Session",
                    startHour: 17,
                    startMinute: 0,
                    endHour: 20,
                    endMinute: 30,
                    daysOfWeekBitmask: 0b0111110
                ),
                ScheduleModel(
                    title: "Nighttime Bedtime Lock",
                    startHour: 22,
                    startMinute: 0,
                    endHour: 6,
                    endMinute: 0,
                    daysOfWeekBitmask: 0b1111111 // Every day overnight
                )
            ]
        )
    }
    
    /// Predefined Deep Work / Pomodoro Profile
    public static var deepWorkTemplate: PolicyProfile {
        PolicyProfile(
            type: .deepWork,
            name: "🎯 Deep Work Flow",
            description: "High-intensity cognitive focus blocks. Eliminates phone distraction with 5-rep posture resets.",
            unlockType: .boxBreathing,
            requiredSquatReps: 5,
            temporaryUnlockMinutes: 5,
            isStrictAntiTamperEnabled: false,
            schedules: [
                ScheduleModel(
                    title: "Morning Focus Block",
                    startHour: 9,
                    startMinute: 0,
                    endHour: 12,
                    endMinute: 30,
                    daysOfWeekBitmask: 0b0111110
                ),
                ScheduleModel(
                    title: "Afternoon Focus Block",
                    startHour: 14,
                    startMinute: 30,
                    endHour: 17,
                    endMinute: 30,
                    daysOfWeekBitmask: 0b0111110
                )
            ]
        )
    }
    
    /// Applies a chosen profile preset atomically across the app and App Group
    public func applyProfile(_ profile: PolicyProfile) {
        dataStore.activeProfile = profile
        dataStore.setAntiTamperEnabled(profile.isStrictAntiTamperEnabled)
        HapticFeedbackManager.shared.profileSwitched()
    }
    
    public func applyPresetType(_ type: ProfileType) {
        switch type {
        case .selfDiscipline:
            applyProfile(Self.selfDisciplineTemplate)
        case .corporate:
            applyProfile(Self.corporateTemplate)
        case .family:
            applyProfile(Self.familyTemplate)
        case .deepWork:
            applyProfile(Self.deepWorkTemplate)
        case .custom:
            var custom = dataStore.activeProfile
            custom.type = .custom
            applyProfile(custom)
        }
    }
}
