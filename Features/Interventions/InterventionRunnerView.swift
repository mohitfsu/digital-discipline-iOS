import SwiftUI

/// Universal dispatcher that executes any of the 42 neuro-behavioral and creative interventions
public struct InterventionRunnerView: View {
    public let intervention: InterventionType
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
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
        Group {
            switch intervention {
            // Movement & Calisthenics (Camera AI)
            case .pushUps, .squats, .lunges, .plank, .wallSit, .jumpingJacks, .highKnees, .calfRaises, .sitToStand:
                MovementWorkoutHostView(
                    intervention: intervention,
                    unlockDurationMinutes: unlockDurationMinutes,
                    onCompleted: onCompleted
                )
                
            // Yoga & Mobility & Pull-ups
            case .pullUps, .mountainPose, .forwardFold, .treePose, .childPose, .shoulderStretch, .miniSunSalutation, .stretch:
                YogaMobilityView(
                    intervention: intervention,
                    unlockDurationMinutes: unlockDurationMinutes,
                    onCompleted: onCompleted
                )
                
            // Breathing & Meditation
            case .boxBreathing, .fourTwoSixBreathing, .oneMinuteBreathingReset, .threeBreathReset,
                 .thirtySecondMeditation, .oneMinuteMeditation, .mindfulPause:
                BreathingMeditationSuiteView(
                    intervention: intervention,
                    unlockDurationMinutes: unlockDurationMinutes,
                    onCompleted: onCompleted
                )
                
            // Simple Resets
            case .standUp, .walk30Steps, .drinkWater, .lookAwayFromScreen, .postureReset:
                SimpleResetsSuiteView(
                    intervention: intervention,
                    unlockDurationMinutes: unlockDurationMinutes,
                    onCompleted: onCompleted
                )
                
            // Cognitive Puzzles
            case .stroopTest:
                StroopChallengeView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .mathSprint:
                MentalMathSprintView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .memoryMatrix:
                MemoryMatrixView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .reactionTest:
                ReactionControlTestView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .mindfulReading:
                MindfulWisdomReadingView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .intentionalWriting:
                IntentionalityPromptView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
                
            // 🎨 Creative & Artistic Expression Interventions
            case .zenCanvas:
                ZenCanvasView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .scavengerHunt:
                RealWorldScavengerView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .handMudra:
                HandMudraDexterityView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .ambientSoundscape:
                AmbientSoundscapeSynthesizerView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .haikuPoetry:
                HaikuPoetryCrafterView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .lateralThinking:
                LateralThinkingView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            case .perspectiveCards:
                PerspectiveShiftCardsView(unlockDurationMinutes: unlockDurationMinutes, onCompleted: onCompleted)
            }
        }
    }
}

