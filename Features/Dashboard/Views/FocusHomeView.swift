import SwiftUI
import FamilyControls

/// Rewired/Opal-style Hero Focus Screen with central status dial, Dopamine Wallet, and Urge Surfing
public struct FocusHomeView: View {
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var wallet = EarnedTimeWallet.shared
    
    @State private var isPickerPresented = false
    @State private var isWorkoutModalPresented = false
    @State private var isUrgeModalPresented = false
    @State private var selectedInterventionToRun: InterventionType = .pushUps
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Profile Bar
                        headerProfileBar
                        
                        // Hero Focus Status Dial
                        heroFocusDial
                        
                        // 🔥 Viral "I AM HAVING AN URGE" Panic Button
                        urgeSurfingHeroButton
                        
                        // 💰 Earned Dopamine Wallet Card
                        dopamineWalletCard
                        
                        // Active Temporary Pass Banner (if unlocked)
                        if dataStore.isTemporaryUnlockActive() {
                            activeTemporaryPassCard
                        } else {
                            // Quick 5-Min Pass Action Card
                            quickFrictionUnlockCard
                        }
                        
                        // Action / Shield Controller
                        shieldControlActions
                        
                        // Stats Overview Row
                        statsOverviewRow
                        
                        // Shielded Apps Mini Grid
                        shieldedAppsSummaryCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Dopamine & Focus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPickerPresented = true
                    } label: {
                        Image(systemName: "plus.app")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DisciplineTheme.accent)
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $shieldManager.activitySelection
            )
            .fullScreenCover(isPresented: $isWorkoutModalPresented) {
                InterventionRunnerView(
                    intervention: selectedInterventionToRun,
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
            .fullScreenCover(isPresented: $isUrgeModalPresented) {
                UrgeSurfingModalView()
            }
        }
    }
    
    // MARK: - Header Profile Bar
    private var headerProfileBar: some View {
        HStack(spacing: 12) {
            Image(systemName: dataStore.activeProfile.type.iconName)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DisciplineTheme.accent)
                .padding(8)
                .background(DisciplineTheme.accent.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(dataStore.activeProfile.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(shieldManager.isShieldCurrentlyActive ? "Shielding Active • Friction Required" : "Ready to Focus")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Spacer()
            
            NavigationLink {
                ProfileSwitcherCardView()
                    .padding()
                    .background(DisciplineTheme.background)
            } label: {
                Text("Switch")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DisciplineTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DisciplineTheme.surfaceSecondary)
                    .cornerRadius(20)
            }
        }
        .padding(12)
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
    }
    
    // MARK: - Hero Focus Dial
    private var heroFocusDial: some View {
        ZStack {
            // Outer Glow
            Circle()
                .fill(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.primary.opacity(0.15) : Color.white.opacity(0.03))
                .frame(width: 240, height: 240)
                .blur(radius: 20)
            
            // Outer Track
            Circle()
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 14)
                .frame(width: 200, height: 200)
            
            // Active Progress Ring
            Circle()
                .trim(from: 0, to: shieldManager.isShieldCurrentlyActive ? 1.0 : 0.0)
                .stroke(
                    LinearGradient(
                        colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: shieldManager.isShieldCurrentlyActive)
            
            // Center Information
            VStack(spacing: 6) {
                Image(systemName: shieldManager.isShieldCurrentlyActive ? "shield.fill" : "shield.slash")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.accent : DisciplineTheme.textSecondary)
                
                Text(shieldManager.isShieldCurrentlyActive ? "PROTECTED" : "UNSHIELDED")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                if dataStore.isTemporaryUnlockActive() {
                    Text("\(dataStore.remainingUnlockSeconds() / 60)m Remaining")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                } else {
                    Text("\(shieldManager.activitySelection.applicationTokens.count) Apps Blocked")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
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
                        .fill(Color(hex: "F97316"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("I AM HAVING AN URGE")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Ride the 60s craving wave $\\rightarrow$ Earn +500 XP & +5m Pass")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "FDBA74"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color(hex: "C2410C"), Color(hex: "EA580C")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "EA580C").opacity(0.4), radius: 10, y: 3)
        }
    }
    
    // MARK: - Dopamine Wallet Card
    private var dopamineWalletCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EARNED TIME WALLET")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                Text("\(wallet.availableMinutes) MIN AVAILABLE")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Daily Earn Cap: \(wallet.dailyEarnedSeconds / 60)/60 min")
                    .font(.system(size: 11))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(DisciplineTheme.accent.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "banknote.fill")
                    .font(.system(size: 22))
                    .foregroundColor(DisciplineTheme.accent)
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Active Temporary Pass Card
    private var activeTemporaryPassCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PASS ACTIVE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                    Text("\(dataStore.remainingUnlockSeconds() / 60)m \(dataStore.remainingUnlockSeconds() % 60)s Remaining")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                
                Button {
                    dataStore.revokeTemporaryUnlock()
                    shieldManager.enforceShields()
                } label: {
                    Text("Re-Lock Now")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(DisciplineTheme.danger)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DisciplineTheme.danger.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            
            // Open Instagram / Apps Button
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
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DisciplineTheme.warning.opacity(0.4), lineWidth: 1)
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
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Do 10 Push-ups / 30s Reset $\\rightarrow$ Earn \(dataStore.activeProfile.temporaryUnlockMinutes)m Pass")
                        .font(.system(size: 11))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DisciplineTheme.accent)
            }
            .padding(14)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.accent.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Shield Control Actions
    private var shieldControlActions: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if shieldManager.isShieldCurrentlyActive {
                    shieldManager.clearShields()
                } else {
                    shieldManager.enforceShields()
                }
            }
            HapticFeedbackManager.shared.profileSwitched()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: shieldManager.isShieldCurrentlyActive ? "pause.fill" : "lock.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(shieldManager.isShieldCurrentlyActive ? "Pause Focus Shield" : "Activate Focus Shield")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                shieldManager.isShieldCurrentlyActive ?
                LinearGradient(colors: [Color(hex: "334155"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [DisciplineTheme.primary, Color(hex: "0284C7")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(14)
            .shadow(color: shieldManager.isShieldCurrentlyActive ? Color.clear : DisciplineTheme.primary.opacity(0.35), radius: 10, y: 4)
        }
    }
    
    // MARK: - Stats Overview Row
    private var statsOverviewRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "BLOCKS TODAY",
                value: "\(dataStore.blockAttemptsCount)",
                icon: "hand.raised.fill",
                color: DisciplineTheme.danger
            )
            
            statCard(
                title: "RESETS DONE",
                value: "\(dataStore.totalSquatReps + dataStore.totalBreathingSessions)",
                icon: "flame.fill",
                color: DisciplineTheme.warning
            )
            
            statCard(
                title: "DISCIPLINE",
                value: "\(max(0, 100 - (dataStore.dailyUnlockCount * 5)))%",
                icon: "bolt.fill",
                color: DisciplineTheme.accent
            )
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DisciplineTheme.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Shielded Apps Summary Card
    private var shieldedAppsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SHIELDED TARGETS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.textSecondary)
                
                Spacer()
                
                Button {
                    isPickerPresented = true
                } label: {
                    Text("Edit Apps")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            
            if shieldManager.activitySelection.applicationTokens.isEmpty && shieldManager.activitySelection.categoryTokens.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 24))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Apps Selected")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("Tap 'Edit Apps' to block YouTube, Instagram, or TikTok.")
                            .font(.system(size: 11))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                }
                .padding(.vertical, 6)
            } else {
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "app.badge.checkmark.fill")
                            .foregroundColor(DisciplineTheme.success)
                        Text("\(shieldManager.activitySelection.applicationTokens.count) Apps")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.gearshape")
                            .foregroundColor(DisciplineTheme.accent)
                        Text("\(shieldManager.activitySelection.categoryTokens.count) Categories")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
}
