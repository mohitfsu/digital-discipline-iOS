import SwiftUI

/// Real-Time Zen Enso Canvas for mindful creative reset
public struct ZenEnsoCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var touchPoints: [CGPoint] = []
    @State private var isDrawing = false
    @State private var symmetryScore: Int = 0
    @State private var isCompleted = false
    @State private var feedbackText = "Draw a single continuous circle without lifting your finger"
    
    public init(
        unlockDurationMinutes: Int = 5,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            Color.ddBgDeep.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.ddTextSecondary)
                    }
                    Spacer()
                    Text("ZEN ENSO CANVAS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.ddAccentViolet)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                VStack(spacing: 6) {
                    Text(isCompleted ? "✨ Enso Mastery Verified!" : "Draw Your Enso Circle")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text(feedbackText)
                        .font(.system(size: 13))
                        .foregroundColor(isCompleted ? Color.ddAccentEmerald : Color.ddTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                
                // Canvas Area
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.ddBgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(isCompleted ? Color.ddAccentEmerald : Color.ddBorderDefault, lineWidth: 1.5)
                        )
                    
                    // Faint Guideline
                    Circle()
                        .stroke(Color.ddBgSubtle, style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                        .frame(width: 220, height: 220)
                    
                    // Live Stroke Canvas
                    Canvas { context, size in
                        guard touchPoints.count > 1 else { return }
                        var path = Path()
                        path.move(to: touchPoints[0])
                        for point in touchPoints.dropFirst() {
                            path.addLine(to: point)
                        }
                        
                        context.stroke(
                            path,
                            with: .linearGradient(
                                Gradient(colors: [Color.ddAccentSky, Color.ddAccentViolet, Color.ddAccentEmerald]),
                                startPoint: .zero,
                                endPoint: CGPoint(x: size.width, y: size.height)
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                        )
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !isCompleted else { return }
                                isDrawing = true
                                touchPoints.append(value.location)
                            }
                            .onEnded { _ in
                                guard !isCompleted else { return }
                                isDrawing = false
                                evaluateEnsoStroke()
                            }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: 380)
                .padding(.horizontal, 20)
                
                // Symmetry Score Display
                if symmetryScore > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle.dashed")
                            .foregroundColor(isCompleted ? Color.ddAccentEmerald : Color.ddAccentAmber)
                        Text("Symmetry: \(symmetryScore)%")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.ddTextPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.ddBgSubtle)
                    .cornerRadius(20)
                }
                
                Spacer()
                
                // Bottom Button
                if isCompleted {
                    Button {
                        EarnedTimeWallet.shared.credit(seconds: unlockDurationMinutes * 60, reason: "Zen Enso Completed")
                        ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                        onCompleted()
                        dismiss()
                    } label: {
                        Text("Claim \(unlockDurationMinutes)m Unlock Pass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.ddAccentEmerald)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    private func evaluateEnsoStroke() {
        guard touchPoints.count > 25 else {
            feedbackText = "Stroke too short. Draw a complete circular loop."
            touchPoints.removeAll()
            return
        }
        
        let start = touchPoints.first!
        let end = touchPoints.last!
        let gap = hypot(start.x - end.x, start.y - end.y)
        
        if gap < 80 {
            symmetryScore = min(98, max(76, Int(100 - gap)))
            isCompleted = true
            feedbackText = "Harmonious flow achieved! Screen time unlocked."
            HapticFeedbackManager.shared.workoutCompleted()
        } else {
            symmetryScore = max(40, Int(80 - gap))
            feedbackText = "Close the circle gap (< 80pt) to complete."
            touchPoints.removeAll()
        }
    }
}
