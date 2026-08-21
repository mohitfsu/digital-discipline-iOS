import Foundation
import CoreGraphics
import Combine

public enum BreathingPhase: String, Sendable {
    case prepare = "Get Ready"
    case inhale = "Inhale Deeply (Nose)"
    case holdInhale = "Hold Breath"
    case exhale = "Exhale Slowly (Mouth)"
    case holdExhale = "Hold Empty"
    case completed = "Session Completed"
}

/// Guided 30-second Box Breathing micro-reset engine with vision posture verification
@MainActor
public final class BreathingClassifier: ObservableObject {
    @Published public var currentPhase: BreathingPhase = .prepare
    @Published public var phaseTimeRemaining: Int = 4
    @Published public var totalSecondsRemaining: Int = 32
    @Published public var isSessionComplete: Bool = false
    @Published public var isPostureAligned: Bool = true
    @Published public var guidanceMessage: String = "Sit tall with shoulders relaxed and look directly at the screen"
    
    private var timer: AnyCancellable?
    private var phaseSecondsElapsed = 0
    private let phaseDuration = 4 // 4s box breathing interval
    
    public init() {}
    
    public func startSession() {
        reset()
        currentPhase = .inhale
        phaseTimeRemaining = phaseDuration
        guidanceMessage = "Inhale slowly through your nose..."
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    public func reset() {
        timer?.cancel()
        timer = nil
        totalSecondsRemaining = 32
        phaseTimeRemaining = 4
        phaseSecondsElapsed = 0
        currentPhase = .prepare
        isSessionComplete = false
        guidanceMessage = "Sit tall with shoulders relaxed"
    }
    
    private func tick() {
        guard !isSessionComplete else { return }
        
        totalSecondsRemaining = max(0, totalSecondsRemaining - 1)
        phaseTimeRemaining = max(0, phaseTimeRemaining - 1)
        
        if totalSecondsRemaining == 0 {
            completeSession()
            return
        }
        
        if phaseTimeRemaining == 0 {
            advanceBreathingPhase()
        }
    }
    
    private func advanceBreathingPhase() {
        phaseTimeRemaining = phaseDuration
        
        switch currentPhase {
        case .prepare, .holdExhale:
            currentPhase = .inhale
            guidanceMessage = "Inhale deeply into your belly (4s)"
            HapticFeedbackManager.shared.bottomSquatReached()
        case .inhale:
            currentPhase = .holdInhale
            guidanceMessage = "Hold your breath calmly (4s)"
            HapticFeedbackManager.shared.bottomSquatReached()
        case .holdInhale:
            currentPhase = .exhale
            guidanceMessage = "Exhale slowly through your mouth (4s)"
            HapticFeedbackManager.shared.bottomSquatReached()
        case .exhale:
            currentPhase = .holdExhale
            guidanceMessage = "Hold lungs empty (4s)"
            HapticFeedbackManager.shared.bottomSquatReached()
        case .completed:
            break
        }
    }
    
    private func completeSession() {
        timer?.cancel()
        timer = nil
        currentPhase = .completed
        isSessionComplete = true
        guidanceMessage = "Calm focus restored. Temporary access granted."
        HapticFeedbackManager.shared.workoutCompleted()
        SharedDataStore.shared.recordBreathingSessionCompleted()
    }
    
    /// Processes human body pose keypoints to verify posture during breathing
    public func processFrame(_ frame: BodyPoseFrame) {
        guard let leftShoulder = frame.leftShoulder,
              let rightShoulder = frame.rightShoulder,
              let nose = frame.nose else {
            return
        }
        
        let shoulderCenter = CGPoint(
            x: (leftShoulder.x + rightShoulder.x) / 2.0,
            y: (leftShoulder.y + rightShoulder.y) / 2.0
        )
        
        let alignmentAngle = AngleCalculator.verticalAlignmentAngle(top: nose, bottom: shoulderCenter)
        let isUpright = alignmentAngle < 25.0
        self.isPostureAligned = isUpright
        
        if !isUpright && !isSessionComplete {
            guidanceMessage = "Align your head and neck upright with your shoulders"
        }
    }
}
