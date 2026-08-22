import Foundation
import Vision
import CoreGraphics
import Combine

/// Vision AI Classifier for Child's Pose (Balasana) with Strict Form & Instant Break Pause Protection
@MainActor
public final class StrictChildPoseClassifier: ObservableObject {
    @Published public var holdSeconds: Int = 0
    @Published public var targetHoldSeconds: Int = 30
    @Published public var feedbackMessage: String = "Align in camera view"
    @Published public var isHoldingValidPose: Bool = false
    @Published public var isCompleted: Bool = false
    
    private var lastHoldTimestamp: Date?
    private var accumulatedHoldMs: Double = 0
    
    public init(targetHoldSeconds: Int = 30) {
        self.targetHoldSeconds = targetHoldSeconds
    }
    
    /// Evaluates biomechanics from a detected BodyPoseFrame
    public func processFrame(_ frame: BodyPoseFrame) {
        guard !isCompleted else { return }
        
        guard let leftShoulder = frame.leftShoulder,
              let leftHip = frame.leftHip,
              let nose = frame.nose else {
            handlePoseLost()
            return
        }
        
        // Torso Fold Geometry: Shoulder Y is near or below Hip Y in Vision normalized coordinates
        let verticalSpineHeight = abs(leftHip.y - leftShoulder.y)
        let isTorsoFolded = verticalSpineHeight < 0.25 // Folded over thighs, not upright
        let isHeadDown = abs(leftShoulder.y - nose.y) < 0.18 // Forehead lowered to mat
        
        let isValidBalasana = isTorsoFolded && isHeadDown
        
        if isValidBalasana {
            let now = Date()
            if let last = lastHoldTimestamp {
                accumulatedHoldMs += now.timeIntervalSince(last)
            }
            lastHoldTimestamp = now
            isHoldingValidPose = true
            holdSeconds = Int(accumulatedHoldMs)
            feedbackMessage = "🟢 Holding Child's Pose! (\(holdSeconds)/\(targetHoldSeconds)s) 🧘"
            
            if holdSeconds >= targetHoldSeconds {
                isCompleted = true
                feedbackMessage = "✅ Balasana Completed! Reset verified."
                HapticFeedbackManager.shared.repSuccess()
            }
        } else {
            // STRICT ANTI-CHEAT PAUSE: Stop timer immediately if user sits up or lifts head
            lastHoldTimestamp = nil
            isHoldingValidPose = false
            feedbackMessage = "⚠️ Fold torso forward onto thighs, forehead to floor to continue timer"
        }
    }
    
    private func handlePoseLost() {
        lastHoldTimestamp = nil
        isHoldingValidPose = false
        feedbackMessage = "Camera searching for body position..."
    }
    
    public func reset() {
        holdSeconds = 0
        accumulatedHoldMs = 0
        lastHoldTimestamp = nil
        isHoldingValidPose = false
        isCompleted = false
        feedbackMessage = "Align in camera view"
    }
}
