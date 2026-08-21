import SwiftUI
import FamilyControls

/// Master Dashboard and Control Plane for Digital Discipline
public struct ParentDashboardView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var templateManager = ProfileTemplateManager.shared
    
    @State private var showingFrictionHub = false
    @State private var showingPinDialog = false
    @State private var showingCloudHub = false
    @State private var pendingProtectedAction: (() -> Void)?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Top Status & Screen Time Authorization Banner
                        statusBanner
                        
                        // Prominent Physical & Cognitive Friction Reset CTA
                        frictionResetCTA
                        
                        // 4-Column Live Metric Boxes
                        metricsGrid
                        
                        // Profile Switcher Card
                        ProfileSwitcherCardView()
                        
                        // Apple Managed Settings App Selector
                        AppSelectorCardView()
                        
                        // Time Window Schedule Builder
                        ScheduleBuilderCardView()
                        
                        // Geofence Perimeters Builder
                        GeofenceBuilderCardView()
                    }
                    .padding()
                }
            }
            .navigationTitle("Digital Discipline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingCloudHub = true
                    } label: {
                        Image(systemName: "icloud.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DisciplineTheme.accent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPinDialog = true
                    } label: {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DisciplineTheme.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingFrictionHub) {
            UnifiedFrictionHubView()
        }
        .sheet(isPresented: $showingCloudHub) {
            CloudHubView()
        }
        .sheet(isPresented: $showingPinDialog) {
            PinVerificationDialog {
                pendingProtectedAction?()
                pendingProtectedAction = nil
            }
        }
        .onAppear {
            authManager.updateStatus()
        }
    }
    
    // MARK: - Status Banner
    private var statusBanner: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.danger : DisciplineTheme.success)
                        .frame(width: 10, height: 10)
                    
                    Text(shieldManager.isShieldCurrentlyActive ? "OS SHIELDS ENFORCED" : "UNRESTRICTED WINDOW")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.danger : DisciplineTheme.success)
                }
                
                Spacer()
                
                if dataStore.isTemporaryUnlockActive() {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text("\(dataStore.remainingUnlockSeconds() / 60)m Left")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DisciplineTheme.warning.opacity(0.15))
                    .cornerRadius(8)
                }
            }
            
            // Authorization warning if Screen Time permission not granted
            if !authManager.isAuthorized {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Screen Time Permission Required")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("Grant FamilyControls authorization to enforce OS-level app shields.")
                            .font(.system(size: 11))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    Spacer()
                    Button("Authorize") {
                        Task {
                            await authManager.requestIndividualAuthorization()
                        }
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DisciplineTheme.primary)
                    .cornerRadius(8)
                }
                .padding(10)
                .background(DisciplineTheme.primary.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Physical & Cognitive Friction CTA
    private var frictionResetCTA: some View {
        Button {
            showingFrictionHub = true
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [DisciplineTheme.primary, DisciplineTheme.warning], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DOPAMINE RESET HUB")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Vision AI Workouts • Stroop Test • Memory Matrix • Math")
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DisciplineTheme.accent)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [DisciplineTheme.surfaceSecondary, DisciplineTheme.surface],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(DisciplineTheme.primary.opacity(0.4), lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Metrics Grid
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricBoxView(
                title: "Squat Reps",
                value: "\(dataStore.totalSquatReps)",
                subtitle: "Vision AI Verified",
                iconName: "figure.cross.training",
                accentColor: DisciplineTheme.accent
            )
            
            MetricBoxView(
                title: "Blocks Prevented",
                value: "\(dataStore.blockAttemptsCount)",
                subtitle: "Shield Interceptions",
                iconName: "shield.checkered",
                accentColor: DisciplineTheme.danger
            )
            
            MetricBoxView(
                title: "Resets & Puzzles",
                value: "\(dataStore.totalBreathingSessions)",
                subtitle: "Brain Tasks Done",
                iconName: "brain.head.profile",
                accentColor: DisciplineTheme.success
            )
            
            MetricBoxView(
                title: "Active Zones",
                value: "\(dataStore.geofences.filter { $0.isEnabled }.count)",
                subtitle: "Geofences Monitored",
                iconName: "location.north.circle.fill",
                accentColor: DisciplineTheme.warning
            )
        }
    }
}
