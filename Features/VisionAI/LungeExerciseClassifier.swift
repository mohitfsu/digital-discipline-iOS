import Foundation
import CoreGraphics
import Combine

public enum LungePhase: String, Sendable {
    case notDetected = "Position camera at side view"
    case standing = "Standing Ready"
    case lungingDown = "Stepping Into Lunge..."
    case bottomLunge = "Good 90° Depth! Hold"
    case pushingBack = "Pushing Back Up..."
}

/// Biomechanical Alternating Lunge Classifier
@MainActor
public final class LungeExerciseClassifier: ObservableObject {
    @Published public var currentPhase: LungePhase = .notDetected
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 10
    @Published public var currentKneeAngle: Double = 180.0
    @Published public var formGuidance: String = "Step forward and drop rear knee toward the floor"
    @Published public var isWorkoutComplete: Bool = false
    
    private var hasReachedBottom = false
    private var lastRepTimestamp: TimeInterval = 0
    private let minRepInterval: TimeInterval = 0.6
    
    public init(targetReps: Int = 10) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let t = targetReps { self.targetReps = t }
        self.repCount = 0
        self.currentPhase = .notDetected
        self.currentKneeAngle = 180.0
        self.hasReachedBottom = false
        self.isWorkoutComplete = false
        self.formGuidance = "Step into frame for alternating lunges"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        var angle: Double?
        if let hip = frame.leftHip, let knee = frame.leftKnee, let ankle = frame.leftAnkle {
            angle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        } else if let hip = frame.rightHip, let knee = frame.rightKnee, let ankle = frame.rightAnkle {
            angle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        }
        
        guard let frontAngle = angle else {
            currentPhase = .notDetected
            formGuidance = "Ensure legs and hips are clearly visible."
            return
        }
        
        self.currentKneeAngle = frontAngle
        
        if frontAngle > 155.0 {
            if hasReachedBottom && (frame.timestamp - lastRepTimestamp) > minRepInterval {
                repCount += 1
                lastRepTimestamp = frame.timestamp
                hasReachedBottom = false
                
                HapticFeedbackManager.shared.repCompleted()
                formGuidance = "Lunge \(repCount)/\(targetReps) complete! Switch legs."
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    currentPhase = .standing
                    formGuidance = "Alternating Lunges completed!"
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                    return
                }
            }
            currentPhase = .standing
        } else if frontAngle < 100.0 {
            if !hasReachedBottom {
                hasReachedBottom = true
                HapticFeedbackManager.shared.bottomSquatReached()
                formGuidance = "Great 90° depth! Push back to start."
            }
            currentPhase = .bottomLunge
        } else {
            if hasReachedBottom {
                currentPhase = .pushingBack
            } else {
                currentPhase = .lungingDown
            }
        }
    }
}
