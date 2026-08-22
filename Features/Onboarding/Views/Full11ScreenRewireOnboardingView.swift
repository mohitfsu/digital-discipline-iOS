import SwiftUI
import FamilyControls

/// Complete 11-Screen Rewire-Style Onboarding Experience
public struct Full11ScreenRewireOnboardingView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var currentStep: Int = 0
    @State private var selectedPatterns: Set<String> = ["I scroll longer than planned"]
    @State private var dailyHoursSpent: Double = 3.0
    @State private var selectedInterruptionStyles: Set<String> = ["Movement AI", "Box Breathing", "Zen Enso Canvas"]
    @State private var selectedAccessTierMinutes: Int = 5
    @State private var isActivityPickerPresented = false
    
    // Interactive Breathing Pacer State for Screen 7
    @State private var breathPhase: String = "Inhale"
    @State private var breathScale: CGFloat = 0.7
    @State private var breathCount: Int = 1
    @State private var isBreathTestDone: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Bar
                if currentStep > 0 && currentStep < 10 {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }
                
                // Screen Content
                TabView(selection: $currentStep) {
                    screen0Manifesto.tag(0)
                    screen1Patterns.tag(1)
                    screen2AppPicker.tag(2)
                    screen3TimeSpent.tag(3)
                    screen4LifetimeLoss.tag(4)
                    screen5TheReframe.tag(5)
                    screen6InterruptionStyles.tag(6)
                    screen7BreathingCalibration.tag(7)
                    screen8AccessTier.tag(8)
                    screen9Permissions.tag(9)
                    screen10Activation.tag(10)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                // Bottom Navigation
                bottomNavigationControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .familyActivityPicker(
            isPresented: $isActivityPickerPresented,
            selection: $shieldManager.activitySelection
        )
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(1..<10) { index in
                Capsule()
                    .fill(index <= currentStep ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
    }
    
    // MARK: - Screen 0: Cinematic Manifesto
    private var screen0Manifesto: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [DisciplineTheme.accent.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "flame.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 16) {
                Text("Your phone isn't the problem.")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("The moment between impulse and action is.")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DisciplineTheme.accent, Color(hex: "38BDF8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                
                Text("Rewire traps the automatic dopamine loop and gives you back hours of deep focus.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Text("🔒 Private • On-Device Neural Engine • Zero Tracking")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textTertiary)
        }
        .padding(20)
    }
    
    // MARK: - Screen 1: Behavioral Patterns
    private var screen1Patterns: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("BEHAVIOR IDENTIFICATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Which loop traps you most?")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                patternToggleCard(title: "I open my phone without thinking", emoji: "📱")
                patternToggleCard(title: "I scroll longer than planned", emoji: "⏳")
                patternToggleCard(title: "Minutes turn into hours", emoji: "🌀")
                patternToggleCard(title: "I check apps while working", emoji: "💼")
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func patternToggleCard(title: String, emoji: String) -> some View {
        let isSelected = selectedPatterns.contains(title)
        return Button {
            if isSelected {
                selectedPatterns.remove(title)
            } else {
                selectedPatterns.insert(title)
            }
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .padding(16)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 2: App Picker
    private var screen2AppPicker: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("TARGET APPS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Choose Distracting Apps")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("Select the apps you want to protect with neuro-friction.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            Button {
                isActivityPickerPresented = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "plus.app.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DisciplineTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open Screen Time Picker")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Instagram, TikTok, YouTube, Reddit, Games...")
                            .font(.system(size: 12))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(DisciplineTheme.textTertiary)
                }
                .padding(18)
                .background(DisciplineTheme.surface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DisciplineTheme.accent.opacity(0.3), lineWidth: 1)
                )
            }
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(DisciplineTheme.success)
                Text("\(shieldManager.activitySelection.applicationTokens.count) Apps Selected")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(14)
            .background(DisciplineTheme.surfaceSecondary)
            .cornerRadius(14)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 3: Self-Reported Time
    private var screen3TimeSpent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DAILY SCREEN TIME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("How much time on apps?")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                timeOptionCard(hours: 1.0, label: "< 1 Hour / Day")
                timeOptionCard(hours: 2.0, label: "1 – 2 Hours / Day")
                timeOptionCard(hours: 3.5, label: "2 – 4 Hours / Day (Average)")
                timeOptionCard(hours: 5.5, label: "5+ Hours / Day (Heavy)")
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func timeOptionCard(hours: Double, label: String) -> some View {
        let isSelected = (dailyHoursSpent == hours)
        return Button {
            dailyHoursSpent = hours
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .padding(16)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 4: Lifetime Loss Calculation
    private var screen4LifetimeLoss: some View {
        let yearsLost = (dailyHoursSpent * 365.0 * 55.0) / (24.0 * 365.0)
        
        return VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("YOUR LIFETIME REALITY")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.danger)
                
                Text(String(format: "%.1f YEARS", yearsLost))
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "EF4444"), Color(hex: "F97316")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("of your remaining life spent staring at a glass screen.")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("At \(String(format: "%.1f", dailyHoursSpent)) hours/day:")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(DisciplineTheme.textSecondary)
                
                HStack {
                    Text("• Equivalent to \(Int(dailyHoursSpent * 365)) hours per year")
                    Spacer()
                }
                .font(.system(size: 13))
                .foregroundColor(.white)
                
                HStack {
                    Text("• Equivalent to 15+ entire unlived books or skills")
                    Spacer()
                }
                .font(.system(size: 13))
                .foregroundColor(.white)
            }
            .padding(18)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 5: The Reframe
    private var screen5TheReframe: some View {
        VStack(spacing: 28) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("THE REFRAME")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Don't Quit Your Apps.")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Just give yourself a better interruption.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            // Flowchart Diagram
            HStack(spacing: 8) {
                flowNode(title: "IMPULSE", subtitle: "Reflex", color: DisciplineTheme.danger)
                Image(systemName: "arrow.right")
                    .foregroundColor(DisciplineTheme.textTertiary)
                flowNode(title: "PAUSE", subtitle: "30s Reset", color: DisciplineTheme.accent)
                Image(systemName: "arrow.right")
                    .foregroundColor(DisciplineTheme.textTertiary)
                flowNode(title: "CHOOSE", subtitle: "Earned Pass", color: DisciplineTheme.success)
            }
            
            Text("By inserting 30s of intentional friction, 78% of mindless urge cycles dissolve naturally.")
                .font(.system(size: 13))
                .foregroundColor(DisciplineTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(20)
    }
    
    private func flowNode(title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(DisciplineTheme.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Screen 6: Interruption Styles
    private var screen6InterruptionStyles: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("NEURO-RESET MODES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Pick Your Resets")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("Select the types of friction you enjoy.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 10) {
                    styleToggleRow(title: "Movement AI (Push-ups & Squats)", icon: "🏋️")
                    styleToggleRow(title: "Box Breathing & 4-7-8", icon: "🌬️")
                    styleToggleRow(title: "Zen Enso Canvas & Art", icon: "🎨")
                    styleToggleRow(title: "Yoga & Balasana Mobility", icon: "🧘")
                    styleToggleRow(title: "Stroop & Mental Math Sprint", icon: "🧠")
                    styleToggleRow(title: "Hydration & Eye Relief", icon: "💧")
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func styleToggleRow(title: String, icon: String) -> some View {
        let isSelected = selectedInterruptionStyles.contains(title)
        return Button {
            if isSelected {
                selectedInterruptionStyles.remove(title)
            } else {
                selectedInterruptionStyles.insert(title)
            }
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .padding(14)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 7: Live Breathing Calibration
    private var screen7BreathingCalibration: some View {
        VStack(spacing: 28) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("FIRST MICRO-INTERVENTION")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Calibrate Your Focus")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("Take 3 calming breaths with the pacer.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            // Interactive Expanding Breath Circle
            ZStack {
                Circle()
                    .fill(DisciplineTheme.accent.opacity(0.15))
                    .frame(width: 240 * breathScale, height: 240 * breathScale)
                    .blur(radius: 16)
                
                Circle()
                    .stroke(DisciplineTheme.accent, lineWidth: 6)
                    .frame(width: 180 * breathScale, height: 180 * breathScale)
                
                VStack(spacing: 6) {
                    Text(breathPhase.uppercased())
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Breath \(breathCount)/3")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .frame(height: 240)
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            runBreathingCalibration()
        }
    }
    
    private func runBreathingCalibration() {
        withAnimation(.easeInOut(duration: 4.0)) {
            breathScale = 1.2
            breathPhase = "Inhale"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            breathPhase = "Hold"
            HapticFeedbackManager.shared.buttonTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 4.0)) {
                    breathScale = 0.7
                    breathPhase = "Exhale"
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    breathCount = 2
                    isBreathTestDone = true
                    HapticFeedbackManager.shared.repSuccess()
                }
            }
        }
    }
    
    // MARK: - Screen 8: Earned Access Tier
    private var screen8AccessTier: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("EARNED PASS DURATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Set Your Reward Tier")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("How many minutes of Instagram/TikTok per reset?")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                tierCard(minutes: 5, title: "5 Minutes (Strict & Fast)", subtitle: "Quick check-in, stops deep rabbit holes.")
                tierCard(minutes: 10, title: "10 Minutes (Balanced)", subtitle: "Recommended: Enough to reply to messages.")
                tierCard(minutes: 15, title: "15 Minutes (Generous)", subtitle: "Extended session for long-form reading.")
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func tierCard(minutes: Int, title: String, subtitle: String) -> some View {
        let isSelected = (selectedAccessTierMinutes == minutes)
        return Button {
            selectedAccessTierMinutes = minutes
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DisciplineTheme.accent)
                    }
                }
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(16)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 9: Permissions Handshake
    private var screen9Permissions: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(DisciplineTheme.accent)
            
            VStack(spacing: 8) {
                Text("Enable Screen Time Shield")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("iOS requires Screen Time authorization to present mindful intervention shields.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button {
                Task {
                    await authManager.requestIndividualAuthorization()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: authManager.isAuthorized ? "checkmark.circle.fill" : "hourglass.badge.plus")
                    Text(authManager.isAuthorized ? "Screen Time Authorized" : "Grant Screen Time Access")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(authManager.isAuthorized ? DisciplineTheme.success : DisciplineTheme.primary)
                .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 10: Plan Activation
    private var screen10Activation: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(DisciplineTheme.success.opacity(0.2))
                    .frame(width: 130, height: 130)
                Image(systemName: "bolt.badge.checkmark.fill")
                    .font(.system(size: 58))
                    .foregroundColor(DisciplineTheme.success)
            }
            
            VStack(spacing: 8) {
                Text("Your Plan Is Active!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Your Dopamine Wallet is primed. Each friction challenge will grant you a \(selectedAccessTierMinutes)-minute focus pass.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Bottom Navigation Controls
    private var bottomNavigationControls: some View {
        HStack(spacing: 12) {
            if currentStep > 0 && currentStep < 10 {
                Button {
                    currentStep -= 1
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(DisciplineTheme.surfaceSecondary)
                        .cornerRadius(14)
                }
            }
            
            Button {
                if currentStep < 10 {
                    currentStep += 1
                    HapticFeedbackManager.shared.buttonTap()
                } else {
                    // Activate & Launch
                    completeAndLaunch()
                }
            } label: {
                Text(currentStep == 0 ? "BUILD MY PLAN" : (currentStep == 10 ? "Enter Dopamine Hub" : "Continue"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
        }
    }
    
    private func completeAndLaunch() {
        var profile = dataStore.activeProfile
        profile.temporaryUnlockMinutes = selectedAccessTierMinutes
        dataStore.activeProfile = profile
        
        wallet.credit(seconds: 300, reason: "Onboarding Welcome Bonus")
        shieldManager.enforceShields()
        dataStore.completeOnboarding()
        HapticFeedbackManager.shared.repSuccess()
    }
}
