import SwiftUI

// MARK: - Dark OLED Color Palette & Design System
public extension Color {
    // Backgrounds
    static let ddBgDeep = Color(hex: "070B12")        // Deep OLED background
    static let ddBgSurface = Color(hex: "0F172A")     // Elevated cards & bottom sheets
    static let ddBgCard = Color(hex: "111827")        // Interactive item container
    static let ddBgSubtle = Color(hex: "1E293B")      // Nested sub-containers & badges
    
    // Accents & Glows
    static let ddAccentSky = Color(hex: "38BDF8")     // Primary focus / Action Blue
    static let ddAccentSkyGlow = Color(hex: "0EA5E9") // Radiant glow highlights
    static let ddAccentEmerald = Color(hex: "10B981") // Success / Habit Completed Green
    static let ddAccentAmber = Color(hex: "F59E0B")   // Active Session Countdown / Warning
    static let ddAccentRose = Color(hex: "F43F5E")    // Strict Lock / Shield Red
    static let ddAccentViolet = Color(hex: "8B5CF6")  // Creative & Perspective Mode Purple
    
    // Typography Colors
    static let ddTextPrimary = Color(hex: "F8FAFC")   // Headers & high-contrast titles
    static let ddTextSecondary = Color(hex: "94A3B8") // Subtitles & descriptive labels
    static let ddTextMuted = Color(hex: "475569")     // Captions & inactive pills
    
    // Borders & Dividers
    static let ddBorderDefault = Color(hex: "1E293B")
    static let ddBorderActive = Color(hex: "38BDF8").opacity(0.8)
}

// MARK: - Reusable Component 1: PremiumSelectCard
public struct PremiumSelectCard: View {
    public let title: String
    public let subtitle: String?
    public let icon: String?
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 16) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 24))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.ddTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.ddAccentSky : Color.ddBorderDefault, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.ddAccentSky)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(18)
            .background(Color.ddBgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.ddAccentSky : Color.ddBorderDefault, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: isSelected ? Color.ddAccentSkyGlow.opacity(0.2) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reusable Component 2: TimeDialProgressView
public struct TimeDialProgressView: View {
    public let availableSeconds: Int
    public let maxSeconds: Int
    public let isSessionActive: Bool
    
    public init(availableSeconds: Int, maxSeconds: Int = 3600, isSessionActive: Bool = false) {
        self.availableSeconds = availableSeconds
        self.maxSeconds = maxSeconds
        self.isSessionActive = isSessionActive
    }
    
    private var progress: Double {
        guard maxSeconds > 0 else { return 0 }
        return min(1.0, Double(availableSeconds) / Double(maxSeconds))
    }
    
    public var body: some View {
        ZStack {
            // Track Circle
            Circle()
                .stroke(Color.ddBorderDefault, lineWidth: 14)
            
            // Glowing Progress Circle
            Circle()
                .trim(from: 0, to: CGFloat(max(0.02, progress)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.ddAccentSky, Color.ddAccentEmerald, Color.ddAccentSkyGlow]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
                .shadow(color: Color.ddAccentSky.opacity(0.4), radius: 10)
            
            // Center Metrics
            VStack(spacing: 4) {
                Text("\(availableSeconds / 60)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text("MINUTES EARNED")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.ddTextSecondary)
                    .tracking(1.2)
            }
        }
        .frame(width: 200, height: 200)
    }
}

// MARK: - Reusable Component 3: BreathingPacerOrbView
public struct BreathingPacerOrbView: View {
    public let phaseText: String
    public let secondsRemaining: Int
    @State private var isExpanded = false
    
    public init(phaseText: String, secondsRemaining: Int) {
        self.phaseText = phaseText
        self.secondsRemaining = secondsRemaining
    }
    
    public var body: some View {
        VStack(spacing: 32) {
            ZStack {
                // Outer Pulse Ring
                Circle()
                    .fill(Color.ddAccentSky.opacity(0.12))
                    .frame(width: isExpanded ? 240 : 120, height: isExpanded ? 240 : 120)
                    .blur(radius: 20)
                
                // Core Bioluminescent Orb
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.ddAccentSky, Color(hex: "0284C7")]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 80
                        )
                    )
                    .frame(width: isExpanded ? 160 : 80, height: isExpanded ? 160 : 80)
                    .shadow(color: Color.ddAccentSkyGlow.opacity(0.6), radius: 25)
                
                Text("\(secondsRemaining)s")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(phaseText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.ddTextPrimary)
                .animation(.easeInOut, value: phaseText)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                isExpanded = true
            }
        }
    }
}
