import SwiftUI

/// Mental Math Sprint puzzle to engage analytical processing before app access
public struct MentalMathSprintView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var questionIndex = 1
    @State private var totalQuestions = 5
    @State private var questionPrompt = "18 + 27"
    @State private var correctAnswer = 45
    @State private var answerChoices: [Int] = [45, 43, 47, 55]
    @State private var isFinished = false
    
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
                        Text("MENTAL MATH SPRINT")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.primary)
                        Text("Problem \(questionIndex) of \(totalQuestions)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Question Card
                VStack(spacing: 12) {
                    Text(questionPrompt)
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("SOLVE RAPIDLY")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(DisciplineTheme.surface)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
                
                Spacer()
                
                // Multiple Choice Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(answerChoices, id: \.self) { choice in
                        Button {
                            handleAnswer(choice: choice)
                        } label: {
                            Text("\(choice)")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(DisciplineTheme.surfaceSecondary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(DisciplineTheme.primary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(24)
            
            if isFinished {
                completionOverlay
            }
        }
        .onAppear {
            generateQuestion()
        }
    }
    
    private func generateQuestion() {
        let op = Int.random(in: 0..<3)
        var qStr = ""
        var ans = 0
        
        switch op {
        case 0: // Addition
            let a = Int.random(in: 15...55)
            let b = Int.random(in: 12...49)
            ans = a + b
            qStr = "\(a) + \(b)"
        case 1: // Subtraction
            let a = Int.random(in: 50...99)
            let b = Int.random(in: 15...45)
            ans = a - b
            qStr = "\(a) − \(b)"
        default: // Multiplication
            let a = Int.random(in: 6...12)
            let b = Int.random(in: 4...9)
            ans = a * b
            qStr = "\(a) × \(b)"
        }
        
        self.questionPrompt = qStr
        self.correctAnswer = ans
        
        var choices = Set<Int>([ans])
        while choices.count < 4 {
            let offset = Int.random(in: -8...8)
            if offset != 0 && ans + offset > 0 {
                choices.insert(ans + offset)
            }
        }
        self.answerChoices = choices.shuffled()
    }
    
    private func handleAnswer(choice: Int) {
        if choice == correctAnswer {
            HapticFeedbackManager.shared.repCompleted()
            if questionIndex < totalQuestions {
                questionIndex += 1
                generateQuestion()
            } else {
                isFinished = true
                HapticFeedbackManager.shared.workoutCompleted()
                SharedDataStore.shared.recordBreathingSessionCompleted()
            }
        } else {
            HapticFeedbackManager.shared.securityError()
            generateQuestion()
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
                
                Text("Analytical Focus Restored!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("All 5 math sprints solved cleanly. Cognitive discipline verified.")
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
