import SwiftUI

/// Spatial Working Memory Matrix puzzle to re-route dopamine toward active problem solving
public struct MemoryMatrixView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var currentLevel = 1
    @State private var totalLevels = 3
    @State private var patternTiles: Set<Int> = []
    @State private var selectedTiles: Set<Int> = []
    @State private var isShowingPattern = false
    @State private var isCompleted = false
    @State private var feedbackText = "Memorize the highlighted tiles..."
    
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
                        Text("MEMORY MATRIX")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        Text("Level \(currentLevel) of \(totalLevels)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Text(feedbackText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isShowingPattern ? DisciplineTheme.warning : DisciplineTheme.accent)
                    .multilineTextAlignment(.center)
                
                // 3x3 Matrix Grid
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { col in
                                let index = row * 3 + col
                                tileButton(index: index)
                            }
                        }
                    }
                }
                .padding(16)
                .background(DisciplineTheme.surface)
                .cornerRadius(24)
                
                Spacer()
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            startLevel(level: 1)
        }
    }
    
    private func tileButton(index: Int) -> some View {
        let isHighlighted = isShowingPattern && patternTiles.contains(index)
        let isUserSelected = selectedTiles.contains(index)
        let isCorrect = isUserSelected && patternTiles.contains(index)
        
        return Button {
            guard !isShowingPattern else { return }
            handleTileTap(index: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isHighlighted ? DisciplineTheme.accent :
                        isUserSelected ? (isCorrect ? DisciplineTheme.success : DisciplineTheme.danger) :
                        DisciplineTheme.surfaceSecondary
                    )
                    .frame(width: 85, height: 85)
                
                if isCorrect {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(isShowingPattern || selectedTiles.contains(index))
    }
    
    private func startLevel(level: Int) {
        selectedTiles.removeAll()
        patternTiles.removeAll()
        isShowingPattern = true
        feedbackText = "Memorize the pattern (1.5s)..."
        
        let tileCount = level + 2 // Level 1 = 3 tiles, Level 2 = 4 tiles, Level 3 = 5 tiles
        var generated = Set<Int>()
        while generated.count < tileCount {
            generated.insert(Int.random(in: 0..<9))
        }
        self.patternTiles = generated
        
        // Flash pattern for 1.5 seconds then hide
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isShowingPattern = false
            self.feedbackText = "Recall and tap the \(tileCount) highlighted tiles"
        }
    }
    
    private func handleTileTap(index: Int) {
        selectedTiles.insert(index)
        
        if patternTiles.contains(index) {
            HapticFeedbackManager.shared.repCompleted()
            
            if selectedTiles == patternTiles {
                // Passed Level
                HapticFeedbackManager.shared.bottomSquatReached()
                if currentLevel < totalLevels {
                    currentLevel += 1
                    feedbackText = "Level complete! Preparing next level..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.startLevel(level: self.currentLevel)
                    }
                } else {
                    isCompleted = true
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordBreathingSessionCompleted()
                }
            }
        } else {
            // Mistake
            HapticFeedbackManager.shared.securityError()
            feedbackText = "Incorrect tile. Retrying level..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.startLevel(level: self.currentLevel)
            }
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
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 36))
                        .foregroundColor(DisciplineTheme.accent)
                }
                
                Text("Working Memory Cleared!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("All 3 spatial memory stages completed. Brain fog eliminated.")
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
