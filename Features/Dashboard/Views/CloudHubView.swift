import SwiftUI

/// Cloud Control Plane & Pairing Hub for Parent/Child workspace synchronization
public struct CloudHubView: View {
    @ObservedObject var pairingManager = PairingManager.shared
    @ObservedObject var syncManager = FirestoreSyncManager.shared
    @ObservedObject var authManager = FirebaseAuthManager.shared
    @ObservedObject var dataStore = SharedDataStore.shared
    
    @State private var enteredChildCode = ""
    @State private var emailInput = ""
    @State private var passwordInput = ""
    @State private var isSigningIn = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Auth Header / Mode Status
                        authStatusCard
                        
                        // Parent vs Child Mode Card
                        if pairingManager.isParentMode {
                            parentWorkspaceCard
                        } else {
                            childWorkspaceCard
                        }
                        
                        // Live Telemetry Event Feed
                        telemetryFeedCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Cloud Control Hub")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Auth Status Card
    private var authStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.primary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DisciplineTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("FIRESTORE CLOUD PLANE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text(authManager.currentUserEmail ?? "Cloud Synchronized")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(DisciplineTheme.success)
                        .frame(width: 8, height: 8)
                    Text("LIVE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.success)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DisciplineTheme.success.opacity(0.15))
                .cornerRadius(8)
            }
            
            // Mode Switcher Tabs
            HStack(spacing: 8) {
                Button {
                    pairingManager.isParentMode = true
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Text("Parent / Supervisor")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(pairingManager.isParentMode ? .white : DisciplineTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(pairingManager.isParentMode ? DisciplineTheme.primary : DisciplineTheme.surfaceSecondary)
                        .cornerRadius(10)
                }
                
                Button {
                    pairingManager.isParentMode = false
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Text("Child / Managed Device")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(!pairingManager.isParentMode ? .white : DisciplineTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(!pairingManager.isParentMode ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Parent Mode Card
    private var parentWorkspaceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FAMILY PAIRING CODE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.textSecondary)
                Text("Pair Supervised iPhone / iPad")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Enter this 6-character code on the child's device to bind it to your cloud policies.")
                .font(.system(size: 13))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            // Active Code Box
            HStack {
                Spacer()
                Text(pairingManager.activePairingCode ?? "GENERATE CODE")
                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                    .foregroundColor(DisciplineTheme.accent)
                    .tracking(6)
                Spacer()
            }
            .padding(.vertical, 20)
            .background(DisciplineTheme.surfaceSecondary.opacity(0.8))
            .cornerRadius(14)
            
            // Generate Code Button
            Button {
                let code = pairingManager.generatePairingCode(
                    familyId: "fam_prod_\(abs(authManager.currentUserId?.hashValue ?? 100))",
                    parentId: authManager.currentUserId ?? "parent_default"
                )
                HapticFeedbackManager.shared.repCompleted()
                print("Generated pairing code: \(code)")
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Generate New 15-Minute Code")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DisciplineTheme.primary)
                .cornerRadius(12)
            }
            
            // Push Live Policy to Firestore
            Button {
                Task {
                    await syncManager.pushPolicyToCloud(
                        familyId: pairingManager.linkedFamilyId ?? "fam_default",
                        childId: pairingManager.linkedChildId ?? "child_all",
                        profile: dataStore.activeProfile
                    )
                    HapticFeedbackManager.shared.workoutCompleted()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Push Current Policy to Managed Devices")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DisciplineTheme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DisciplineTheme.surfaceSecondary)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Child Mode Card
    private var childWorkspaceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CHILD DEVICE MANAGEMENT")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.textSecondary)
                Text(pairingManager.isPaired ? "Device Paired & Supervised" : "Pair with Parent Hub")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if pairingManager.isPaired {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(DisciplineTheme.success)
                        Text("Linked to Family: \(pairingManager.linkedFamilyId ?? "Active")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("This device is receiving live Screen Time and Shield policies from the parent control plane.")
                        .font(.system(size: 13))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DisciplineTheme.surfaceSecondary.opacity(0.5))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    TextField("ENTER 6-CHAR CODE", text: $enteredChildCode)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(DisciplineTheme.surfaceSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    if let err = pairingManager.pairingError {
                        Text(err)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DisciplineTheme.danger)
                    }
                    
                    Button {
                        Task {
                            _ = await pairingManager.redeemPairingCode(enteredChildCode)
                        }
                    } label: {
                        Text("Redeem Code & Pair Device")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DisciplineTheme.accent)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Telemetry Feed Card
    private var telemetryFeedCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DEVICE TELEMETRY & AUDIT")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text("Recent Real-Time Activity")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            if syncManager.recentTelemetryEvents.isEmpty {
                HStack {
                    Spacer()
                    Text("Telemetry stream active. Events will appear in real-time.")
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textTertiary)
                        .padding(.vertical, 12)
                    Spacer()
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(syncManager.recentTelemetryEvents) { event in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.eventType)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(DisciplineTheme.accent)
                                Text(event.timestamp)
                                    .font(.system(size: 10))
                                    .foregroundColor(DisciplineTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(DisciplineTheme.surfaceSecondary.opacity(0.4))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
}
