import SwiftUI

/// Stoic wisdom reflection and comprehension check to awaken deliberate mindfulness
public struct MindfulWisdomReadingView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var readingSecondsRemaining = 25
    @State private var isReadingTimeDone = false
    @State private var isCompleted = false
    @State private var selectedAnswerIndex: Int?
    @State private var isAnswerIncorrect = false
    
    private let quoteText = "“You have power over your mind - not outside events. Realize this, and you will find strength. The happiness of your life depends upon the quality of your thoughts.”"
    private let author = "Marcus Aurelius, Meditations"
    private let question = "According to the passage, where does your true power reside?"
    private let options = [
        "In outside events and external notifications",
        "Over your own mind and thoughts",
        "In seeking rapid stimulation",
        "In comparing yourself to others"
    ]
    private let correctIndex = 1
    
    public init(unlockDurationMinutes: Int = 15, onCompleted: @escaping () -> Void = {}) {
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
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
                    
                    Text("STOIC WISDOM REFLECTION")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                }
                
                // Quote Card
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 28))
                        .foregroundColor(DisciplineTheme.accent.opacity(0.6))
                    
                    Text(quoteText)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .lineSpacing(6)
                    
                    HStack {
                        Spacer()
                        Text("— \(author)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                    }
                }
                .padding(20)
                .background(DisciplineTheme.surface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
                
                if !isReadingTimeDone {
                    // Reading countdown
                    VStack(spacing: 6) {
                        ProgressView(value: Double(25 - readingSecondsRemaining), total: 25.0)
                            .tint(DisciplineTheme.accent)
                        
                        Text("Reflect on these words for \(readingSecondsRemaining)s before verification...")
                            .font(.system(size: 12))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    .padding(.top, 8)
                } else {
                    // Comprehension Check
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comprehension Check:")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        
                        Text(question)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<options.count, id: \.self) { idx in
                                Button {
                                    handleOptionSelect(index: idx)
                                } label: {
                                    HStack {
                                        Text(options[idx])
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(selectedAnswerIndex == idx ? (idx == correctIndex ? DisciplineTheme.success : DisciplineTheme.danger) : DisciplineTheme.surfaceSecondary)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            startReadingTimer()
        }
    }
    
    private func startReadingTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if readingSecondsRemaining > 0 {
                readingSecondsRemaining -= 1
            } else {
                timer.invalidate()
                isReadingTimeDone = true
                HapticFeedbackManager.shared.bottomSquatReached()
            }
        }
    }
    
    private func handleOptionSelect(index: Int) {
        selectedAnswerIndex = index
        if index == correctIndex {
            HapticFeedbackManager.shared.repCompleted()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.isCompleted = true
                HapticFeedbackManager.shared.workoutCompleted()
                SharedDataStore.shared.recordBreathingSessionCompleted()
            }
        } else {
            HapticFeedbackManager.shared.securityError()
            isAnswerIncorrect = true
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.accent.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.accent)
                }
                
                Text("Wisdom Verified!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Mindful perspective grounded. Screen access granted.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                
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
                        .background(DisciplineTheme.accent)
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
