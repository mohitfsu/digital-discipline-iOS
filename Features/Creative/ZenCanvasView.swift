import SwiftUI

/// Zen Drawing Canvas & 1-Stroke Enso Circle sandbox for active creative expression
public struct ZenCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var lines: [DrawingLine] = []
    @State private var currentLine: DrawingLine?
    @State private var promptText = "Draw a single continuous Zen Enso Circle in one breath"
    @State private var isCompleted = false
    @State private var strokeCount = 0
    @State private var selectedColor: Color = DisciplineTheme.accent
    
    private let palette: [Color] = [
        DisciplineTheme.accent,
        DisciplineTheme.success,
        Color(hex: "A855F7"),
        Color(hex: "EC4899"),
        DisciplineTheme.warning,
        Color.white
    ]
    
    public struct DrawingLine: Identifiable {
        public let id = UUID()
        public var points: [CGPoint]
        public var color: Color
        public var lineWidth: CGFloat
    }
    
    public init(unlockDurationMinutes: Int = 15, onCompleted: @escaping () -> Void = {}) {
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 16) {
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
                        Text("ACTIVE CREATOR MODE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(selectedColor)
                        Text("Zen Enso Canvas")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Creative Prompt Banner
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .foregroundColor(selectedColor)
                    Text(promptText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(12)
                .background(DisciplineTheme.surface)
                .cornerRadius(12)
                
                // Drawing Canvas Canvas Area
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(DisciplineTheme.surfaceSecondary.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        Canvas { context, size in
                            for line in lines {
                                var path = Path()
                                guard let first = line.points.first else { continue }
                                path.move(to: first)
                                for pt in line.points.dropFirst() {
                                    path.addLine(to: pt)
                                }
                                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                            }
                            
                            if let curr = currentLine {
                                var path = Path()
                                guard let first = curr.points.first else { return }
                                path.move(to: first)
                                for pt in curr.points.dropFirst() {
                                    path.addLine(to: pt)
                                }
                                context.stroke(path, with: .color(curr.color), lineWidth: curr.lineWidth)
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    let newPoint = value.location
                                    if currentLine == nil {
                                        currentLine = DrawingLine(points: [newPoint], color: selectedColor, lineWidth: 5.0)
                                        HapticFeedbackManager.shared.buttonTap()
                                    } else {
                                        currentLine?.points.append(newPoint)
                                    }
                                }
                                .onEnded { _ in
                                    if let finished = currentLine {
                                        lines.append(finished)
                                        currentLine = nil
                                        strokeCount += 1
                                        HapticFeedbackManager.shared.bottomSquatReached()
                                    }
                                }
                        )
                    }
                }
                
                // Color Palette & Controls
                HStack(spacing: 12) {
                    ForEach(palette, id: \.self) { color in
                        Button {
                            selectedColor = color
                            HapticFeedbackManager.shared.buttonTap()
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 2.5 : 0)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        lines.removeAll()
                        currentLine = nil
                        HapticFeedbackManager.shared.buttonTap()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(DisciplineTheme.textSecondary)
                            .padding(8)
                            .background(DisciplineTheme.surface)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 4)
                
                // Complete Creation Button
                Button {
                    guard strokeCount > 0 else { return }
                    isCompleted = true
                    HapticFeedbackManager.shared.workoutCompleted()
                    SharedDataStore.shared.recordBreathingSessionCompleted()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Artwork Completed & Mind Grounded")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(strokeCount > 0 ? selectedColor : DisciplineTheme.surfaceSecondary)
                    .cornerRadius(14)
                }
                .disabled(strokeCount == 0)
            }
            .padding(20)
            
            if isCompleted {
                completionOverlay
            }
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(selectedColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 40))
                        .foregroundColor(selectedColor)
                }
                
                Text("Creative Flow Activated!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You shifted from passive scrolling to active creation. Your mind is restored.")
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
                        .background(selectedColor)
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
