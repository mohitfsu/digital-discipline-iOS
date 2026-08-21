import Foundation
import CoreGraphics
import Combine

public enum WallSitState: String, Sendable {
    case notDetected = "Position camera at side view"
    case tooHigh = "Lower hips to 90°"
    case perfectHold = "Holding 90° Wall Sit! Stay Strong"
    case tooLow = "Raise hips slightly to 90°"
    case completed = "Wall Sit Completed!"
}

/// Real-time biomechanical Wall Sit isometric hold classifier with live countdown
@MainActor
public final class WallSitClassifier: ObservableObject {
    @Published public var state: WallSitState = .notDetected
    @Published public var currentKneeAngle: Double = 180.0
    @Published public var secondsRemaining: Int = 30
    @Published public var targetDurationSeconds: Int = 30
    @Published public var isHoldActive: Bool = false
    @Published public var isCompleted: Bool = false
    @Published public var formGuidance: String = "Lean back against a wall and slide down until thighs are parallel to the floor"
    
    private var timer: AnyCancellable?
    private var isHoldingProperAngle = false
    
    public init(targetDurationSeconds: Int = 30) {
        self.targetDurationSeconds = targetDurationSeconds
        self.secondsRemaining = targetDurationSeconds
        startTimer()
    }
    
    public func reset(targetDuration: Int? = nil) {
        if let duration = targetDuration {
            self.targetDurationSeconds = duration
        }
        self.secondsRemaining = self.targetDurationSeconds
        self.state = .notDetected
        self.isHoldActive = false
        self.isCompleted = false
        self.isHoldingProperAngle = false
        self.formGuidance = "Lean back against a wall at 90°"
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard !isCompleted else { return }
        
        if isHoldingProperAngle {
            secondsRemaining = max(0, secondsRemaining - 1)
            isHoldActive = true
            
            if secondsRemaining % 5 == 0 && secondsRemaining > 0 {
                HapticFeedbackManager.shared.bottomSquatReached()
            }
            
            if secondsRemaining == 0 {
                completeHold()
            }
        } else {
            isHoldActive = false
        }
    }
    
    private func completeHold() {
        isCompleted = true
        state = .completed
        formGuidance = "Isometric Wall Sit hold complete!"
        HapticFeedbackManager.shared.workoutCompleted()
        SharedDataStore.shared.recordSquatRepsCompleted(5) // Award metric points
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isCompleted else { return }
        
        var angle: Double?
        if let hip = frame.leftHip, let knee = frame.leftKnee, let ankle = frame.leftAnkle {
            angle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        } else if let hip = frame.rightHip, let knee = frame.rightKnee, let ankle = frame.rightAnkle {
            angle = AngleCalculator.angleDegrees(pointA: hip, vertexB: knee, pointC: ankle)
        }
        
        guard let kneeAngle = angle else {
            state = .notDetected
            isHoldingProperAngle = false
            formGuidance = "Ensure your hip, knee, and ankle are clearly visible."
            return
        }
        
        self.currentKneeAngle = kneeAngle
        
        if kneeAngle >= 75.0 && kneeAngle <= 105.0 {
            // Perfect 90° window
            state = .perfectHold
            isHoldingProperAngle = true
            formGuidance = "Hold this depth! Timer is ticking (\(secondsRemaining)s left)"
        } else if kneeAngle > 105.0 {
            state = .tooHigh
            isHoldingProperAngle = false
            formGuidance = "Too high (\(Int(kneeAngle))°). Slide down so thighs are flat at 90°"
        } else {
            state = .tooLow
            isHoldingProperAngle = false
            formGuidance = "Too deep (\(Int(kneeAngle))°). Push up slightly to 90°"
        }
    }
}
