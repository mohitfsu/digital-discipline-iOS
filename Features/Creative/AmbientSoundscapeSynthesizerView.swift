import SwiftUI
import AVFoundation

/// 4-Track Ambient Soundscape & 40Hz Binaural Focus synthesizer
public struct AmbientSoundscapeSynthesizerView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var track1Volume: Double = 0.8 // 40Hz Gamma Wave
    @State private var track2Volume: Double = 0.5 // Rain on Leaves
    @State private var track3Volume: Double = 0.6 // Tibetan Singing Bowl
    @State private var track4Volume: Double = 0.4 // Warm Lo-Fi Chords
    
    @State private var secondsRemaining = 20
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
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("SONIC RESET & FOCUS")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "A855F7"))
                        Text("Ambient Synthesizer")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Guidance Banner
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "A855F7"))
                    
                    Text("Mix your personalized focus soundscape. Listen for \(secondsRemaining)s to anchor your nervous system.")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                }
                .padding(14)
                .background(DisciplineTheme.surface)
                .cornerRadius(16)
                
                // 4-Track Mixer Sliders
                VStack(spacing: 14) {
                    trackSlider(title: "40Hz Gamma Focus Binaural Wave", icon: "waveform.path.ecg", volume: $track1Volume, color: DisciplineTheme.accent)
                    trackSlider(title: "Gentle Rain on Forest Leaves", icon: "cloud.rain.fill", volume: $track2Volume, color: DisciplineTheme.primary)
                    trackSlider(title: "Tibetan Singing Bowl Resonance", icon: "bell.fill", volume: $track3Volume, color: DisciplineTheme.warning)
                    trackSlider(title: "Warm Lo-Fi Tape Chords", icon: "music.note", volume: $track4Volume, color: Color(hex: "A855F7"))
                }
                .padding(16)
                .background(DisciplineTheme.surface)
                .cornerRadius(20)
                
                Spacer()
                
                // Countdown & Complete Button
                HStack {
                    Text("TIME TO GROUND FOCUS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Spacer()
                    Text("\(secondsRemaining)s")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "A855F7"))
                }
                .padding()
                .background(DisciplineTheme.surface)
                .cornerRadius(14)
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
        .onAppear {
            startTimer()
        }
    }
    
    private func trackSlider(title: String, icon: String, volume: Binding<Double>, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(volume.wrappedValue * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Slider(value: volume, in: 0...1.0)
                .tint(color)
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer.invalidate()
                isCompleted = true
                HapticFeedbackManager.shared.workoutCompleted()
                SharedDataStore.shared.recordBreathingSessionCompleted()
            }
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "A855F7").opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "headphones")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "A855F7"))
                }
                
                Text("Soundscape Grounded!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Binaural frequencies stabilized your focus channels.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                
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
                        .background(Color(hex: "A855F7"))
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
