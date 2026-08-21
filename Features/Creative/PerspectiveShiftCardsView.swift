import SwiftUI

/// 3D Interactive Stoic Tarot & Perspective Shift deck to reframe cognitive impulses
public struct PerspectiveShiftCardsView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var selectedCardIndex: Int?
    @State private var isFlipped = false
    @State private var isCompleted = false
    
    private let cards: [(title: String, icon: String, quote: String, question: String)] = [
        (
            "MEMENTO MORI",
            "hourglass",
            "“You could leave life right now. Let that determine what you do and say and think.” — Marcus Aurelius",
            "Will opening this app contribute to the legacy you want to leave today?"
        ),
        (
            "THE COSMIC ZOOM",
            "globe.americas.fill",
            "“Look at the stars and see yourself running with them. Consider the immense ocean of time behind you.”",
            "From the perspective of your entire lifetime, how valuable is this scroll session?"
        ),
        (
            "THE INVERSION",
            "arrow.triangle.2.circlepath",
            "“Invert, always invert. Turn a situation upside down to see what you must avoid.” — Carl Jacobi",
            "What would the most disciplined, unstoppable version of you do right now?"
        )
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
                    
                    Text("PERSPECTIVE SHIFT DECK")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.primary)
                }
                
                VStack(spacing: 6) {
                    Text("Choose a Card to Reframe Your Mind")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Tap one of the three reflection cards to shatter your immediate dopamine tunnel vision.")
                        .font(.system(size: 13))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // 3 Cards Deck
                if let selected = selectedCardIndex {
                    // Flipped Single Card Detail
                    flippedCardView(card: cards[selected])
                        .transition(.scale)
                } else {
                    // 3-Card Selection Grid
                    HStack(spacing: 12) {
                        ForEach(0..<cards.count, id: \.self) { index in
                            cardBackView(index: index)
                        }
                    }
                }
                
                Spacer()
                
                if selectedCardIndex != nil {
                    Button {
                        isCompleted = true
                        HapticFeedbackManager.shared.workoutCompleted()
                        SharedDataStore.shared.recordBreathingSessionCompleted()
                    } label: {
                        Text("I Have Shifted My Perspective")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DisciplineTheme.primary)
                            .cornerRadius(14)
                    }
                }
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
    }
    
    private func cardBackView(index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectedCardIndex = index
            }
            HapticFeedbackManager.shared.repCompleted()
        } label: {
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundColor(DisciplineTheme.accent)
                
                Text("CARD \(index + 1)")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(
                LinearGradient(
                    colors: [DisciplineTheme.surface, DisciplineTheme.surfaceSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DisciplineTheme.primary.opacity(0.4), lineWidth: 1.5)
            )
        }
    }
    
    private func flippedCardView(card: (title: String, icon: String, quote: String, question: String)) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DisciplineTheme.primary.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: card.icon)
                    .font(.system(size: 28))
                    .foregroundColor(DisciplineTheme.primary)
            }
            
            Text(card.title)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            
            Text(card.quote)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(DisciplineTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal)
            
            Divider()
                .background(DisciplineTheme.surfaceSecondary)
                .padding(.horizontal, 20)
            
            Text(card.question)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(DisciplineTheme.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(DisciplineTheme.surface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(DisciplineTheme.primary.opacity(0.5), lineWidth: 2)
        )
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.primary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "eye.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.primary)
                }
                
                Text("Perspective Cleared!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Tunnel vision dissolved. You have reclaimed conscious control.")
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
