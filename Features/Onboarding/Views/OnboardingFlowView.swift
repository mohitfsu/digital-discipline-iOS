import SwiftUI
import FamilyControls

/// Interactive guided onboarding flow for selecting Persona, Apps, Interventions, and Unlock Durations
public struct OnboardingFlowView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    
    @State private var currentStep: Int = 0
    @State private var selectedProfileType: ProfileType = .selfDiscipline
    @State private var selectedIntervention: InterventionType = .pushUps
    @State private var selectedUnlockDuration: Int = 5 // 5 minutes default
    @State private var isActivityPickerPresented = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Progress Indicator
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                // Active Step Content
                TabView(selection: $currentStep) {
                    welcomeStepView.tag(0)
                    personaStepView.tag(1)
                    appsSelectionStepView.tag(2)
                    frictionConfigStepView.tag(3)
                    activationStepView.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                // Bottom Navigation Controls
                bottomActionBar
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
        HStack(spacing: 6) {
            ForEach(0..<5) { index in
                Capsule()
                    .fill(index <= currentStep ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
    }
    
    // MARK: - Step 0: Welcome View
    private var welcomeStepView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DisciplineTheme.primary.opacity(0.3), DisciplineTheme.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("Rewire Your Dopamine")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Transform mindless doomscrolling into mindful physical workouts, breathing resets, and cognitive focus sprints.")
                    .font(.system(size: 15))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Step 1: Persona Selection
    private var personaStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("STEP 1 OF 4")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Choose Your Purpose")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("Select the primary mode for your focus routine.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            VStack(spacing: 14) {
                personaCard(
                    type: .selfDiscipline,
                    title: "🧘 Self-Discipline Mode",
                    subtitle: "Personal focus: Replace Instagram/TikTok dopamine loops with 30s physical and mindful friction."
                )
                
                personaCard(
                    type: .parentChild,
                    title: "👨‍👩‍👧 Family & Parental Mode",
                    subtitle: "Manage a teen/child's device: PIN lockouts, strict anti-tamper, and educational resets."
                )
                
                personaCard(
                    type: .corporate,
                    title: "🏢 Workplace Deep Focus",
                    subtitle: "Lock distractions during work hours (9 AM - 5 PM) with optional GPS office geofencing."
                )
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func personaCard(type: ProfileType, title: String, subtitle: String) -> some View {
        let isSelected = (selectedProfileType == type)
        return Button {
            selectedProfileType = type
            ProfileTemplateManager.shared.applyPresetType(type)
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(16)
            .background(isSelected ? DisciplineTheme.surfaceSecondary.opacity(0.8) : DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    // MARK: - Step 2: App Selection
    private var appsSelectionStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("STEP 2 OF 4")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Select Distracting Apps")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("Pick the social media, gaming, or entertainment apps you want shielded.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            VStack(spacing: 16) {
                Button {
                    isActivityPickerPresented = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "plus.app.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DisciplineTheme.accent)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Open App Selector")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Select Instagram, TikTok, YouTube, X, Reddit...")
                                .font(.system(size: 12))
                                .foregroundColor(DisciplineTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(DisciplineTheme.textTertiary)
                    }
                    .padding(18)
                    .background(DisciplineTheme.surface)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(DisciplineTheme.accent.opacity(0.4), lineWidth: 1)
                    )
                }
                
                // Currently Selected Apps Badge
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "apps.iphone")
                            .foregroundColor(DisciplineTheme.accent)
                        Text("\(shieldManager.activitySelection.applicationTokens.count) Apps Chosen")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.gearshape")
                            .foregroundColor(DisciplineTheme.primary)
                        Text("\(shieldManager.activitySelection.categoryTokens.count) Categories")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(14)
                .background(DisciplineTheme.surfaceSecondary)
                .cornerRadius(14)
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    // MARK: - Step 3: Friction Configuration
    private var frictionConfigStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("STEP 3 OF 4")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("Choose Your Friction Reset")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("When you want to open Instagram, complete this reset for a temporary pass.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            .padding(.top, 12)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Reset Types Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        resetOptionTile(type: .pushUps, emoji: "💪", name: "10 Push-ups")
                        resetOptionTile(type: .squats, emoji: "🏋️", name: "10 Squats")
                        resetOptionTile(type: .boxBreathing, emoji: "🌬️", name: "30s Box Breath")
                        resetOptionTile(type: .zenCanvas, emoji: "🖌️", name: "Zen Enso Circle")
                        resetOptionTile(type: .mathSprint, emoji: "⚡", name: "Math Sprint")
                        resetOptionTile(type: .stroopTest, emoji: "🧠", name: "Stroop Test")
                    }
                    
                    // Temporary Unlock Pass Duration
                    VStack(alignment: .leading, spacing: 10) {
                        Text("UNLOCK PASS DURATION")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.textSecondary)
                        
                        HStack(spacing: 12) {
                            durationPill(minutes: 5)
                            durationPill(minutes: 10)
                            durationPill(minutes: 15)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func resetOptionTile(type: InterventionType, emoji: String, name: String) -> some View {
        let isSelected = (selectedIntervention == type)
        return Button {
            selectedIntervention = type
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DisciplineTheme.surfaceSecondary : DisciplineTheme.surface)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
    
    private func durationPill(minutes: Int) -> some View {
        let isSelected = (selectedUnlockDuration == minutes)
        return Button {
            selectedUnlockDuration = minutes
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            Text("\(minutes) Minutes")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? DisciplineTheme.accent : DisciplineTheme.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Step 4: Activation Step
    private var activationStepView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(DisciplineTheme.success.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 54))
                    .foregroundColor(DisciplineTheme.success)
            }
            
            VStack(spacing: 10) {
                Text("Ready to Activate Shield")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Your \(selectedProfileType.displayName) is configured. Tap below to enable permissions and start your disciplined digital routine.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            // Summary Card
            VStack(spacing: 8) {
                summaryLine(label: "Mode", value: selectedProfileType.displayName)
                summaryLine(label: "Shielded Apps", value: "\(shieldManager.activitySelection.applicationTokens.count) Apps")
                summaryLine(label: "Friction Reset", value: selectedIntervention.displayName)
                summaryLine(label: "Unlock Duration", value: "\(selectedUnlockDuration) Minutes")
            }
            .padding(16)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
            
            Spacer()
        }
        .padding(20)
    }
    
    private func summaryLine(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DisciplineTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        HStack(spacing: 14) {
            if currentStep > 0 {
                Button {
                    currentStep -= 1
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(DisciplineTheme.surfaceSecondary)
                        .cornerRadius(14)
                }
            }
            
            Button {
                if currentStep < 4 {
                    currentStep += 1
                    HapticFeedbackManager.shared.buttonTap()
                } else {
                    // Final Activation Action
                    activateAndCompleteOnboarding()
                }
            } label: {
                Text(currentStep == 4 ? "Arm Shield & Enter App" : (currentStep == 0 ? "Get Started" : "Continue"))
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
    
    private func activateAndCompleteOnboarding() {
        Task {
            // Request permissions
            await authManager.requestIndividualAuthorization()
            
            // Save configured profile
            var profile = dataStore.activeProfile
            profile.type = selectedProfileType
            profile.temporaryUnlockMinutes = selectedUnlockDuration
            dataStore.activeProfile = profile
            
            // Enforce shield
            shieldManager.enforceShields()
            
            // Complete onboarding
            dataStore.completeOnboarding()
            HapticFeedbackManager.shared.profileSwitched()
        }
    }
}
