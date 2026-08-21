import Foundation
import CoreGraphics
import Combine

/// Calf Raises ankle plantar-flexion movement classifier
@MainActor
public final class CalfRaisesClassifier: ObservableObject {
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 15
    @Published public var formGuidance: String = "Rise onto the balls of your feet and lower slowly"
    @Published public var isWorkoutComplete: Bool = false
    
    private var baselineAnkleY: CGFloat?
    private var isAtTop = false
    private var lastRepTimestamp: TimeInterval = 0
    
    public init(targetReps: Int = 15) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let t = targetReps { self.targetReps = t }
        self.repCount = 0
        self.baselineAnkleY = nil
        self.isAtTop = false
        self.isWorkoutComplete = false
        self.formGuidance = "Rise up on your toes"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        guard let leftAnkle = frame.leftAnkle, let rightAnkle = frame.rightAnkle else {
            formGuidance = "Keep your feet and ankles in view."
            return
        }
        
        let currentAnkleY = (leftAnkle.y + rightAnkle.y) / 2.0
        
        if baselineAnkleY == nil {
            baselineAnkleY = currentAnkleY
            return
        }
        
        guard let base = baselineAnkleY else { return }
        
        // Raising onto balls of feet decreases Y (moves higher in screen)
        if currentAnkleY < (base - 0.03) {
            if !isAtTop {
                isAtTop = true
                HapticFeedbackManager.shared.bottomSquatReached()
            }
        } else if currentAnkleY >= (base - 0.01) {
            if isAtTop && (frame.timestamp - lastRepTimestamp) > 0.4 {
                repCount += 1
                lastRepTimestamp = frame.timestamp
                isAtTop = false
                
                HapticFeedbackManager.shared.repCompleted()
                formGuidance = "Calf Raise \(repCount)/\(targetReps) complete!"
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    formGuidance = "Calf Raises Completed!"
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                }
            }
        }
    }
}
