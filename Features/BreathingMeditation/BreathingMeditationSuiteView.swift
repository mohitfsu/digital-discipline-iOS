import SwiftUI

/// Comprehensive visualizer and pacer for all 4 Breathing and 3 Meditation interventions
public struct BreathingMeditationSuiteView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let intervention: InterventionType
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var totalSecondsRemaining: Int
    @State private var totalDuration: Int
    @State private var breathPhase = "Inhale"
    @State private var phaseSecondsRemaining = 4
    @State private var orbScale: CGFloat = 0.6
    @State private var isCompleted = false
    
    public init(
        intervention: InterventionType,
        unlockDurationMinutes: Int = 15,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.intervention = intervention
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
        
        let dur: Int = {
            switch intervention {
            case .boxBreathing: return 32
            case .fourTwoSixBreathing: return 36
            case .oneMinuteBreathingReset, .oneMinuteMeditation: return 60
            case .threeBreathReset, .thirtySecondMeditation, .mindfulPause: return 30
            default: return 30
            }
        }()
        _totalSecondsRemaining = State(initialValue: dur)
        _totalDuration = State(initialValue: dur)
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Header
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
                            .foregroundColor(accentColor)
                        Text(intervention.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Pulsing Breathing / Meditation Orb
                VStack(spacing: 20) {
                    ZStack {
                        // Outer ambient ring
                        Circle()
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 220, height: 220)
                            .scaleEffect(orbScale * 1.15)
                            .animation(.easeInOut(duration: phaseDuration), value: orbScale)
                        
                        // Inner pulsing core
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .scaleEffect(orbScale)
                            .animation(.easeInOut(duration: phaseDuration), value: orbScale)
                            .shadow(color: accentColor.opacity(0.4), radius: 20)
                        
                        VStack(spacing: 4) {
                            Text(isMeditation ? "Stillness" : breathPhase.uppercased())
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            if !isMeditation {
                                Text("\(phaseSecondsRemaining)s")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    
                    Text(guidanceText)
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Bottom Countdown
                HStack {
                    Text("TOTAL TIME REMAINING")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Spacer()
                    Text("\(totalSecondsRemaining)s")
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .foregroundColor(accentColor)
                }
                .padding()
                .background(DisciplineTheme.surface)
                .cornerRadius(14)
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            startBreathingEngine()
        }
    }
    
    private var isMeditation: Bool {
        intervention.category == .meditation
    }
    
    private var accentColor: Color {
        isMeditation ? Color(hex: "A855F7") : DisciplineTheme.accent
    }
    
    private var phaseDuration: Double {
        switch intervention {
        case .fourTwoSixBreathing:
            return breathPhase == "Exhale" ? 6.0 : (breathPhase == "Hold" ? 2.0 : 4.0)
        default:
            return 4.0
        }
    }
    
    private var guidanceText: String {
        switch intervention {
        case .boxBreathing:
            return "Even 4-4-4-4 rhythm: Inhale 4s, Hold 4s, Exhale 4s, Hold 4s."
        case .fourTwoSixBreathing:
            return "Parasympathetic activation: Inhale 4s, Hold 2s, Slow Exhale 6s."
        case .oneMinuteBreathingReset:
            return "Breathe naturally and gently. Allow tension to leave with each exhale."
        case .threeBreathReset:
            return "Take 3 deep, grounding belly breaths before continuing."
        case .thirtySecondMeditation:
            return "Close your eyes. Rest in complete silence and observe the present moment."
        case .oneMinuteMeditation:
            return "Full minute of silent stillness away from notifications and dopamine spikes."
        case .mindfulPause:
            return "Ask yourself: 'What am I feeling right now? Is opening this app truly helpful?'"
        default:
            return intervention.mechanismDescription
        }
    }
    
    private func startBreathingEngine() {
        orbScale = 1.0
        breathPhase = "Inhale"
        phaseSecondsRemaining = 4
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if totalSecondsRemaining > 0 {
                totalSecondsRemaining -= 1
                phaseSecondsRemaining -= 1
                
                if phaseSecondsRemaining == 0 {
                    advanceBreathCycle()
                }
            } else {
                timer.invalidate()
                completeSession()
            }
        }
    }
    
    private func advanceBreathCycle() {
        HapticFeedbackManager.shared.bottomSquatReached()
        
        switch intervention {
        case .boxBreathing:
            switch breathPhase {
            case "Inhale":
                breathPhase = "Hold Full"
                phaseSecondsRemaining = 4
                orbScale = 1.0
            case "Hold Full":
                breathPhase = "Exhale"
                phaseSecondsRemaining = 4
                orbScale = 0.6
            case "Exhale":
                breathPhase = "Hold Empty"
                phaseSecondsRemaining = 4
                orbScale = 0.6
            default:
                breathPhase = "Inhale"
                phaseSecondsRemaining = 4
                orbScale = 1.0
            }
            
        case .fourTwoSixBreathing:
            switch breathPhase {
            case "Inhale":
                breathPhase = "Hold"
                phaseSecondsRemaining = 2
                orbScale = 1.0
            case "Hold":
                breathPhase = "Exhale (Slow)"
                phaseSecondsRemaining = 6
                orbScale = 0.5
            default:
                breathPhase = "Inhale"
                phaseSecondsRemaining = 4
                orbScale = 1.0
            }
            
        default:
            if breathPhase == "Inhale" {
                breathPhase = "Exhale"
                phaseSecondsRemaining = 4
                orbScale = 0.6
            } else {
                breathPhase = "Inhale"
                phaseSecondsRemaining = 4
                orbScale = 1.0
            }
        }
    }
    
    private func completeSession() {
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
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(accentColor)
                }
                
                Text("Autonomic Balance Restored!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You completed \(intervention.displayName). Your mind is centered.")
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
                        .background(accentColor)
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
