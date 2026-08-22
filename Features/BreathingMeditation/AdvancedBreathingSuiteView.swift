import SwiftUI

/// Advanced Suite for 4-7-8, Resonant Coherence, 5-4-3-2-1 Sensory Grounding, and Body Scan
public struct AdvancedBreathingSuiteView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let mode: AdvancedResetMode
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    public enum AdvancedResetMode {
        case relax478
        case resonantCoherence
        case sensory54321
        case bodyScan
    }
    
    @State private var phase: String = "Inhale"
    @State private var circleScale: CGFloat = 0.7
    @State private var secondsRemaining: Int = 45
    @State private var groundingStep: Int = 5
    @State private var isComplete: Bool = false
    @State private var timer: Timer?
    
    public init(
        mode: AdvancedResetMode,
        unlockDurationMinutes: Int = 10,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                headerBar
                
                Spacer()
                
                // Visual Content based on mode
                switch mode {
                case .relax478:
                    breathingVisual(
                        title: "4-7-8 Deep Calm",
                        subtitle: phase,
                        instruction: "4s Inhale • 7s Hold • 8s Exhale",
                        color: Color(hex: "818CF8")
                    )
                case .resonantCoherence:
                    breathingVisual(
                        title: "Resonant Coherence",
                        subtitle: phase,
                        instruction: "5.5s Inhale • 5.5s Exhale (6 Breaths/Min HRV Sync)",
                        color: DisciplineTheme.accent
                    )
                case .sensory54321:
                    sensoryGroundingWizard
                case .bodyScan:
                    unclenchBodyScanView
                }
                
                Spacer()
                
                // Countdown & Complete Button
                bottomActionBar
            }
            .padding(24)
        }
        .onAppear {
            startSession()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Header
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
            Text("\(secondsRemaining)s Remaining")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(DisciplineTheme.accent.opacity(0.15))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Breathing Visual
    private func breathingVisual(title: String, subtitle: String, instruction: String, color: Color) -> some View {
        VStack(spacing: 32) {
            ZStack {
                // Outer Pulsing Glow
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 260 * circleScale, height: 260 * circleScale)
                    .blur(radius: 16)
                
                Circle()
                    .stroke(color, lineWidth: 6)
                    .frame(width: 200 * circleScale, height: 200 * circleScale)
                
                VStack(spacing: 8) {
                    Text(subtitle.uppercased())
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Image(systemName: "wind")
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
            .frame(height: 280)
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(instruction)
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - 5-4-3-2-1 Sensory Grounding Wizard
    private var sensoryGroundingWizard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "06B6D4").opacity(0.15))
                    .frame(width: 100, height: 100)
                Text("\(groundingStep)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "06B6D4"))
            }
            
            VStack(spacing: 8) {
                Text(groundingPromptTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(groundingPromptSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            
            Button {
                if groundingStep > 1 {
                    groundingStep -= 1
                    HapticFeedbackManager.shared.buttonTap()
                } else {
                    completeSession()
                }
            } label: {
                Text(groundingStep == 1 ? "Complete Grounding" : "Noticed & Next (→ \(groundingStep - 1))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color(hex: "06B6D4"))
                    .cornerRadius(14)
            }
            .padding(.top, 12)
        }
    }
    
    private var groundingPromptTitle: String {
        switch groundingStep {
        case 5: return "👀 Spot 5 Things You Can See"
        case 4: return "🖐️ Touch 4 Physical Textures"
        case 3: return "👂 Listen for 3 Ambient Sounds"
        case 2: return "👃 Notice 2 Subtle Scents"
        case 1: return "👅 Acknowledge 1 Present Taste"
        default: return "Grounding Complete"
        }
    }
    
    private var groundingPromptSubtitle: String {
        switch groundingStep {
        case 5: return "Scan your room. Identify 5 specific items around you right now."
        case 4: return "Feel the fabric of your clothes, desk surface, or phone case."
        case 3: return "Close your eyes. Listen to the room hum, footsteps, or breathing."
        case 2: return "Inhale deeply. Notice the air, coffee, or fresh environment."
        case 1: return "Take a sip of water or focus on your current mouth sensation."
        default: return "You are anchored in the physical present."
        }
    }
    
    // MARK: - Unclench Body Scan View
    private var unclenchBodyScanView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(hex: "EC4899").opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "EC4899"))
            }
            
            VStack(spacing: 12) {
                Text("Unclench & Release Tension")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 10) {
                    scanRow(step: "1", text: "Drop your shoulders away from your ears")
                    scanRow(step: "2", text: "Unclench your jaw and soften tongue from roof of mouth")
                    scanRow(step: "3", text: "Smooth out your forehead and brow tension")
                    scanRow(step: "4", text: "Take one long, audible exhale through your mouth")
                }
                .padding(16)
                .background(DisciplineTheme.surface)
                .cornerRadius(16)
            }
        }
    }
    
    private func scanRow(step: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(step)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "EC4899"))
                .frame(width: 24, height: 24)
                .background(Color(hex: "EC4899").opacity(0.15))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 12) {
            if isComplete {
                Button {
                    EarnedTimeWallet.shared.credit(seconds: unlockDurationMinutes * 60, reason: "Mindful Reset Completed")
                    ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                    onCompleted()
                    dismiss()
                } label: {
                    Text("Claim \(unlockDurationMinutes)m Unlock Pass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DisciplineTheme.success)
                        .cornerRadius(14)
                }
            } else {
                Text("Breathe & anchor in the physical moment...")
                    .font(.system(size: 12))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
        }
    }
    
    private func startSession() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if secondsRemaining > 1 {
                    secondsRemaining -= 1
                    updatePacingCycles()
                } else {
                    completeSession()
                }
            }
        }
    }
    
    private func updatePacingCycles() {
        if mode == .relax478 {
            let cycleSeconds = (45 - secondsRemaining) % 19
            if cycleSeconds < 4 {
                phase = "Inhale (4s)"
                withAnimation(.easeInOut(duration: 4.0)) { circleScale = 1.2 }
            } else if cycleSeconds < 11 {
                phase = "Hold (7s)"
                withAnimation(.easeInOut(duration: 1.0)) { circleScale = 1.2 }
            } else {
                phase = "Exhale (8s)"
                withAnimation(.easeInOut(duration: 8.0)) { circleScale = 0.7 }
            }
        } else if mode == .resonantCoherence {
            let cycleSeconds = (45 - secondsRemaining) % 11
            if cycleSeconds < 6 {
                phase = "Inhale (5.5s)"
                withAnimation(.easeInOut(duration: 5.5)) { circleScale = 1.2 }
            } else {
                phase = "Exhale (5.5s)"
                withAnimation(.easeInOut(duration: 5.5)) { circleScale = 0.7 }
            }
        }
    }
    
    private func completeSession() {
        timer?.invalidate()
        isComplete = true
        HapticFeedbackManager.shared.repSuccess()
    }
}
