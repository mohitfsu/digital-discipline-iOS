import UIKit

/// High-performance haptic feedback engine for physical resets, rep increments, and security locks
@MainActor
public final class HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        prepare()
    }
    
    public func prepare() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactRigid.prepare()
        notificationGenerator.prepare()
    }
    
    /// Triggered upon each completed valid squat rep
    public func repCompleted() {
        impactMedium.impactOccurred(intensity: 1.0)
    }
    
    /// Triggered upon successful rep / breath cycle validation
    public func repSuccess() {
        impactMedium.impactOccurred(intensity: 1.0)
    }
    
    /// Triggered when user reaches bottom squat position
    public func bottomSquatReached() {
        impactLight.impactOccurred(intensity: 0.8)
    }
    
    /// Triggered on successful shield unlock or workout completion
    public func workoutCompleted() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Triggered on PIN error or unauthorized bypass attempt
    public func securityError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    /// Triggered on profile mode switch or schedule toggle
    public func profileSwitched() {
        impactRigid.impactOccurred()
    }
    
    /// Triggered on time picker or button taps
    public func buttonTap() {
        impactLight.impactOccurred()
    }
}
