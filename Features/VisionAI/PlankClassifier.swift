import Foundation
import CoreGraphics
import Combine

public enum PlankState: String, Sendable {
    case notDetected = "Place camera to capture full body side profile"
    case hipsSagging = "Lift hips! Straighten lower back"
    case hipsPiked = "Lower hips! Maintain flat spine"
    case perfectPlank = "Perfect Flat Plank! Core Engaged"
    case completed = "Plank Hold Completed!"
}

/// Real-time isometric Plank core hold classifier with spine alignment verification
@MainActor
public final class PlankClassifier: ObservableObject {
    @Published public var state: PlankState = .notDetected
    @Published public var spineAngle: Double = 180.0
    @Published public var secondsRemaining: Int = 45
    @Published public var targetDurationSeconds: Int = 45
    @Published public var isHoldActive: Bool = false
    @Published public var isCompleted: Bool = false
    @Published public var formGuidance: String = "Hold a flat forearm or high plank with core braced"
    
    private var timer: AnyCancellable?
    private var isHoldingValidPlank = false
    
    public init(targetDurationSeconds: Int = 45) {
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
        self.isHoldingValidPlank = false
        self.formGuidance = "Align plank from head to heels"
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
        
        if isHoldingValidPlank {
            secondsRemaining = max(0, secondsRemaining - 1)
            isHoldActive = true
            
            if secondsRemaining % 5 == 0 && secondsRemaining > 0 {
                HapticFeedbackManager.shared.bottomSquatReached()
            }
            
            if secondsRemaining == 0 {
                completePlank()
            }
        } else {
            isHoldActive = false
        }
    }
    
    private func completePlank() {
        isCompleted = true
        state = .completed
        formGuidance = "Core stability verified! Screen time granted."
        HapticFeedbackManager.shared.workoutCompleted()
        SharedDataStore.shared.recordBreathingSessionCompleted()
    }
    
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isCompleted else { return }
        
        var angle: Double?
        if let shoulder = frame.leftShoulder, let hip = frame.leftHip, let ankle = frame.leftAnkle {
            angle = AngleCalculator.angleDegrees(pointA: shoulder, vertexB: hip, pointC: ankle)
        } else if let shoulder = frame.rightShoulder, let hip = frame.rightHip, let ankle = frame.rightAnkle {
            angle = AngleCalculator.angleDegrees(pointA: shoulder, vertexB: hip, pointC: ankle)
        }
        
        guard let computedSpineAngle = angle else {
            state = .notDetected
            isHoldingValidPlank = false
            formGuidance = "Ensure your shoulder, hip, and ankles are in frame."
            return
        }
        
        self.spineAngle = computedSpineAngle
        
        if computedSpineAngle >= 160.0 && computedSpineAngle <= 195.0 {
            state = .perfectPlank
            isHoldingValidPlank = true
            formGuidance = "Brace core! Timer running: \(secondsRemaining)s remaining"
        } else if computedSpineAngle < 160.0 {
            state = .hipsPiked
            isHoldingValidPlank = false
            formGuidance = "Hips are too high (\(Int(computedSpineAngle))°). Flatten your back."
        } else {
            state = .hipsSagging
            isHoldingValidPlank = false
            formGuidance = "Hips are sagging. Squeeze glutes and lift abdomen."
        }
    }
}
