import Foundation
import CoreGraphics
import Combine

/// Squat exercise state machine phases
public enum SquatPhase: String, Sendable {
    case notDetected = "Adjust Camera Position"
    case standing = "Ready - Standing Upright"
    case descending = "Squatting Down..."
    case bottomSquat = "Hold Depth! (<100°)"
    case ascending = "Pushing Up..."
}

/// Real-time biomechanical Squat classifier with joint angle calculation and state tracking
@MainActor
public final class SquatExerciseClassifier: ObservableObject {
    @Published public var currentPhase: SquatPhase = .notDetected
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 10
    @Published public var currentKneeAngle: Double = 180.0
    @Published public var formFeedback: String = "Position yourself in full view of the front camera"
    @Published public var isWorkoutComplete: Bool = false
    
    private var hasReachedBottom = false
    private var lastRepTimestamp: TimeInterval = 0
    private let minRepInterval: TimeInterval = 0.45 // 450ms debounce
    
    public init(targetReps: Int = 10) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let target = targetReps {
            self.targetReps = target
        }
        self.repCount = 0
        self.currentPhase = .notDetected
        self.currentKneeAngle = 180.0
        self.hasReachedBottom = false
        self.isWorkoutComplete = false
        self.formFeedback = "Position yourself in full view of the camera"
    }
    
    /// Classifies a pose frame and advances the squat state machine
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        var leftAngle: Double?
        if let hip = frame.leftHip, let knee = frame.leftKnee, let ankle = frame.leftAnkle {
            leftAngle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        }
        
        var rightAngle: Double?
        if let hip = frame.rightHip, let knee = frame.rightKnee, let ankle = frame.rightAnkle {
            rightAngle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        }
        
        // Use average of both legs or single visible leg
        let detectedAngle: Double
        if let left = leftAngle, let right = rightAngle {
            detectedAngle = (left + right) / 2.0
        } else if let left = leftAngle {
            detectedAngle = left
        } else if let right = rightAngle {
            detectedAngle = right
        } else {
            currentPhase = .notDetected
            formFeedback = "Legs not detected. Step back so hips, knees, and feet are visible."
            return
        }
        
        self.currentKneeAngle = detectedAngle
        advanceStateMachine(angle: detectedAngle, timestamp: frame.timestamp)
    }
    
    private func advanceStateMachine(angle: Double, timestamp: TimeInterval) {
        if angle > 160.0 {
            // Standing Upright
            if hasReachedBottom && (timestamp - lastRepTimestamp) > minRepInterval {
                // Completed full rep cycle!
                repCount += 1
                lastRepTimestamp = timestamp
                hasReachedBottom = false
                
                HapticFeedbackManager.shared.repCompleted()
                formFeedback = "Rep \(repCount) complete! Keep going."
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    currentPhase = .standing
                    formFeedback = "Target achieved! Physical reset completed."
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                    return
                }
            }
            currentPhase = .standing
        } else if angle < 100.0 {
            // Reached Bottom Squat Depth
            if !hasReachedBottom {
                hasReachedBottom = true
                HapticFeedbackManager.shared.bottomSquatReached()
                formFeedback = "Good depth! Now push straight up."
            }
            currentPhase = .bottomSquat
        } else {
            // Intermediate transition
            if hasReachedBottom {
                currentPhase = .ascending
                formFeedback = "Push up to standing position"
            } else {
                currentPhase = .descending
                formFeedback = "Lower your hips below 100°"
            }
        }
    }
}
