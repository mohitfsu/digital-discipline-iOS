import SwiftUI

/// Rewire-style "I AM HAVING AN URGE" Urge Surfing & Dopamine Reset Modal
public struct UrgeSurfingModalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var secondsRemaining: Int = 45
    @State private var waveScale: CGFloat = 0.8
    @State private var hasResisted: Bool = false
    @State private var timer: Timer?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Ambient Radial Glow
            RadialGradient(
                colors: [Color(hex: "F97316").opacity(0.25), Color.black],
                center: .center,
                startRadius: 40,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    Spacer()
                    Text("URGE SURFING PROTOCOL")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "F97316"))
                }
                
                Spacer()
                
                // Animated Urge Wave Pulse
                ZStack {
                    Circle()
                        .fill(Color(hex: "F97316").opacity(0.12))
                        .frame(width: 240 * waveScale, height: 240 * waveScale)
                        .blur(radius: 20)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "F97316"), Color(hex: "FBBF24")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 180 * waveScale, height: 180 * waveScale)
                    
                    VStack(spacing: 6) {
                        Text("\(secondsRemaining)s")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("RIDE THE WAVE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color(hex: "F97316"))
                    }
                }
                .frame(height: 260)
                
                VStack(spacing: 8) {
                    Text("Urges peak in 60s, then fade")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("Notice the physical sensation of the urge in your chest or hands. Breathe into it without acting.")
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if hasResisted {
                        Button {
                            wallet.credit(seconds: 300, reason: "Urge Resisted (+5m Earned)")
                            HapticFeedbackManager.shared.repSuccess()
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                Text("Claim +5m Focus Pass (Urge Defeated)")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "F97316"), Color(hex: "EA580C")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    } else {
                        Button {
                            hasResisted = true
                        } label: {
                            Text("I Resisted the Urge (Pass)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(DisciplineTheme.surfaceSecondary)
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            waveScale = 1.2
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if secondsRemaining > 1 {
                    secondsRemaining -= 1
                } else {
                    hasResisted = true
                    timer?.invalidate()
                }
            }
        }
    }
}