/// Host for 60 FPS Camera AI movement classifiers
public struct MovementWorkoutHostView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let intervention: InterventionType
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @StateObject private var squatClassifier = SquatExerciseClassifier(targetReps: 10)
    @StateObject private var pushupClassifier = PushupExerciseClassifier(targetReps: 10)
    @StateObject private var lungeClassifier = LungeExerciseClassifier(targetReps: 10)
    @StateObject private var wallSitClassifier = WallSitClassifier(targetDurationSeconds: 30)
    @StateObject private var plankClassifier = PlankClassifier(targetDurationSeconds: 30)
    @StateObject private var jacksClassifier = JumpingJacksClassifier(targetReps: 15)
    @StateObject private var highKneesClassifier = HighKneesClassifier(targetReps: 20)
    @StateObject private var calfRaisesClassifier = CalfRaisesClassifier(targetReps: 15)
    @StateObject private var sitToStandClassifier = SitToStandClassifier(targetReps: 10)
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            CameraFeedView { frame in
                switch intervention {
                case .squats: squatClassifier.processFrame(frame)
                case .pushUps: pushupClassifier.processFrame(frame)
                case .lunges: lungeClassifier.processFrame(frame)
                case .wallSit: wallSitClassifier.processFrame(frame)
                case .plank: plankClassifier.processFrame(frame)
                case .jumpingJacks: jacksClassifier.processFrame(frame)
                case .highKnees: highKneesClassifier.processFrame(frame)
                case .calfRaises: calfRaisesClassifier.processFrame(frame)
                case .sitToStand: sitToStandClassifier.processFrame(frame)
                default: break
                }
            }
            .ignoresSafeArea()
            
            // Dark Gradient
            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.clear, Color.black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(intervention.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.primary)
                        Text(intervention.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Rep / Hold Counter HUD
                hudView
                
                Spacer()
                
                // Guidance Toast
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(DisciplineTheme.primary)
                    Text(guidanceText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(DisciplineTheme.surface.opacity(0.85))
                .cornerRadius(14)
            }
            .padding()
            
            if isComplete {
                completionOverlay
            }
        }
    }
    
    private var isComplete: Bool {
        squatClassifier.isWorkoutComplete ||
        pushupClassifier.isWorkoutComplete ||
        lungeClassifier.isWorkoutComplete ||
        wallSitClassifier.isCompleted ||
        plankClassifier.isCompleted ||
        jacksClassifier.isWorkoutComplete ||
        highKneesClassifier.isWorkoutComplete ||
        calfRaisesClassifier.isWorkoutComplete ||
        sitToStandClassifier.isWorkoutComplete
    }
    
    @ViewBuilder
    private var hudView: some View {
        switch intervention {
        case .squats:
            counterHUD(current: squatClassifier.repCount, target: 10, label: "REPS", subtitle: "KNEE: \(Int(squatClassifier.currentKneeAngle))°")
        case .pushUps:
            counterHUD(current: pushupClassifier.repCount, target: 10, label: "PUSHUPS", subtitle: "ELBOW: \(Int(pushupClassifier.currentElbowAngle))°")
        case .lunges:
            counterHUD(current: lungeClassifier.repCount, target: 10, label: "LUNGES", subtitle: "KNEE: \(Int(lungeClassifier.currentKneeAngle))°")
        case .wallSit:
            counterHUD(current: wallSitClassifier.targetDurationSeconds - wallSitClassifier.secondsRemaining, target: 30, label: "\(wallSitClassifier.secondsRemaining)s", subtitle: "HOLD 90° (\(Int(wallSitClassifier.currentKneeAngle))°)")
        case .plank:
            counterHUD(current: plankClassifier.targetDurationSeconds - plankClassifier.secondsRemaining, target: 30, label: "\(plankClassifier.secondsRemaining)s", subtitle: "SPINE: \(Int(plankClassifier.spineAngle))°")
        case .jumpingJacks:
            counterHUD(current: jacksClassifier.repCount, target: 15, label: "JACKS", subtitle: jacksClassifier.state.rawValue)
        case .highKnees:
            counterHUD(current: highKneesClassifier.repCount, target: 20, label: "HIGH KNEES", subtitle: "DRIVE KNEES HIGH")
        case .calfRaises:
            counterHUD(current: calfRaisesClassifier.repCount, target: 15, label: "CALF RAISES", subtitle: "ANKLE EXTENSION")
        case .sitToStand:
            counterHUD(current: sitToStandClassifier.repCount, target: 10, label: "SIT-TO-STAND", subtitle: "FULL EXTENSION")
        default:
            EmptyView()
        }
    }
    
    private func counterHUD(current: Int, target: Int, label: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(current) / CGFloat(max(1, target)))
                    .stroke(DisciplineTheme.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(label.contains("s") ? label : "\(current)")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("GOAL: \(target)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
            
            Text(subtitle)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DisciplineTheme.surface.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    private var guidanceText: String {
        switch intervention {
        case .squats: return squatClassifier.formFeedback
        case .pushUps: return pushupClassifier.formGuidance
        case .lunges: return lungeClassifier.formGuidance
        case .wallSit: return wallSitClassifier.formGuidance
        case .plank: return plankClassifier.formGuidance
        case .jumpingJacks: return jacksClassifier.formGuidance
        case .highKnees: return highKneesClassifier.formGuidance
        case .calfRaises: return calfRaisesClassifier.formGuidance
        case .sitToStand: return sitToStandClassifier.formGuidance
        default: return "Maintain active camera view"
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.primary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.primary)
                }
                
                Text("Movement Validated!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You completed \(intervention.displayName). Physical friction reset verified.")
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
                        .background(DisciplineTheme.primary)
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
