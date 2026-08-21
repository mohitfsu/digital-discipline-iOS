import SwiftUI

/// Micro-Poetry & 5-7-5 Haiku crafter forcing deliberate language retrieval
public struct HaikuPoetryCrafterView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var line1 = ""
    @State private var line2 = ""
    @State private var line3 = ""
    @State private var isCompleted = false
    
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
                    
                    Text("HAIKU POETRY CRAFTER")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "EC4899"))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Compose a 3-Line Mindful Haiku")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Write a 5-7-5 syllable structured reflection on your current headspace.")
                        .font(.system(size: 13))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3 Line Text Fields
                VStack(spacing: 12) {
                    haikuLineInput(title: "Line 1 (~5 Syllables)", placeholder: "Glass glows in the dark...", text: $line1)
                    haikuLineInput(title: "Line 2 (~7 Syllables)", placeholder: "Quiet room awaits my breath...", text: $line2)
                    haikuLineInput(title: "Line 3 (~5 Syllables)", placeholder: "Focus is restored...", text: $line3)
                }
                
                Spacer()
                
                Button {
                    guard isValidHaiku else { return }
                    isCompleted = true
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordBreathingSessionCompleted()
                } label: {
                    HStack {
                        Image(systemName: "feather")
                        Text("Publish Haiku & Restore Focus")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValidHaiku ? Color(hex: "EC4899") : DisciplineTheme.surfaceSecondary)
                    .cornerRadius(14)
                }
                .disabled(!isValidHaiku)
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
    }
    
    private var isValidHaiku: Bool {
        line1.trimmingCharacters(in: .whitespaces).count >= 4 &&
        line2.trimmingCharacters(in: .whitespaces).count >= 6 &&
        line3.trimmingCharacters(in: .whitespaces).count >= 4
    }
    
    private func haikuLineInput(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            TextField(placeholder, text: text)
                .padding(12)
                .background(DisciplineTheme.surface)
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "EC4899").opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "EC4899"))
                }
                
                Text("Poetry Created!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("“\(line1)\n\(line2)\n\(line3)”")
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(DisciplineTheme.accent)
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
                        .background(Color(hex: "EC4899"))
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
