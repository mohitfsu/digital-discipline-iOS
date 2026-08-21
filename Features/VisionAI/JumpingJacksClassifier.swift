import Foundation
import CoreGraphics
import Combine

public enum JumpingJackState: String, Sendable {
    case notDetected = "Stand in full view of camera"
    case feetTogether = "Ready - Feet Together"
    case starPosition = "Star Spread! Arms High"
}

/// Jumping Jacks movement classifier using arm and leg spread tracking
@MainActor
public final class JumpingJacksClassifier: ObservableObject {
    @Published public var state: JumpingJackState = .notDetected
    @Published public var repCount: Int = 0
    @Published public var targetReps: Int = 15
    @Published public var formGuidance: String = "Perform 15 rhythmic jumping jacks"
    @Published public var isWorkoutComplete: Bool = false
    
    private var hasReachedStar = false
    private var lastRepTimestamp: TimeInterval = 0
    private let minRepInterval: TimeInterval = 0.4
    
    public init(targetReps: Int = 15) {
        self.targetReps = targetReps
    }
    
    public func reset(targetReps: Int? = nil) {
        if let t = targetReps { self.targetReps = t }
        self.repCount = 0
        self.state = .notDetected
        self.hasReachedStar = false
        self.isWorkoutComplete = false
        self.formGuidance = "Jump and spread arms overhead"
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isWorkoutComplete else { return }
        
        guard let leftWrist = frame.leftShoulder,
              let rightWrist = frame.rightShoulder,
              let leftAnkle = frame.leftAnkle,
              let rightAnkle = frame.rightAnkle,
              let leftHip = frame.leftHip,
              let rightHip = frame.rightHip else {
            state = .notDetected
            formGuidance = "Stand back so your entire body is visible."
            return
        }
        
        let ankleDistance = AngleCalculator.distance(from: leftAnkle, to: rightAnkle)
        let hipDistance = max(0.05, AngleCalculator.distance(from: leftHip, to: rightHip))
        let spreadRatio = ankleDistance / hipDistance
        
        // Star position when feet are spread wider than 1.4x hip width
        if spreadRatio > 1.4 {
            hasReachedStar = true
            state = .starPosition
            formGuidance = "Star reached! Jump feet back together."
        } else if spreadRatio < 1.1 {
            if hasReachedStar && (frame.timestamp - lastRepTimestamp) > minRepInterval {
                repCount += 1
                lastRepTimestamp = frame.timestamp
                hasReachedStar = false
                
                HapticFeedbackManager.shared.repCompleted()
                formGuidance = "Rep \(repCount)/\(targetReps) complete!"
                
                if repCount >= targetReps {
                    isWorkoutComplete = true
                    formGuidance = "Jumping Jacks Completed!"
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordSquatRepsCompleted(repCount)
                    return
                }
            }
            state = .feetTogether
        }
    }
}
