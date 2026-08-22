import SwiftUI
import FamilyControls

/// Complete 11-Screen Rewire-Style Onboarding starting with Persona Selection
public struct Full11ScreenRewireOnboardingView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var currentStep: Int = 0
    @State private var selectedProfileType: ProfileType = .selfDiscipline
    @State private var selectedPatterns: Set<String> = ["I scroll longer than planned"]
    @State private var dailyHoursSpent: Double = 3.0
    @State private var installedApps: [DeviceInstalledApp] = []
    @State private var selectedAppNames: Set<String> = ["Instagram"]
    @State private var customAppNameInput: String = ""
    @State private var isShowingAddApp = false
    @State private var selectedInterventionCategories: Set<String> = ["MOVE", "BREATHE", "RESET", "CREATE"]
    @State private var selectedAccessTierMinutes: Int = 5
    @State private var isAuthHandshakeCompleted = false
    
    // Interactive Breathing Pacer State for Screen 7
    @State private var breathPhase: String = "Inhale"
    @State private var breathScale: CGFloat = 0.7
    @State private var breathCount: Int = 1
    @State private var breathElapsedSeconds: Int = 0
    @State private var isBreathTestDone: Bool = false
    @State private var breathTimer: Timer?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.ddBgDeep.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Bar with Dynamic Island Safe Padding
                if currentStep > 0 && currentStep < 10 {
                    progressBar
                        .padding(.horizontal, 24)
                        .padding(.top, 56)
                        .padding(.bottom, 12)
                } else {
                    Spacer().frame(height: 52)
                }
                
                // Screen Content
                TabView(selection: $currentStep) {
                    screen0PersonaMode.tag(0)
                    screen1Patterns.tag(1)
                    screen2InstalledAppsPicker.tag(2)
                    screen3TimeSpent.tag(3)
                    screen4LifetimeLoss.tag(4)
                    screen5TheReframe.tag(5)
                    screen6InterventionStyles.tag(6)
                    screen7BreathingCalibration.tag(7)
                    screen8AccessTier.tag(8)
                    screen9Permissions.tag(9)
                    screen10Activation.tag(10)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.38, dampingFraction: 0.82), value: currentStep)
                
                // Bottom Navigation Controls
                bottomNavigationControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            loadInstalledApps()
        }
        .onDisappear {
            breathTimer?.invalidate()
        }
    }
    
    private func loadInstalledApps() {
        let detected = InstalledAppsDetector.shared.getInstalledAppsOnDevice()
        self.installedApps = detected
        if selectedAppNames.isEmpty && !detected.isEmpty {
            self.selectedAppNames = [detected[0].name]
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(1..<10) { index in
                Capsule()
                    .fill(index <= currentStep ? Color.ddAccentSky : Color.ddBgSubtle)
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
    }
    
    // MARK: - Screen 0: Mode Selection (Self Mode vs Family vs Corporate)
    private var screen0PersonaMode: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("WELCOME TO DIGITAL DISCIPLINE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Choose Your Mode")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text("Select how you want the neuro-friction system configured.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.ddTextSecondary)
            }
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                PremiumSelectCard(
                    title: "🧘 Self-Discipline Mode",
                    subtitle: "Personal focus: Lock Instagram/games behind 30s physical and mindful friction.",
                    icon: "🔥",
                    isSelected: selectedProfileType == .selfDiscipline,
                    action: { selectedProfileType = .selfDiscipline }
                )
                
                PremiumSelectCard(
                    title: "👨‍👩‍👧 Family & Parental Mode",
                    subtitle: "Parent & child device management: PIN locks, anti-tamper, and study hours.",
                    icon: "👨‍👩‍👧",
                    isSelected: selectedProfileType == .family,
                    action: { selectedProfileType = .family }
                )
                
                PremiumSelectCard(
                    title: "🏢 Corporate / Office Mode",
                    subtitle: "Workplace productivity: Strict 9-5 work hours, social blocking, deep focus blocks.",
                    icon: "🏢",
                    isSelected: selectedProfileType == .corporate,
                    action: { selectedProfileType = .corporate }
                )
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text("🔒 Private • On-Device Neural Engine • Zero Tracking")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.ddTextMuted)
                Spacer()
            }
        }
        .padding(20)
    }
    
    // MARK: - Screen 1: Behavioral Problem Identification
    private var screen1Patterns: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BEHAVIOR IDENTIFICATION")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Which loop traps you most?")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
            
            VStack(spacing: 10) {
                PremiumSelectCard(
                    title: "I open my phone without thinking",
                    subtitle: "Reflexive opening during micro-moments",
                    icon: "📱",
                    isSelected: selectedPatterns.contains("I open my phone without thinking"),
                    action: { togglePattern("I open my phone without thinking") }
                )
                
                PremiumSelectCard(
                    title: "I scroll longer than planned",
                    subtitle: "5 minutes accidentally turns into 45 minutes",
                    icon: "⏳",
                    isSelected: selectedPatterns.contains("I scroll longer than planned"),
                    action: { togglePattern("I scroll longer than planned") }
                )
                
                PremiumSelectCard(
                    title: "Minutes turn into hours",
                    subtitle: "Late-night rabbit holes and reel doomscrolling",
                    icon: "🌀",
                    isSelected: selectedPatterns.contains("Minutes turn into hours"),
                    action: { togglePattern("Minutes turn into hours") }
                )
                
                PremiumSelectCard(
                    title: "I check apps while working",
                    subtitle: "Constant context switching destroys flow state",
                    icon: "💼",
                    isSelected: selectedPatterns.contains("I check apps while working"),
                    action: { togglePattern("I check apps while working") }
                )
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func togglePattern(_ title: String) {
        if selectedPatterns.contains(title) {
            selectedPatterns.remove(title)
        } else {
            selectedPatterns.insert(title)
        }
    }
    
    // MARK: - Screen 2: Real Installed Apps on Device + Add App
    private var screen2InstalledAppsPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TARGET APPS TO SHIELD")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Select Apps on Your Phone")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Select the apps you want protected behind physical friction resets.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.ddTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
            
            ScrollView {
                VStack(spacing: 10) {
                    // Apps List
                    ForEach(installedApps) { app in
                        let isSelected = selectedAppNames.contains(app.name)
                        let gradientColors = app.gradientColors.map { Color(hex: $0) }
                        
                        Button {
                            if isSelected {
                                selectedAppNames.remove(app.name)
                            } else {
                                selectedAppNames.insert(app.name)
                            }
                            HapticFeedbackManager.shared.buttonTap()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: app.iconName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(app.name)
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.ddTextPrimary)
                                    Text("Shield with 30s physical reset")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.ddTextSecondary)
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
                            .padding(14)
                            .background(isSelected ? Color.ddBgSubtle : Color.ddBgCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.ddAccentSky : Color.ddBorderDefault, lineWidth: isSelected ? 1.5 : 1)
                            )
                        }
                    }
                    
                    // Add Custom App Option
                    if isShowingAddApp {
                        HStack(spacing: 10) {
                            TextField("Enter App Name (e.g. Chess)", text: $customAppNameInput)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.ddBgSubtle)
                                .cornerRadius(10)
                            
                            Button("Add") {
                                if !customAppNameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                    let cleanName = customAppNameInput.trimmingCharacters(in: .whitespaces)
                                    selectedAppNames.insert(cleanName)
                                    installedApps.append(DeviceInstalledApp(id: cleanName.lowercased(), name: cleanName, scheme: "\(cleanName.lowercased())://", iconName: "app.fill", gradientColors: ["38BDF8", "0284C7"]))
                                    customAppNameInput = ""
                                    isShowingAddApp = false
                                    HapticFeedbackManager.shared.buttonTap()
                                }
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.ddAccentSky)
                            .cornerRadius(10)
                        }
                    } else {
                        Button {
                            isShowingAddApp = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.ddAccentSky)
                                Text("+ Add Custom App Name")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.ddAccentSky)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.ddBgCard)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.ddBorderDefault, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Active Target Summary
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(Color.ddAccentEmerald)
                        Text("\(selectedAppNames.count) Apps Selected for Friction Shielding")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.ddTextPrimary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.ddBgSubtle)
                    .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 3: Self-Reported Time
    private var screen3TimeSpent: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DAILY SCREEN TIME")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("How much time on apps?")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 4)
            
            VStack(spacing: 10) {
                PremiumSelectCard(title: "< 1 Hour / Day", subtitle: "Light check-ins", isSelected: dailyHoursSpent == 1.0, action: { dailyHoursSpent = 1.0 })
                PremiumSelectCard(title: "1 – 2 Hours / Day", subtitle: "Moderate social usage", isSelected: dailyHoursSpent == 2.0, action: { dailyHoursSpent = 2.0 })
                PremiumSelectCard(title: "2 – 4 Hours / Day", subtitle: "Average user (High friction recommended)", isSelected: dailyHoursSpent == 3.5, action: { dailyHoursSpent = 3.5 })
                PremiumSelectCard(title: "5+ Hours / Day", subtitle: "Heavy doomscrolling (Urgent reset needed)", isSelected: dailyHoursSpent == 5.5, action: { dailyHoursSpent = 5.5 })
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 4: Lifetime Impact
    private var screen4LifetimeLoss: some View {
        let yearsLost = (dailyHoursSpent * 365.0 * 55.0) / (24.0 * 365.0)
        
        return VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("If nothing changed...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.ddTextSecondary)
                
                Text(String(format: "%.1f YEARS", yearsLost))
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.ddAccentRose, Color.ddAccentAmber],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.ddAccentRose.opacity(0.5), radius: 20)
                
                Text("could be spent scrolling these apps over your lifetime.")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.ddTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Text("Even a small 30-second pause creates massive lifelong freedom.")
                .font(.system(size: 13))
                .foregroundColor(Color.ddTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 5: The Impulse-Pause-Choose Model
    private var screen5TheReframe: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("THE REFRAME")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Don't Quit Your Apps.")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text("Just give yourself a better interruption.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.ddTextSecondary)
            }
            
            HStack(spacing: 6) {
                flowNode(title: "IMPULSE", subtitle: "Reflex", color: Color.ddAccentRose)
                Image(systemName: "arrow.right").font(.system(size: 11)).foregroundColor(Color.ddTextMuted)
                flowNode(title: "PAUSE", subtitle: "30s Reset", color: Color.ddAccentSky)
                Image(systemName: "arrow.right").font(.system(size: 11)).foregroundColor(Color.ddTextMuted)
                flowNode(title: "CHOOSE", subtitle: "Earned Pass", color: Color.ddAccentEmerald)
            }
            
            Text("By inserting 30s of intentional friction, 78% of mindless urge cycles dissolve naturally.")
                .font(.system(size: 13))
                .foregroundColor(Color.ddTextSecondary)
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
                .foregroundColor(Color.ddTextSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.ddBgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Screen 6: 9 Intervention Categories
    private var screen6InterventionStyles: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEURO-RESET MODES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Pick Your Reset Styles")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Select the types of friction you enjoy.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.ddTextSecondary)
            }
            .padding(.top, 4)
            
            ScrollView {
                VStack(spacing: 8) {
                    categoryToggleCard(id: "MOVE", emoji: "💪", title: "MOVE", desc: "Pushups, squats, physical movements")
                    categoryToggleCard(id: "BREATHE", emoji: "🫁", title: "BREATHE", desc: "Box breathing, 4-7-8 relaxation resets")
                    categoryToggleCard(id: "RESET", emoji: "🧘", title: "RESET", desc: "Mindfulness, sensory grounding, body scan")
                    categoryToggleCard(id: "MOBILITY", emoji: "🧘‍♂️", title: "MOBILITY", desc: "Child's pose, cobra stretch, cat-cow")
                    categoryToggleCard(id: "CREATE", emoji: "🎨", title: "CREATE", desc: "Zen Enso circle, scavenger hunt, haiku")
                    categoryToggleCard(id: "PERSPECTIVE", emoji: "🔮", title: "PERSPECTIVE", desc: "Stoic reflections, future-self capsule")
                    categoryToggleCard(id: "REFLECT", emoji: "🧠", title: "REFLECT", desc: "Stroop color clash, memory matrices")
                    categoryToggleCard(id: "STEP_AWAY", emoji: "💧", title: "STEP AWAY", desc: "Water hydration, 20-20-20 eye rest")
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func categoryToggleCard(id: String, emoji: String, title: String, desc: String) -> some View {
        let isSelected = selectedInterventionCategories.contains(id)
        return Button {
            if isSelected {
                selectedInterventionCategories.remove(id)
            } else {
                selectedInterventionCategories.insert(id)
            }
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 12) {
                Text(emoji).font(.system(size: 20))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddTextSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.ddAccentSky)
                }
            }
            .padding(12)
            .background(isSelected ? Color.ddBgSubtle : Color.ddBgCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.ddAccentSky : Color.ddBorderDefault, lineWidth: isSelected ? 1.5 : 1)
            )
        }
    }
    
    // MARK: - Screen 7: Interactive 3-Breath Trial
    private var screen7BreathingCalibration: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 6) {
                Text("FIRST MICRO-INTERVENTION")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Calibrate Your Focus")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text(isBreathTestDone ? "✨ Calibration complete!" : "Take 3 calming breaths with the pacer.")
                    .font(.system(size: 14))
                    .foregroundColor(isBreathTestDone ? Color.ddAccentEmerald : Color.ddTextSecondary)
            }
            
            BreathingPacerOrbView(
                phaseText: isBreathTestDone ? "COMPLETED (3/3)" : "\(breathPhase.uppercased()) (\(breathCount)/3)",
                secondsRemaining: max(0, 10 - (breathElapsedSeconds % 10))
            )
            
            if !isBreathTestDone {
                Button {
                    isBreathTestDone = true
                    breathTimer?.invalidate()
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Text("Skip Calibration (→ Continue)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.ddTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.ddBgSubtle)
                        .cornerRadius(20)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            startBreathingCycleTimer()
        }
    }
    
    private func startBreathingCycleTimer() {
        guard breathTimer == nil else { return }
        breathElapsedSeconds = 0
        breathCount = 1
        
        breathTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                breathElapsedSeconds += 1
                let cycleTime = breathElapsedSeconds % 10
                
                if cycleTime == 0 {
                    if breathCount < 3 {
                        breathCount += 1
                    } else {
                        isBreathTestDone = true
                        breathTimer?.invalidate()
                        HapticFeedbackManager.shared.workoutCompleted()
                    }
                }
                
                if cycleTime < 4 {
                    breathPhase = "Inhale"
                } else if cycleTime < 6 {
                    breathPhase = "Hold"
                } else {
                    breathPhase = "Exhale"
                }
            }
        }
    }
    
    // MARK: - Screen 8: Earned Screen Time Economy Rules
    private var screen8AccessTier: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EARNED ACCESS ECONOMY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                Text("Set Your Reward Duration")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("How many minutes of Instagram per friction reset?")
                    .font(.system(size: 13))
                    .foregroundColor(Color.ddTextSecondary)
            }
            .padding(.top, 4)
            
            VStack(spacing: 10) {
                PremiumSelectCard(
                    title: "5 Minutes (Strict & Fast)",
                    subtitle: "Quick message reply, stops deep rabbit holes.",
                    isSelected: selectedAccessTierMinutes == 5,
                    action: { selectedAccessTierMinutes = 5 }
                )
                
                PremiumSelectCard(
                    title: "10 Minutes (Balanced)",
                    subtitle: "Standard session for focused checking.",
                    isSelected: selectedAccessTierMinutes == 10,
                    action: { selectedAccessTierMinutes = 10 }
                )
                
                PremiumSelectCard(
                    title: "15 Minutes (Generous)",
                    subtitle: "Extended pass for long-form reading.",
                    isSelected: selectedAccessTierMinutes == 15,
                    action: { selectedAccessTierMinutes = 15 }
                )
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Screen 9: Permissions Handshake
    private var screen9Permissions: some View {
        VStack(spacing: 22) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundColor(Color.ddAccentSky)
            
            VStack(spacing: 8) {
                Text("Enable Focus Shield")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text("Enables intentional friction protection for your selected apps.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.ddTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 12) {
                Button {
                    Task {
                        await authManager.requestIndividualAuthorization()
                        isAuthHandshakeCompleted = true
                        HapticFeedbackManager.shared.buttonTap()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isAuthHandshakeCompleted ? "checkmark.circle.fill" : "shield.checkered")
                        Text(isAuthHandshakeCompleted ? "Friction Protection Active" : "Activate Protection Shield")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isAuthHandshakeCompleted ? Color.ddAccentEmerald : Color.ddAccentSky)
                    .cornerRadius(14)
                }
                
                if isAuthHandshakeCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.ddAccentEmerald)
                        Text("Autonomous Friction Shield Enabled.")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.ddAccentEmerald)
                    }
                }
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
                    .fill(Color.ddAccentEmerald.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: "bolt.badge.checkmark.fill")
                    .font(.system(size: 54))
                    .foregroundColor(Color.ddAccentEmerald)
            }
            
            VStack(spacing: 8) {
                Text("Your Plan Is Active!")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.ddTextPrimary)
                Text("You start with 0 minutes. Complete a friction challenge to earn your first \(selectedAccessTierMinutes)-minute focus pass.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.ddTextSecondary)
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
                        .background(Color.ddBgSubtle)
                        .cornerRadius(14)
                }
            }
            
            Button {
                if currentStep < 10 {
                    currentStep += 1
                    HapticFeedbackManager.shared.buttonTap()
                } else {
                    completeAndLaunch()
                }
            } label: {
                Text(currentStep == 0 ? "CONFIRM MODE" : (currentStep == 10 ? "Enter Dopamine Hub" : (currentStep == 4 ? "I WANT TO CHANGE THIS" : "Continue")))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.ddAccentSky, Color(hex: "0284C7")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
        }
    }
    
    private func completeAndLaunch() {
        ProfileTemplateManager.shared.applyPresetType(selectedProfileType)
        
        var profile = dataStore.activeProfile
        profile.temporaryUnlockMinutes = selectedAccessTierMinutes
        dataStore.activeProfile = profile
        dataStore.shieldedTargetAppNames = Array(selectedAppNames)
        
        wallet.availableSeconds = 0
        wallet.dailyEarnedSeconds = 0
        
        shieldManager.enforceShields()
        dataStore.completeOnboarding()
        HapticFeedbackManager.shared.workoutCompleted()
    }
}
