import SwiftUI

/// Guided visual and timer engine for all Yoga & Mobility interventions
public struct YogaMobilityView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let intervention: InterventionType
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var secondsRemaining = 30
    @State private var totalDuration = 30
    @State private var currentFlowStep = 1
    @State private var isRunning = true
    @State private var isCompleted = false
    
    public init(
        intervention: InterventionType,
        unlockDurationMinutes: Int = 15,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.intervention = intervention
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(intervention.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.success)
                        Text(intervention.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Visual Posture Icon & Title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(DisciplineTheme.success.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Text(intervention.emoji)
                            .font(.system(size: 64))
                    }
                    
                    Text(intervention.displayName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(poseGuidanceText)
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Center Timer / Reps HUD
                if intervention == .pullUps {
                    pullUpsHUD
                } else {
                    timerHUD
                }
                
                Spacer()
                
                // Bottom Button
                if intervention == .pullUps {
                    Button {
                        completeIntervention()
                    } label: {
                        Text("Confirm 5 Pull-ups Completed")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DisciplineTheme.primary)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            if intervention != .pullUps {
                startTimer()
            }
        }
    }
    
    private var poseGuidanceText: String {
        switch intervention {
        case .mountainPose:
            return "Stand tall with feet hip-width apart, arms at sides, shoulders relaxed, and crown of head reaching toward the sky."
        case .forwardFold:
            return "Hinge from your hips with soft knees, let your head hang heavy, and breathe deeply into your lower back and hamstrings."
        case .treePose:
            return "Place one foot onto your inner calf or thigh. Bring hands to heart center and focus your gaze on a single unmoving point."
        case .childPose:
            return "Kneel on the floor, bring big toes together, sit on your heels, and extend your arms forward on the floor."
        case .shoulderStretch:
            return "Bring your right arm across your chest and gently hook with your left forearm. Switch sides halfway through."
        case .miniSunSalutation:
            return "Flow: 1. Inhale reach high → 2. Exhale forward fold → 3. Inhale halfway lift → 4. Exhale fold & rise."
        case .stretch:
            return "Interlace fingers overhead, push palms toward ceiling, and take 3 deep full-body grounding breaths."
        case .pullUps:
            return "Complete 5 strict pull-ups or chin-ups on your door/gym bar to reset your physical dopamine system."
        default:
            return intervention.mechanismDescription
        }
    }
    
    private var timerHUD: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(totalDuration - secondsRemaining) / CGFloat(totalDuration))
                    .stroke(DisciplineTheme.success, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: secondsRemaining)
                
                VStack(spacing: 4) {
                    Text("\(secondsRemaining)s")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("HOLD POSE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.success)
                }
            }
        }
    }
    
    private var pullUpsHUD: some View {
        VStack(spacing: 8) {
            Text("5 REPS")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("UPPER BODY RESET")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.accent)
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
                if secondsRemaining == 15 && intervention == .shoulderStretch {
                    HapticFeedbackManager.shared.bottomSquatReached()
                }
            } else {
                timer.invalidate()
                completeIntervention()
            }
        }
    }
    
    private func completeIntervention() {
        isCompleted = true
        HapticFeedbackManager.shared.workoutCompleted()
        SharedDataStore.shared.recordBreathingSessionCompleted()
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.success.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.success)
                }
                
                Text("Mobility & Flow Restored!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You completed \(intervention.displayName). Your body is re-aligned.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                    onCompleted()
                    dismiss()
                } label: {
                    Text("Claim \(unlockDurationMinutes)m Unlock")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DisciplineTheme.success)
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(DisciplineTheme.surface)
            .cornerRadius(24)
            .padding(24)
        }
    }
}
