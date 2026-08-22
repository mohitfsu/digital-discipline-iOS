import SwiftUI
import FamilyControls

/// Master Dark OLED TodayScreen & Daily Friction Dashboard
public struct FocusHomeView: View {
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var isWorkoutModalPresented = false
    @State private var isUrgeModalPresented = false
    @State private var isZenEnsoPresented = false
    @State private var isShortcutsGuidePresented = false
    @State private var selectedInterventionToRun: InterventionType = .pushUps
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.ddBgDeep.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 22) {
                        // Top Bar: User Profile, Streak Counter (🔥 7 Days), Mode
                        topStatusBar
                        
                        // Hero Card: TimeDialProgressView + Quick Earn Action Pill
                        heroTimeDialCard
                        
                        // 🔥 Viral "I AM HAVING AN URGE" Panic Button
                        urgeSurfingHeroButton
                        
                        // ⚡ Instant App Trap Setup Card (Shortcuts Automation)
                        shortcutsAutomationSetupCard
                        
                        // Active Temporary Pass Countdown (if unlocked)
                        if dataStore.isTemporaryUnlockActive() {
                            activeTemporaryPassCard
                        } else {
                            quickFrictionUnlockCard
                        }
                        
                        // Shield Control Action (Enforced / Protected status)
                        shieldStatusBanner
                        
                        // Daily Summary Metrics
                        metricsSummaryRow
                        
                        // Target Shielded Apps with Real Icons
                        shieldedAppsGrid
                        
                        // Intervention Categories & Quick Resets
                        interventionCategoryExplorer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isWorkoutModalPresented) {
                InterventionRunnerView(
                    intervention: selectedInterventionToRun,
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
            .fullScreenCover(isPresented: $isUrgeModalPresented) {
                UrgeSurfingModalView()
            }
            .fullScreenCover(isPresented: $isZenEnsoPresented) {
                ZenEnsoCanvasView(
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
            .sheet(isPresented: $isShortcutsGuidePresented) {
                ShortcutsAutomationGuideView()
            }
        }
    }
    
    // MARK: - Top Status Bar
    private var topStatusBar: some View {
        HStack(spacing: 12) {
            // Mode Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.ddAccentEmerald)
                    .frame(width: 8, height: 8)
                Text(dataStore.activeProfile.name.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.ddBgSubtle)
            .cornerRadius(20)
            
            Spacer()
            
            // 🔥 Streak Badge
            HStack(spacing: 4) {
                Text("🔥")
                Text("7 Days")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.ddAccentAmber)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.ddBgSubtle)
            .cornerRadius(20)
        }
    }
    
    // MARK: - Hero Time Dial Card
    private var heroTimeDialCard: some View {
        VStack(spacing: 18) {
            TimeDialProgressView(
                availableSeconds: wallet.availableSeconds,
                maxSeconds: 3600,
                isSessionActive: dataStore.isTemporaryUnlockActive()
            )
            
            // Quick Action Pill: + Earn 5 Mins Now
            Button {
                selectedInterventionToRun = .pushUps
                isWorkoutModalPresented = true
                HapticFeedbackManager.shared.buttonTap()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("+ Earn \(dataStore.activeProfile.temporaryUnlockMinutes) Mins Now")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.ddAccentSky, Color(hex: "0284C7")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.ddAccentSkyGlow.opacity(0.35), radius: 8)
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Viral Urge Surfing Button
    private var urgeSurfingHeroButton: some View {
        Button {
            isUrgeModalPresented = true
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.ddAccentAmber)
                        .frame(width: 44, height: 44)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("I AM HAVING AN URGE")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Ride the 60s craving wave $\\rightarrow$ Earn +5m Pass")
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddAccentAmber)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(14)
            .background(Color.ddBgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ddAccentAmber.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: Color.ddAccentAmber.opacity(0.15), radius: 10)
        }
    }
    
    // MARK: - Shortcuts Automation Setup Card (One Sec Style)
    private var shortcutsAutomationSetupCard: some View {
        Button {
            isShortcutsGuidePresented = true
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.ddAccentSky.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "bolt.badge.automatic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.ddAccentSky)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-Trap Instagram Opens")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text("Intercept Instagram opening $\\rightarrow$ Require 30s reset")
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddTextSecondary)
                }
                
                Spacer()
                
                Text("Setup")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.ddAccentSky)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.ddBgSubtle)
                    .cornerRadius(8)
            }
            .padding(12)
            .background(Color.ddBgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.ddAccentSky.opacity(0.4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Active Temporary Pass Card
    private var activeTemporaryPassCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FOCUS PASS ACTIVE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.ddAccentAmber)
                    Text("\(dataStore.remainingUnlockSeconds() / 60)m \(dataStore.remainingUnlockSeconds() % 60)s Remaining")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                }
                Spacer()
                
                Button {
                    dataStore.revokeTemporaryUnlock()
                    shieldManager.enforceShields()
                } label: {
                    Text("Re-Lock Now")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.ddAccentRose)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.ddAccentRose.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            
            Button {
                if let url = URL(string: "instagram://") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.square.fill")
                    Text("Launch Instagram Now")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "E1306C"), Color(hex: "F77737")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(14)
        .background(Color.ddBgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.ddAccentAmber.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Quick Friction Unlock Card
    private var quickFrictionUnlockCard: some View {
        Button {
            selectedInterventionToRun = .pushUps
            isWorkoutModalPresented = true
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "E1306C"), Color(hex: "F77737")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Need to Open Instagram?")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text("Do 10 Push-ups / 30s Reset $\\rightarrow$ Earn \(dataStore.activeProfile.temporaryUnlockMinutes)m Pass")
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.ddAccentSky)
            }
            .padding(14)
            .background(Color.ddBgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ddBorderDefault, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Shield Status Banner
    private var shieldStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.fill")
                .foregroundColor(Color.ddAccentEmerald)
            Text("PROTECTED • \(dataStore.shieldedTargetAppNames.count) Apps Shielded")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.ddTextPrimary)
            Spacer()
            Text("ACTIVE")
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(Color.ddAccentEmerald)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.ddAccentEmerald.opacity(0.15))
                .cornerRadius(6)
        }
        .padding(12)
        .background(Color.ddBgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Metrics Summary Row
    private var metricsSummaryRow: some View {
        HStack(spacing: 10) {
            metricCard(title: "BLOCKS", value: "\(dataStore.blockAttemptsCount)", icon: "hand.raised.fill", color: Color.ddAccentRose)
            metricCard(title: "RESETS", value: "\(dataStore.totalSquatReps + dataStore.totalBreathingSessions)", icon: "flame.fill", color: Color.ddAccentAmber)
            metricCard(title: "SCORE", value: "\(max(0, 100 - (dataStore.dailyUnlockCount * 5)))", icon: "bolt.fill", color: Color.ddAccentSky)
        }
    }
    
    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.ddTextPrimary)
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ddBgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Shielded Apps Grid
    private var shieldedAppsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SHIELDED TARGET APPS")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dataStore.shieldedTargetAppNames, id: \.self) { appName in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.ddAccentSky.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: appIconName(for: appName))
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.ddAccentSky)
                                )
                            Text(appName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.ddTextPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.ddBgCard)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.ddBorderDefault, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private func appIconName(for name: String) -> String {
        switch name {
        case "Instagram": return "camera.fill"
        case "TikTok": return "play.tv.fill"
        case "YouTube": return "play.rectangle.fill"
        case "Twitter / X": return "message.fill"
        case "Reddit": return "bubble.left.fill"
        case "Snapchat": return "ghost.fill"
        case "Netflix": return "film.fill"
        default: return "app.fill"
        }
    }
    
    // MARK: - Intervention Category Explorer
    private var interventionCategoryExplorer: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("43 ACTIVE NEURO-CHALLENGES")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextSecondary)
            
            VStack(spacing: 8) {
                challengeRow(
                    emoji: "🏋️",
                    title: "10 AI Push-ups",
                    desc: "Vision AI form & chest-to-ground tracking",
                    badge: "+5 Mins",
                    action: {
                        selectedInterventionToRun = .pushUps
                        isWorkoutModalPresented = true
                    }
                )
                
                challengeRow(
                    emoji: "🧘",
                    title: "30s Balasana Child's Pose",
                    desc: "Instant pause anti-cheat fold hold",
                    badge: "+5 Mins",
                    action: {
                        selectedInterventionToRun = .childPose
                        isWorkoutModalPresented = true
                    }
                )
                
                challengeRow(
                    emoji: "🎨",
                    title: "Zen Enso Circle",
                    desc: "Continuous single-stroke mindfulness canvas",
                    badge: "+5 Mins",
                    action: {
                        isZenEnsoPresented = true
                    }
                )
                
                challengeRow(
                    emoji: "🫁",
                    title: "4-7-8 Deep Sleep & Calm",
                    desc: "4s Inhale • 7s Hold • 8s Exhale cycle",
                    badge: "+5 Mins",
                    action: {
                        selectedInterventionToRun = .boxBreathing
                        isWorkoutModalPresented = true
                    }
                )
            }
        }
    }
    
    private func challengeRow(emoji: String, title: String, desc: String, badge: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticFeedbackManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 12) {
                Text(emoji).font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddTextSecondary)
                }
                Spacer()
                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.ddAccentSky)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.ddAccentSky.opacity(0.15))
                    .cornerRadius(6)
            }
            .padding(14)
            .background(Color.ddBgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.ddBorderDefault, lineWidth: 1)
            )
        }
    }
}

/// One Sec-style Shortcuts Automation Guide View
public struct ShortcutsAutomationGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        ZStack {
            Color.ddBgDeep.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Auto-Trap Instagram")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.ddTextSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    guideStepRow(step: "1", title: "Open Apple 'Shortcuts' App", desc: "Tap the 'Automation' tab at the bottom.")
                    guideStepRow(step: "2", title: "Create Personal Automation", desc: "Select 'App' $\\rightarrow$ Choose 'Instagram' $\\rightarrow$ Is Opened.")
                    guideStepRow(step: "3", title: "Add 'Open App' Action", desc: "Choose 'Open Digital Discipline' $\\rightarrow$ Turn OFF 'Ask Before Running'.")
                }
                .padding(16)
                .background(Color.ddBgCard)
                .cornerRadius(16)
                
                Button {
                    if let url = URL(string: "shortcuts://") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    dismiss()
                } label: {
                    Text("Open Shortcuts App Now")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.ddAccentSky)
                        .cornerRadius(14)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    private func guideStepRow(step: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(step)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color.ddAccentSky)
                .frame(width: 24, height: 24)
                .background(Color.ddAccentSky.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.ddTextPrimary)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(Color.ddTextSecondary)
            }
        }
    }
}
