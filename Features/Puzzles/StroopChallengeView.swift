import SwiftUI

/// Stroop Effect Cognitive Inhibitory Control Puzzle to break scrolling autopilot
public struct StroopChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var currentRound = 1
    @State private var totalRounds = 6
    @State private var score = 0
    @State private var wordText = "RED"
    @State private var inkColor: Color = .blue
    @State private var inkColorName = "BLUE"
    @State private var isFinished = false
    @State private var feedbackText = "Tap the INK COLOR, not what the word reads!"
    @State private var feedbackColor = DisciplineTheme.accent
    
    private let colorOptions: [(name: String, color: Color)] = [
        ("RED", Color(hex: "EF4444")),
        ("BLUE", Color(hex: "0284C7")),
        ("GREEN", Color(hex: "10B981")),
        ("YELLOW", Color(hex: "F59E0B")),
        ("PURPLE", Color(hex: "A855F7"))
    ]
    
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
                        Text("STROOP INHIBITORY CHALLENGE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        Text("Round \(currentRound) of \(totalRounds)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Guidance Toast
                Text(feedbackText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(feedbackColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Center Stroop Stimulus Card
                VStack(spacing: 12) {
                    Text(wordText)
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(inkColor)
                        .padding(.vertical, 32)
                        .padding(.horizontal, 40)
                        .background(DisciplineTheme.surfaceSecondary.opacity(0.6))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                        )
                    
                    Text("WHAT COLOR IS THE INK?")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                Spacer()
                
                // Color Choice Buttons Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(colorOptions, id: \.name) { option in
                        Button {
                            handleAnswer(selectedName: option.name)
                        } label: {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 14, height: 14)
                                Text(option.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DisciplineTheme.surface)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(24)
            
            // Completion Modal
            if isFinished {
                completionView
            }
        }
        .onAppear {
            generateNextStimulus()
        }
    }
    
    private func generateNextStimulus() {
        let randomWordOption = colorOptions.randomElement()!
        var randomInkOption = colorOptions.randomElement()!
        
        // Ensure ink color is different from word text 80% of the time to maximize inhibitory friction
        while randomInkOption.name == randomWordOption.name {
            randomInkOption = colorOptions.randomElement()!
        }
        
        self.wordText = randomWordOption.name
        self.inkColor = randomInkOption.color
        self.inkColorName = randomInkOption.name
    }
    
    private func handleAnswer(selectedName: String) {
        if selectedName == inkColorName {
            score += 1
            HapticFeedbackManager.shared.repCompleted()
            feedbackText = "Correct! Inhibitory control engaged."
            feedbackColor = DisciplineTheme.success
        } else {
            HapticFeedbackManager.shared.securityError()
            feedbackText = "Incorect! You tapped the word text, not the ink color."
            feedbackColor = DisciplineTheme.danger
        }
        
        if currentRound < totalRounds {
            currentRound += 1
            generateNextStimulus()
        } else {
            isFinished = true
            HapticFeedbackManager.shared.workoutCompleted()
            SharedDataStore.shared.recordBreathingSessionCompleted()
        }
    }
    
    private var completionView: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.success.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.success)
                }
                
                Text("Prefrontal Cortex Activated!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You broke the autopilot impulse loop by solving \(score)/\(totalRounds) Stroop focus tests.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
                .padding(.top, 8)
            }
            .padding(24)
            .background(DisciplineTheme.surface)
            .cornerRadius(24)
            .padding(24)
        }
    }
}
