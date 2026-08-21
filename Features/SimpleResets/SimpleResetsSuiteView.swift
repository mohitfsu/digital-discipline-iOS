import SwiftUI
import CoreMotion

/// Simple physical resets: 30 steps pedometer, Drink Water, 20-20-20 Eye Relief, Posture Reset, Stand Up & Shake
public struct SimpleResetsSuiteView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let intervention: InterventionType
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var stepsCount = 0
    @State private var targetSteps = 30
    @State private var secondsRemaining = 30
    @State private var totalSeconds = 30
    @State private var isCompleted = false
    
    private let pedometer = CMPedometer()
    
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
                // Header
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
                        Text("SIMPLE PHYSICAL RESET")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.warning)
                        Text(intervention.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Icon & Title
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(DisciplineTheme.warning.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Text(intervention.emoji)
                            .font(.system(size: 64))
                    }
                    
                    Text(intervention.displayName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(resetGuidanceText)
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Pedometer vs Timer HUD
                if intervention == .walk30Steps {
                    pedometerHUD
                } else if intervention == .drinkWater {
                    drinkWaterHUD
                } else {
                    timerHUD
                }
                
                Spacer()
                
                if intervention == .drinkWater {
                    Button {
                        completeReset()
                    } label: {
                        Text("I drank a full glass of water")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DisciplineTheme.warning)
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
            if intervention == .walk30Steps {
                startPedometer()
            } else if intervention != .drinkWater {
                startTimer()
            }
        }
    }
    
    private var resetGuidanceText: String {
        switch intervention {
        case .walk30Steps:
            return "Get up and walk around the room with your phone until 30 steps are registered."
        case .drinkWater:
            return "Hydrate your brain! Step away to the kitchen, pour a full glass of water, and drink it."
        case .lookAwayFromScreen:
            return "20-20-20 Rule: Look out a window or at an object 20 feet away to completely relax your optical focus."
        case .postureReset:
            return "Roll your shoulders up, back, and down. Tuck your chin gently and align your ears over your shoulders."
        case .standUp:
            return "Stand up from your desk, shake out your hands, arms, and legs to release stagnant blood flow."
        default:
            return intervention.mechanismDescription
        }
    }
    
    private var pedometerHUD: some View {
        VStack(spacing: 8) {
            Text("\(stepsCount)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            
            Text("OF 30 STEPS COUNTED")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.warning)
        }
    }
    
    private var drinkWaterHUD: some View {
        VStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.system(size: 44))
                .foregroundColor(DisciplineTheme.accent)
            Text("HYDRATION CHECKPOINT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
    }
    
    private var timerHUD: some View {
        ZStack {
            Circle()
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 10)
                .frame(width: 150, height: 150)
            
            Circle()
                .trim(from: 0, to: CGFloat(totalSeconds - secondsRemaining) / CGFloat(totalSeconds))
                .stroke(DisciplineTheme.warning, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text("\(secondsRemaining)s")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("RESET")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.warning)
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer.invalidate()
                completeReset()
            }
        }
    }
    
    private func startPedometer() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { data, error in
                DispatchQueue.main.async {
                    if let steps = data?.numberOfSteps.intValue {
                        self.stepsCount = steps
                        if steps >= self.targetSteps {
                            self.pedometer.stopUpdates()
                            self.completeReset()
                        }
                    }
                }
            }
        } else {
            // Fallback simulated step timer if running on simulator
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                if self.stepsCount < self.targetSteps {
                    self.stepsCount += 1
                } else {
                    timer.invalidate()
                    self.completeReset()
                }
            }
        }
    }
    
    private func completeReset() {
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
                        .fill(DisciplineTheme.warning.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.warning)
                }
                
                Text("Physical Reset Complete!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You completed \(intervention.displayName). Your biological energy is restored.")
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
                        .background(DisciplineTheme.warning)
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
