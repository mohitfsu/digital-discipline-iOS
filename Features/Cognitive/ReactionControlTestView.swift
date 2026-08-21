import SwiftUI

/// Inhibitory Reaction Control Test: Wait on Red, Tap on Green across 3 rounds
public struct ReactionControlTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var currentRound = 1
    @State private var totalRounds = 3
    @State private var testState: ReactionState = .waitingToStart
    @State private var greenStartTime: Date?
    @State private var reactionTimes: [Double] = []
    @State private var isFinished = false
    @State private var earlyTapWarning = false
    
    private enum ReactionState {
        case waitingToStart
        case primedRed
        case greenActive
        case roundFinished(ms: Double)
    }
    
    public init(unlockDurationMinutes: Int = 15, onCompleted: @escaping () -> Void = {}) {
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
                        Text("REACTION INHIBITORY TEST")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        Text("Round \(currentRound) of \(totalRounds)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Interactive Tap Target Canvas
                tapTargetCard
                    .frame(height: 320)
                
                Spacer()
            }
            .padding(24)
            
            if isFinished {
                completionOverlay
            }
        }
        .onAppear {
            startRound()
        }
    }
    
    private var tapTargetCard: some View {
        Button {
            handleCardTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardBackgroundColor)
                
                VStack(spacing: 12) {
                    Image(systemName: cardIconName)
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    Text(cardTitle)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(cardSubtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private var cardBackgroundColor: Color {
        switch testState {
        case .waitingToStart:
            return DisciplineTheme.surfaceSecondary
        case .primedRed:
            return DisciplineTheme.danger
        case .greenActive:
            return DisciplineTheme.success
        case .roundFinished:
            return DisciplineTheme.primary
        }
    }
    
    private var cardIconName: String {
        switch testState {
        case .waitingToStart: return "hand.tap.fill"
        case .primedRed: return "hand.raised.fill"
        case .greenActive: return "bolt.fill"
        case .roundFinished: return "checkmark"
        }
    }
    
    private var cardTitle: String {
        switch testState {
        case .waitingToStart: return "TAP TO BEGIN"
        case .primedRed: return "WAIT FOR GREEN..."
        case .greenActive: return "TAP NOW!"
        case .roundFinished(let ms): return "\(Int(ms)) ms"
        }
    }
    
    private var cardSubtitle: String {
        switch testState {
        case .waitingToStart: return "Do NOT tap while the screen is red"
        case .primedRed: return earlyTapWarning ? "Too early! Inhibitory penalty applied." : "Hold your impulse until it changes"
        case .greenActive: return "Tap as fast as humanly possible!"
        case .roundFinished: return "Tap anywhere for next round"
        }
    }
    
    private func startRound() {
        earlyTapWarning = false
        testState = .primedRed
        
        let randomDelay = Double.random(in: 1.8...4.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            if case .primedRed = self.testState {
                self.testState = .greenActive
                self.greenStartTime = Date()
                HapticFeedbackManager.shared.bottomSquatReached()
            }
        }
    }
    
    private func handleCardTap() {
        switch testState {
        case .waitingToStart:
            startRound()
            
        case .primedRed:
            // Tapped too early!
            HapticFeedbackManager.shared.securityError()
            earlyTapWarning = true
            // Restart current round
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startRound()
            }
            
        case .greenActive:
            if let start = greenStartTime {
                let elapsedMs = Date().timeIntervalSince(start) * 1000.0
                reactionTimes.append(elapsedMs)
                HapticFeedbackManager.shared.repCompleted()
                testState = .roundFinished(ms: elapsedMs)
            }
            
        case .roundFinished:
            if currentRound < totalRounds {
                currentRound += 1
                startRound()
            } else {
                isFinished = true
                HapticFeedbackManager.shared.workoutCompleted()
                SharedDataStore.shared.recordBreathingSessionCompleted()
            }
        }
    }
    
    private var completionOverlay: some View {
        let avgMs = reactionTimes.reduce(0, +) / Double(max(1, reactionTimes.count))
        
        return ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.success.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.success)
                }
                
                Text("Impulse Control Verified!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Average Reaction: \(Int(avgMs))ms across \(totalRounds) rounds with zero false starts.")
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
