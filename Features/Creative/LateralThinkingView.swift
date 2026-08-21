import SwiftUI

/// Alternative Uses Task evaluating divergent thinking to stimulate natural dopamine novelty
public struct LateralThinkingView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var itemObject = "a Coffee Mug"
    @State private var idea1 = ""
    @State private var idea2 = ""
    @State private var idea3 = ""
    @State private var isCompleted = false
    
    private let commonObjects = ["a Coffee Mug", "a Paperclip", "a Brick", "a Wooden Spoon", "an Umbrella"]
    
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
                    
                    Text("LATERAL DIVERGENT THINKING")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                }
                
                // Prompt Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name 3 Unusual Uses For:")
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    
                    Text(itemObject)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(DisciplineTheme.warning)
                    
                    Text("Think outside the box! (e.g. Planter for succulents, acoustic phone amplifier...)")
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(DisciplineTheme.surface)
                .cornerRadius(18)
                
                // 3 Idea Fields
                VStack(spacing: 10) {
                    ideaInputField(number: 1, text: $idea1, placeholder: "Idea 1: Unusual use...")
                    ideaInputField(number: 2, text: $idea2, placeholder: "Idea 2: Unusual use...")
                    ideaInputField(number: 3, text: $idea3, placeholder: "Idea 3: Unusual use...")
                }
                
                Spacer()
                
                Button {
                    guard areIdeasValid else { return }
                    isCompleted = true
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordBreathingSessionCompleted()
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Submit 3 Creative Uses")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(areIdeasValid ? DisciplineTheme.warning : DisciplineTheme.surfaceSecondary)
                    .cornerRadius(14)
                }
                .disabled(!areIdeasValid)
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            itemObject = commonObjects.randomElement()!
        }
    }
    
    private var areIdeasValid: Bool {
        idea1.trimmingCharacters(in: .whitespaces).count >= 3 &&
        idea2.trimmingCharacters(in: .whitespaces).count >= 3 &&
        idea3.trimmingCharacters(in: .whitespaces).count >= 3
    }
    
    private func ideaInputField(number: Int, text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(DisciplineTheme.warning.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DisciplineTheme.warning)
            }
            
            TextField(placeholder, text: text)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(DisciplineTheme.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.warning.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.warning)
                }
                
                Text("Prefrontal Elasticity Sparked!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Divergent thinking activated your creative neuro-circuits. Autopilot craving broken.")
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
