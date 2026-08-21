import Foundation
import SwiftUI

/// Profile preset types matching enterprise and wellbeing personas
public enum ProfileType: String, Codable, CaseIterable, Identifiable, Sendable {
    case corporate = "OFFICE_MODE"
    case family = "FAMILY_MODE"
    case deepWork = "DEEP_WORK"
    case custom = "CUSTOM"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .corporate: return "Corporate / Office"
        case .family: return "Family & Parenting"
        case .deepWork: return "Deep Work Focus"
        case .custom: return "Custom Policy"
        }
    }
    
    public var iconName: String {
        switch self {
        case .corporate: return "building.2.fill"
        case .family: return "person.2.fill"
        case .deepWork: return "brain.head.profile"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .corporate: return "Strict office hours, social block, communication whitelist"
        case .family: return "School hours, study lock, physical exercise to earn screen time"
        case .deepWork: return "Pomodoro focus blocks with physical & cognitive micro-resets"
        case .custom: return "User-defined schedule, geofences, and shield thresholds"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .corporate: return DisciplineTheme.primary
        case .family: return DisciplineTheme.accent
        case .deepWork: return DisciplineTheme.success
        case .custom: return DisciplineTheme.warning
        }
    }
}

/// Extended Physical & Cognitive Friction Unlock Requirements
public enum FrictionUnlockType: String, Codable, CaseIterable, Identifiable, Sendable {
    // Physical Friction (Vision AI)
    case squats = "SQUATS"
    case wallSit = "WALL_SIT"
    case pushups = "PUSHUPS"
    case plank = "PLANK"
    case boxBreathing = "BOX_BREATHING"
    
    // Cognitive Friction (Dopamine-Diverting Puzzles)
    case stroopChallenge = "STROOP_CHALLENGE"
    case memoryMatrix = "MEMORY_MATRIX"
    case mentalMath = "MENTAL_MATH"
    case intentionalPrompt = "INTENTIONAL_PROMPT"
    
    // Administrative Locks
    case parentPinOnly = "PARENT_PIN_ONLY"
    case noUnlockAllowed = "STRICT_LOCKOUT"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .squats: return "Squats Physical Reset"
        case .wallSit: return "30s Wall Sit Hold"
        case .pushups: return "Pushups Physical Reset"
        case .plank: return "45s Plank Core Hold"
        case .boxBreathing: return "30s Box Breathing"
        case .stroopChallenge: return "Stroop Focus Challenge"
        case .memoryMatrix: return "Memory Matrix Puzzle"
        case .mentalMath: return "Mental Math Sprint"
        case .intentionalPrompt: return "Intentionality Journal"
        case .parentPinOnly: return "Parent PIN Required"
        case .noUnlockAllowed: return "Strict Lockout (No Unlock)"
        }
    }
    
    public var iconName: String {
        switch self {
        case .squats: return "figure.cross.training"
        case .wallSit: return "figure.strengthtraining.traditional"
        case .pushups: return "figure.core.training"
        case .plank: return "figure.play"
        case .boxBreathing: return "wind"
        case .stroopChallenge: return "paintpalette.fill"
        case .memoryMatrix: return "square.grid.3x3.fill"
        case .mentalMath: return "number.square.fill"
        case .intentionalPrompt: return "square.and.pencil"
        case .parentPinOnly: return "lock.shield.fill"
        case .noUnlockAllowed: return "xmark.octagon.fill"
        }
    }
    
    public var categoryName: String {
        switch self {
        case .squats, .wallSit, .pushups, .plank:
            return "PHYSICAL FRICTION"
        case .boxBreathing:
            return "MINDFUL PAUSE"
        case .stroopChallenge, .memoryMatrix, .mentalMath, .intentionalPrompt:
            return "COGNITIVE PUZZLE"
        case .parentPinOnly, .noUnlockAllowed:
            return "ADMINISTRATIVE"
        }
    }
    
    public var isCameraAIRequired: Bool {
        switch self {
        case .squats, .wallSit, .pushups, .plank, .boxBreathing:
            return true
        default:
            return false
        }
    }
}

/// Complete policy model encapsulating schedules, friction rules, and shielding flags
public struct PolicyProfile: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var type: ProfileType
    public var name: String
    public var description: String
    public var unlockType: FrictionUnlockType
    public var requiredSquatReps: Int
    public var temporaryUnlockMinutes: Int
    public var isStrictAntiTamperEnabled: Bool
    public var schedules: [ScheduleModel]
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        type: ProfileType,
        name: String,
        description: String,
        unlockType: FrictionUnlockType = .squats,
        requiredSquatReps: Int = 10,
        temporaryUnlockMinutes: Int = 15,
        isStrictAntiTamperEnabled: Bool = true,
        schedules: [ScheduleModel] = [],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.description = description
        self.unlockType = unlockType
        self.requiredSquatReps = requiredSquatReps
        self.temporaryUnlockMinutes = temporaryUnlockMinutes
        self.isStrictAntiTamperEnabled = isStrictAntiTamperEnabled
        self.schedules = schedules
        self.updatedAt = updatedAt
    }
}

/// Configurable schedule item supporting active days bitmask and overnight spans
public struct ScheduleModel: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var startHour: Int
    public var startMinute: Int
    public var endHour: Int
    public var endMinute: Int
    public var daysOfWeekBitmask: Int // 1=Sun, 2=Mon, 4=Tue, 8=Wed, 16=Thu, 32=Fri, 64=Sat
    public var isEnabled: Bool
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        daysOfWeekBitmask: Int = 0b0111110, // Mon-Fri
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.daysOfWeekBitmask = daysOfWeekBitmask
        self.isEnabled = isEnabled
    }
    
    public var isOvernight: Bool {
        if startHour > endHour {
            return true
        }
        if startHour == endHour && startMinute > endMinute {
            return true
        }
        return false
    }
    
    public var formattedTimeSpan: String {
        let start = TimeFormatter.formatTime(hour: startHour, minute: startMinute)
        let end = TimeFormatter.formatTime(hour: endHour, minute: endMinute)
        return "\(start) → \(end)"
    }
    
    public var formattedDays: String {
        return TimeFormatter.formatDaysOfWeek(bitmask: daysOfWeekBitmask)
    }
}
