import SwiftUI

/// Cognitive friction reflection journal requiring conscious intention before unlocking
public struct IntentionalityPromptView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var intentionText = ""
    @State private var isCompleted = false
    
    private let minCharacters = 25
    
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
                    
                    Text("CONSCIOUS INTENTIONALITY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why are you unlocking now?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Type 1 intentional sentence explaining the exact purpose and outcome you need to achieve.")
                        .font(.system(size: 13))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Text Editor
                ZStack(alignment: .topLeading) {
                    if intentionText.isEmpty {
                        Text("e.g., I need to respond to Sarah's urgent project message on WhatsApp and check my calendar...")
                            .font(.system(size: 14))
                            .foregroundColor(DisciplineTheme.textTertiary)
                            .padding(16)
                    }
                    
                    TextEditor(text: $intentionText)
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .frame(height: 140)
                        .scrollContentBackground(.hidden)
                }
                .background(DisciplineTheme.surface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
                
                // Character Progress
                HStack {
                    Text("\(intentionText.count)/\(minCharacters) characters minimum")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(intentionText.count >= minCharacters ? DisciplineTheme.success : DisciplineTheme.textSecondary)
                    Spacer()
                }
                
                Spacer()
                
                // Unlock Button
                Button {
                    guard intentionText.count >= minCharacters else { return }
                    ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                    HapticFeedbackManager.shared.workoutCompleted()
                    onCompleted()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Confirm Intention & Unlock (\(unlockDurationMinutes)m)")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(intentionText.count >= minCharacters ? DisciplineTheme.warning : DisciplineTheme.surfaceSecondary)
                    .cornerRadius(14)
                }
                .disabled(intentionText.count < minCharacters)
            }
            .padding(24)
        }
    }
}
