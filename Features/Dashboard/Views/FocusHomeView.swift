import SwiftUI
import FamilyControls

/// Rewired/Opal-style Hero Focus Screen with central status dial, session controls, and quick profile switcher
public struct FocusHomeView: View {
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    
    @State private var isPickerPresented = false
    @State private var showingUnlockConfirmation = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Profile Bar
                        headerProfileBar
                        
                        // Hero Focus Status Dial
                        heroFocusDial
                        
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
            .navigationTitle("Focus Shield")
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
                .frame(width: 260, height: 260)
                .blur(radius: 20)
            
            // Outer Track
            Circle()
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 16)
                .frame(width: 220, height: 220)
            
            // Active Progress Ring
            Circle()
                .trim(from: 0, to: shieldManager.isShieldCurrentlyActive ? 1.0 : 0.0)
                .stroke(
                    LinearGradient(
                        colors: [DisciplineTheme.primary, DisciplineTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: shieldManager.isShieldCurrentlyActive)
            
            // Center Information
            VStack(spacing: 8) {
                Image(systemName: shieldManager.isShieldCurrentlyActive ? "shield.fill" : "shield.slash")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.accent : DisciplineTheme.textSecondary)
                
                Text(shieldManager.isShieldCurrentlyActive ? "PROTECTED" : "UNSHIELDED")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                if dataStore.isTemporaryUnlockActive() {
                    Text("\(dataStore.remainingUnlockSeconds() / 60)m Remaining")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                } else {
                    Text("\(shieldManager.activitySelection.applicationTokens.count) Apps Blocked")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
        }
        .padding(.vertical, 16)
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
                    .font(.system(size: 16, weight: .bold))
                Text(shieldManager.isShieldCurrentlyActive ? "Pause Focus Shield" : "Activate Focus Shield")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                shieldManager.isShieldCurrentlyActive ?
                LinearGradient(colors: [Color(hex: "334155"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom) :
                LinearGradient(colors: [DisciplineTheme.primary, Color(hex: "0284C7")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .shadow(color: shieldManager.isShieldCurrentlyActive ? Color.clear : DisciplineTheme.primary.opacity(0.35), radius: 12, y: 4)
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
