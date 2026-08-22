import SwiftUI
import FamilyControls

/// Complete 11-Screen Rewire-Style Onboarding Experience with dynamic auto-sizing, pre-authorization, and quick app selector
public struct Full11ScreenRewireOnboardingView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var currentStep: Int = 0
    @State private var selectedPatterns: Set<String> = ["I scroll longer than planned"]
    @State private var dailyHoursSpent: Double = 3.0
    @State private var selectedPopularApps: Set<String> = ["Instagram", "TikTok", "YouTube"]
    @State private var selectedInterruptionStyles: Set<String> = ["Movement AI (Push-ups & Squats)", "Box Breathing & 4-7-8", "Zen Enso Canvas & Art"]
    @State private var selectedAccessTierMinutes: Int = 5
    @State private var isActivityPickerPresented = false
    @State private var isRequestingAuth = false
    
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
        .task {
            // Pre-request authorization early in background so FamilyActivityPicker has access
            await authManager.requestIndividualAuthorization()
        }
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
        VStack(spacing: 24) {
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
                    .frame(width: 150, height: 150)
                
                Image(systemName: "flame.circle.fill")
                    .font(.system(size: 68))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 14) {
                Text("Your phone isn't the problem.")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("The moment between impulse and action is.")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DisciplineTheme.accent, Color(hex: "38BDF8")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Rewire traps the automatic dopamine loop and gives you back hours of deep focus.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
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
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BEHAVIOR IDENTIFICATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Which loop traps you most?")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 12)
            
            VStack(spacing: 10) {
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
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
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
    
    // MARK: - Screen 2: App Picker with Quick Selector Grid
    private var screen2AppPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TARGET APPS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Select Distracting Apps")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Choose your most addictive apps to protect with friction resets.")
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 14) {
                    // Quick Popular App Toggles
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        popularAppPill(name: "Instagram", icon: "camera.fill", color: Color(hex: "E1306C"))
                        popularAppPill(name: "TikTok", icon: "play.tv.fill", color: Color(hex: "00F2FE"))
                        popularAppPill(name: "YouTube", icon: "play.rectangle.fill", color: Color(hex: "FF0000"))
                        popularAppPill(name: "Twitter / X", icon: "message.fill", color: Color(hex: "38BDF8"))
                        popularAppPill(name: "Reddit", icon: "bubble.left.and.bubble.right.fill", color: Color(hex: "FF4500"))
                        popularAppPill(name: "Snapchat", icon: "ghost.fill", color: Color(hex: "FACC15"))
                        popularAppPill(name: "Games", icon: "gamecontroller.fill", color: Color(hex: "A855F7"))
                        popularAppPill(name: "Netflix", icon: "film.fill", color: Color(hex: "E50914"))
                    }
                    
                    // Advanced Apple Screen Time Picker
                    Button {
                        isActivityPickerPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(DisciplineTheme.accent)
                            Text("Advanced iOS Screen Time Picker")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(DisciplineTheme.textTertiary)
                        }
                        .padding(14)
                        .background(DisciplineTheme.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                        )
                    }
                    
                    // Selection Summary
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(DisciplineTheme.success)
                        Text("\(selectedPopularApps.count) Apps Chosen for Friction Shielding")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(12)
                    .background(DisciplineTheme.surfaceSecondary)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func popularAppPill(name: String, icon: String, color: Color) -> some View {
        let isSelected = selectedPopularApps.contains(name)
        return Button {
            if isSelected {
                selectedPopularApps.remove(name)
            } else {
                selectedPopularApps.insert(name)
            }
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .padding(12)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 3: Self-Reported Time
    private var screen3TimeSpent: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY SCREEN TIME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("How much time on apps?")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 12)
            
            VStack(spacing: 10) {
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
    
    // MARK: - Screen 4: Lifetime Loss Calculation
    private var screen4LifetimeLoss: some View {
        let yearsLost = (dailyHoursSpent * 365.0 * 55.0) / (24.0 * 365.0)
        
        return VStack(spacing: 22) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("YOUR LIFETIME REALITY")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.danger)
                
                Text(String(format: "%.1f YEARS", yearsLost))
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "EF4444"), Color(hex: "F97316")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("of your remaining life spent staring at a glass screen.")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("At \(String(format: "%.1f", dailyHoursSpent)) hours/day:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DisciplineTheme.textSecondary)
                
                HStack {
                    Text("• Equivalent to \(Int(dailyHoursSpent * 365)) hours per year")
                    Spacer()
                }
                .font(.system(size: 13))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text("• Equivalent to 15+ entire unlived books, workouts, or skills")
                    Spacer()
                }
                .font(.system(size: 13))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 5: The Reframe
    private var screen5TheReframe: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("THE REFRAME")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Don't Quit Your Apps.")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Just give yourself a better interruption.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            // Flowchart Diagram
            HStack(spacing: 6) {
                flowNode(title: "IMPULSE", subtitle: "Reflex", color: DisciplineTheme.danger)
                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                    .foregroundColor(DisciplineTheme.textTertiary)
                flowNode(title: "PAUSE", subtitle: "30s Reset", color: DisciplineTheme.accent)
                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                    .foregroundColor(DisciplineTheme.textTertiary)
                flowNode(title: "CHOOSE", subtitle: "Earned Pass", color: DisciplineTheme.success)
            }
            
            Text("By inserting 30s of intentional friction, 78% of mindless urge cycles dissolve naturally.")
                .font(.system(size: 13))
                .foregroundColor(DisciplineTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(20)
    }
    
    private func flowNode(title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(color)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
        .padding(10)
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
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEURO-RESET MODES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Pick Your Resets")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Select the types of friction you enjoy.")
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 8) {
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
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .padding(12)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Screen 7: Live Breathing Calibration
    private var screen7BreathingCalibration: some View {
        VStack(spacing: 24) {
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
                    .frame(width: 220 * breathScale, height: 220 * breathScale)
                    .blur(radius: 16)
                
                Circle()
                    .stroke(DisciplineTheme.accent, lineWidth: 6)
                    .frame(width: 170 * breathScale, height: 170 * breathScale)
                
                VStack(spacing: 4) {
                    Text(breathPhase.uppercased())
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Breath \(breathCount)/3")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            .frame(height: 220)
            
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
                    HapticFeedbackManager.shared.repCompleted()
                }
            }
        }
    }
    
    // MARK: - Screen 8: Earned Access Tier
    private var screen8AccessTier: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EARNED PASS DURATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Set Your Reward Tier")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text("How many minutes of Instagram/TikTok per reset?")
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            VStack(spacing: 10) {
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
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DisciplineTheme.accent)
                    }
                }
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
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
    
    // MARK: - Screen 9: Permissions Handshake
    private var screen9Permissions: some View {
        VStack(spacing: 22) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundColor(DisciplineTheme.accent)
            
            VStack(spacing: 8) {
                Text("Enable Screen Time Shield")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("iOS Screen Time authorization enables automated app shielding.")
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 12) {
                Button {
                    isRequestingAuth = true
                    Task {
                        await authManager.requestIndividualAuthorization()
                        isRequestingAuth = false
                        HapticFeedbackManager.shared.buttonTap()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isRequestingAuth {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: authManager.isAuthorized ? "checkmark.circle.fill" : "hourglass.badge.plus")
                        }
                        Text(authManager.isAuthorized ? "Screen Time Authorized" : "Grant Screen Time Access")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(authManager.isAuthorized ? DisciplineTheme.success : DisciplineTheme.primary)
                    .cornerRadius(14)
                }
                
                Text(authManager.isAuthorized ? "✅ System authorization confirmed." : "Note: Tap to authorize. If sideloading with a free Apple ID, tap Continue to proceed.")
                    .font(.system(size: 11))
                    .foregroundColor(authManager.isAuthorized ? DisciplineTheme.success : DisciplineTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 10: Plan Activation
    private var screen10Activation: some View {
        VStack(spacing: 22) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(DisciplineTheme.success.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "bolt.badge.checkmark.fill")
                    .font(.system(size: 54))
                    .foregroundColor(DisciplineTheme.success)
            }
            
            VStack(spacing: 8) {
                Text("Your Plan Is Active!")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Your Dopamine Wallet is primed with \(selectedPopularApps.count) target apps. Each friction challenge will grant you a \(selectedAccessTierMinutes)-minute focus pass.")
                    .font(.system(size: 13))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
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
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
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
        HapticFeedbackManager.shared.repCompleted()
    }
}
