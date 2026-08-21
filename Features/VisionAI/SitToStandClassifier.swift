import Foundation
import CoreGraphics
import Combine

/// Desk & Chair Sit-to-Stand functional movement classifier
@MainActor
public final class SitToStandClassifier: ObservableObject {
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 10
    @Published public var formGuidance: String = "Sit on chair, stand up fully, then sit back down"
    @Published public var isWorkoutComplete: Bool = false
    
    private var isSeated = false
    private var lastRepTimestamp: TimeInterval = 0
    
    public init(targetReps: Int = 10) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let t = targetReps { self.targetReps = t }
        self.repCount = 0
        self.isSeated = false
        self.isWorkoutComplete = false
        self.formGuidance = "Sit and stand 10 times"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        var kneeAngle: Double?
        if let hip = frame.leftHip, let knee = frame.leftKnee, let ankle = frame.leftAnkle {
            kneeAngle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        } else if let hip = frame.rightHip, let knee = frame.rightKnee, let ankle = frame.rightAnkle {
            kneeAngle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        }
        
        guard let angle = kneeAngle else {
            formGuidance = "Keep your legs and chair in camera frame."
            return
        }
        
        if angle < 105.0 {
            // Seated on chair
            if !isSeated {
                isSeated = true
                HapticFeedbackManager.shared.bottomSquatReached()
                formGuidance = "Now stand up to full extension"
            }
        } else if angle > 165.0 {
            // Standing upright
            if isSeated && (frame.timestamp - lastRepTimestamp) > 0.5 {
                repCount += 1
                lastRepTimestamp = frame.timestamp
                isSeated = false
                
                HapticFeedbackManager.shared.repCompleted()
                formGuidance = "Rep \(repCount)/\(targetReps) complete! Sit back down."
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    formGuidance = "Sit-to-Stand Completed!"
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                }
            }
        }
    }
}
