import SwiftUI

/// Full-screen Camera AI Workout Screen for all Physical Friction & Mindful Pause Resets
public struct ExerciseWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var squatClassifier: SquatExerciseClassifier
    @StateObject private var wallSitClassifier = WallSitClassifier(targetDurationSeconds: 30)
    @StateObject private var pushupClassifier = PushupExerciseClassifier(targetReps: 10)
    @StateObject private var plankClassifier = PlankClassifier(targetDurationSeconds: 45)
    @StateObject private var breathingClassifier = BreathingClassifier()
    
    @State private var selectedWorkoutType: FrictionUnlockType
    @State private var unlockDurationMinutes: Int
    
    public init(
        workoutType: FrictionUnlockType = .squats,
        targetReps: Int = 10,
        unlockDurationMinutes: Int = 15
    ) {
        _selectedWorkoutType = State(initialValue: workoutType)
        _unlockDurationMinutes = State(initialValue: unlockDurationMinutes)
        _squatClassifier = StateObject(wrappedValue: SquatExerciseClassifier(targetReps: targetReps))
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            // 60 FPS Real-time Camera Preview
            CameraFeedView { frame in
                switch selectedWorkoutType {
                case .squats:
                    squatClassifier.processFrame(frame)
                case .wallSit:
                    wallSitClassifier.processFrame(frame)
                case .pushups:
                    pushupClassifier.processFrame(frame)
                case .plank:
                    plankClassifier.processFrame(frame)
                case .boxBreathing:
                    breathingClassifier.processFrame(frame)
                default:
                    break
                }
            }
            .ignoresSafeArea()
            
            // Dark Gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.clear,
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // HUD Controls
            VStack(spacing: 16) {
                headerBar
                
                exerciseModePicker
                
                Spacer()
                
                // Dynamic HUD per exercise type
                switch selectedWorkoutType {
                case .squats:
                    squatHUD
                case .wallSit:
                    wallSitHUD
                case .pushups:
                    pushupHUD
                case .plank:
                    plankHUD
                case .boxBreathing:
                    breathingHUD
                default:
                    squatHUD
                }
                
                Spacer()
                
                bottomGuidance
            }
            .padding()
            
            // Completion Overlay
            if isAnyWorkoutComplete {
                completionOverlay
            }
        }
        .onAppear {
            if selectedWorkoutType == .boxBreathing {
                breathingClassifier.startSession()
            }
        }
    }
    
    private var isAnyWorkoutComplete: Bool {
        squatClassifier.isWorkoutComplete ||
        wallSitClassifier.isCompleted ||
        pushupClassifier.isWorkoutComplete ||
        plankClassifier.isCompleted ||
        breathingClassifier.isSessionComplete
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
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
                Text(selectedWorkoutType.categoryName)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Reward: \(unlockDurationMinutes)m Unlock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DisciplineTheme.textPrimary)
            }
        }
    }
    
    // MARK: - Exercise Mode Picker
    private var exerciseModePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pickerButton(type: .squats, title: "Squats", icon: "figure.cross.training")
                pickerButton(type: .wallSit, title: "Wall Sit", icon: "figure.strengthtraining.traditional")
                pickerButton(type: .pushups, title: "Pushups", icon: "figure.core.training")
                pickerButton(type: .plank, title: "Plank", icon: "figure.play")
                pickerButton(type: .boxBreathing, title: "Breathing", icon: "wind")
            }
            .padding(4)
        }
        .background(DisciplineTheme.surfaceSecondary.opacity(0.85))
        .cornerRadius(20)
    }
    
    private func pickerButton(type: FrictionUnlockType, title: String, icon: String) -> some View {
        let isSelected = selectedWorkoutType == type
        return Button {
            selectedWorkoutType = type
            resetAllClassifiers()
            if type == .boxBreathing {
                breathingClassifier.startSession()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(isSelected ? .white : DisciplineTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? DisciplineTheme.primary : Color.clear)
            .cornerRadius(16)
        }
    }
    
    private func resetAllClassifiers() {
        squatClassifier.reset()
        wallSitClassifier.reset()
        pushupClassifier.reset()
        plankClassifier.reset()
        breathingClassifier.reset()
    }
    
    // MARK: - Squat HUD
    private var squatHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(squatClassifier.repCount) / CGFloat(max(1, squatClassifier.targetReps)))
                    .stroke(DisciplineTheme.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(squatClassifier.repCount)")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("OF \(squatClassifier.targetReps) REPS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
            
            Text("KNEE ANGLE: \(Int(squatClassifier.currentKneeAngle))°")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(DisciplineTheme.surface.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Wall Sit HUD
    private var wallSitHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(wallSitClassifier.targetDurationSeconds - wallSitClassifier.secondsRemaining) / CGFloat(wallSitClassifier.targetDurationSeconds))
                    .stroke(DisciplineTheme.warning, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(wallSitClassifier.secondsRemaining)s")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("ISOMETRIC HOLD")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                }
            }
            
            Text("KNEE: \(Int(wallSitClassifier.currentKneeAngle))° (TARGET: 90°)")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(DisciplineTheme.surface.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Pushup HUD
    private var pushupHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(pushupClassifier.repCount) / CGFloat(max(1, pushupClassifier.targetReps)))
                    .stroke(DisciplineTheme.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(pushupClassifier.repCount)")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("OF \(pushupClassifier.targetReps) PUSHUPS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
            
            Text("ELBOW: \(Int(pushupClassifier.currentElbowAngle))° (<95° DEPTH)")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(DisciplineTheme.surface.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Plank HUD
    private var plankHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(plankClassifier.targetDurationSeconds - plankClassifier.secondsRemaining) / CGFloat(plankClassifier.targetDurationSeconds))
                    .stroke(DisciplineTheme.success, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(plankClassifier.secondsRemaining)s")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("CORE PLANK")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.success)
                }
            }
            
            Text("SPINE: \(Int(plankClassifier.spineAngle))° (GOAL: 180°)")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(DisciplineTheme.surface.opacity(0.8))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Breathing HUD
    private var breathingHUD: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: CGFloat(32 - breathingClassifier.totalSecondsRemaining) / 32.0)
                    .stroke(DisciplineTheme.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(breathingClassifier.phaseTimeRemaining)s")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(breathingClassifier.currentPhase.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            
            Text("TOTAL: \(breathingClassifier.totalSecondsRemaining)s REMAINING")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
    }
    
    // MARK: - Bottom Guidance Banner
    private var bottomGuidance: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(DisciplineTheme.accent)
            
            let message: String = {
                switch selectedWorkoutType {
                case .squats: return squatClassifier.formFeedback
                case .wallSit: return wallSitClassifier.formGuidance
                case .pushups: return pushupClassifier.formGuidance
                case .plank: return plankClassifier.formGuidance
                case .boxBreathing: return breathingClassifier.guidanceMessage
                default: return "Position yourself clearly in view"
                }
            }()
            
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(DisciplineTheme.surface.opacity(0.85))
        .cornerRadius(14)
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.success.opacity(0.2))
                        .frame(width: 90, height: 90)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundColor(DisciplineTheme.success)
                }
                
                VStack(spacing: 6) {
                    Text("Physical Friction Complete!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("You earned \(unlockDurationMinutes) minutes of distraction-free access.")
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                    dismiss()
                } label: {
                    Text("Claim \(unlockDurationMinutes)m Unlock & Exit")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DisciplineTheme.success)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(DisciplineTheme.surface)
            .cornerRadius(24)
            .padding(24)
        }
    }
}
