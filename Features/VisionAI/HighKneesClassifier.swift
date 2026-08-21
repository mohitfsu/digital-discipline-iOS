import Foundation
import CoreGraphics
import Combine

/// Rapid High Knees cardio classifier tracking knee elevation
@MainActor
public final class HighKneesClassifier: ObservableObject {
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 20
    @Published public var formGuidance: String = "Drive knees up to hip height alternating legs"
    @Published public var isWorkoutComplete: Bool = false
    
    private var isLeftKneeUp = false
    private var isRightKneeUp = false
    private var lastRepTimestamp: TimeInterval = 0
    
    public init(targetReps: Int = 20) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let t = targetReps { self.targetReps = t }
        self.repCount = 0
        self.isLeftKneeUp = false
        self.isRightKneeUp = false
        self.isWorkoutComplete = false
        self.formGuidance = "Drive knees high alternating fast"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        guard let leftHip = frame.leftHip,
              let rightHip = frame.rightHip,
              let leftKnee = frame.leftKnee,
              let rightKnee = frame.rightKnee else {
            formGuidance = "Ensure your hips and knees are in view."
            return
        }
        
        let hipAvgY = (leftHip.y + rightHip.y) / 2.0
        
        // High knee threshold: Knee Y close to or above hip Y
        if leftKnee.y <= (hipAvgY + 0.08) {
            if !isLeftKneeUp && (frame.timestamp - lastRepTimestamp) > 0.25 {
                isLeftKneeUp = true
                repCount += 1
                lastRepTimestamp = frame.timestamp
                HapticFeedbackManager.shared.repCompleted()
            }
        } else {
            isLeftKneeUp = false
        }
        
        if rightKnee.y <= (hipAvgY + 0.08) {
            if !isRightKneeUp && (frame.timestamp - lastRepTimestamp) > 0.25 {
                isRightKneeUp = true
                repCount += 1
                lastRepTimestamp = frame.timestamp
                HapticFeedbackManager.shared.repCompleted()
            }
        } else {
            isRightKneeUp = false
        }
        
        formGuidance = "\(repCount)/\(targetReps) High Knees! Keep the tempo."
        
        if repCount >= targetReps {
            isWorkoutComplete = true
            formGuidance = "High Knees Target Achieved!"
            HapticFeedbackManager.shared.workoutCompleted()
            SharedDataStore.shared.recordSquatRepsCompleted(repCount)
        }
    }
}
