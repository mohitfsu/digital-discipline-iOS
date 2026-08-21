import Foundation
import CoreGraphics
import Combine

public enum PushupPhase: String, Sendable {
    case notDetected = "Place camera on floor looking at side"
    case topPlank = "Plank Ready - Lockout (>155°)"
    case descending = "Lowering Chest..."
    case bottomDepth = "Good Chest Depth! (<95°)"
    case pushingUp = "Pushing Up..."
}

/// Real-time Pushup exercise classifier measuring elbow flexion and plank depth
@MainActor
public final class PushupExerciseClassifier: ObservableObject {
    @Published public var currentPhase: PushupPhase = .notDetected
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 10
    @Published public var currentElbowAngle: Double = 180.0
    @Published public var formGuidance: String = "Set phone on floor at 45° angle to capture full side profile"
    @Published public var isWorkoutComplete: Bool = false
    
    private var hasReachedBottom = false
    private var lastRepTimestamp: TimeInterval = 0
    private let minRepInterval: TimeInterval = 0.5
    
    public init(targetReps: Int = 10) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let target = targetReps {
            self.targetReps = target
        }
        self.repCount = 0
        self.currentPhase = .notDetected
        self.currentElbowAngle = 180.0
        self.hasReachedBottom = false
        self.isWorkoutComplete = false
        self.formGuidance = "Align camera for pushup side profile"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        var elbowAngle: Double?
        if let shoulder = frame.leftShoulder, let elbow = frame.leftElbow, let wrist = frame.leftWrist {
            elbowAngle = AngleCalculator.angleDegrees(pointA: shoulder, vertexB: elbow, pointC: wrist)
        } else if let shoulder = frame.rightShoulder, let elbow = frame.rightElbow, let wrist = frame.rightWrist {
            elbowAngle = AngleCalculator.angleDegrees(pointA: shoulder, vertexB: elbow, pointC: wrist)
        }
        
        guard let angle = elbowAngle else {
            currentPhase = .notDetected
            formGuidance = "Shoulder, elbow, or wrist not detected. Step into frame."
            return
        }
        
        self.currentElbowAngle = angle
        advanceStateMachine(angle: angle, timestamp: frame.timestamp)
    }
    
    private func advanceStateMachine(angle: Double, timestamp: TimeInterval) {
        if angle > 155.0 {
            // Full lockout
            if hasReachedBottom && (timestamp - lastRepTimestamp) > minRepInterval {
                repCount += 1
                lastRepTimestamp = timestamp
                hasReachedBottom = false
                
                HapticFeedbackManager.shared.repCompleted()
                formGuidance = "Pushup \(repCount) complete! Keep going."
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    currentPhase = .topPlank
                    formGuidance = "Target pushup reps achieved!"
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                    return
                }
            }
            currentPhase = .topPlank
        } else if angle < 95.0 {
            // Bottom chest depth
            if !hasReachedBottom {
                hasReachedBottom = true
                HapticFeedbackManager.shared.bottomSquatReached()
                formGuidance = "Chest to deck achieved! Push back up."
            }
            currentPhase = .bottomDepth
        } else {
            if hasReachedBottom {
                currentPhase = .pushingUp
                formGuidance = "Push up to full plank lockout"
            } else {
                currentPhase = .descending
                formGuidance = "Lower chest below 95° elbow angle"
            }
        }
    }
}
