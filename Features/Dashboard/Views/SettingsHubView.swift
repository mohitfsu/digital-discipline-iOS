import SwiftUI

/// Settings & Security Management Screen
public struct SettingsHubView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    @ObservedObject var shieldManager = ShieldManager.shared
    
    @State private var isPinDialogOpen = false
    @State private var isCloudHubOpen = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Permissions Status Section
                        permissionsSection
                        
                        // Security & Anti-Tamper Section
                        securitySection
                        
                        // Cloud Pairing Hub Link
                        cloudSection
                        
                        // About Card
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings & Security")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPinDialogOpen) {
                PinVerificationDialog {
                    // PIN verified action
                }
            }
            .sheet(isPresented: $isCloudHubOpen) {
                CloudHubView()
            }
        }
    }
    
    // MARK: - Permissions Section
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERMISSIONS & SYSTEM INTEGRATION")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "hourglass.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(DisciplineTheme.accent)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Screen Time Access")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(authManager.isAuthorized ? "Authorized • Shielding Active" : "Permission Required for App Blocking")
                            .font(.system(size: 11))
                            .foregroundColor(authManager.isAuthorized ? DisciplineTheme.success : DisciplineTheme.warning)
                    }
                    
                    Spacer()
                    
                    if !authManager.isAuthorized {
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
                }
                .padding(14)
                
                Divider()
                    .background(DisciplineTheme.surfaceSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DisciplineTheme.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Camera AI (Vision)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("On-device Pose & Object Detection")
                            .font(.system(size: 11))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DisciplineTheme.success)
                }
                .padding(14)
            }
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SECURITY & HARD LOCKOUT")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            VStack(spacing: 0) {
                // Anti-Uninstall Lockout Toggle
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DisciplineTheme.danger)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Anti-Uninstall & Tamper Lock")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Prevents app deletion and date/time modification")
                            .font(.system(size: 11))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { dataStore.isAntiTamperEnabled },
                        set: { newValue in
                            dataStore.setAntiTamperEnabled(newValue)
                            shieldManager.applyAntiTamperPolicies(enabled: newValue)
                            HapticFeedbackManager.shared.buttonTap()
                        }
                    ))
                    .labelsHidden()
                    .tint(DisciplineTheme.danger)
                }
                .padding(14)
                
                Divider()
                    .background(DisciplineTheme.surfaceSecondary)
                
                // Parent PIN Lockout Configuration
                Button {
                    isPinDialogOpen = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DisciplineTheme.warning)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Parent Security PIN")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Require 6-digit PIN to modify profiles")
                                .font(.system(size: 11))
                                .foregroundColor(DisciplineTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DisciplineTheme.textTertiary)
                    }
                    .padding(14)
                }
            }
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Cloud Section
    private var cloudSection: some View {
        Button {
            isCloudHubOpen = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.accent.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 18))
                        .foregroundColor(DisciplineTheme.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cloud Pairing Hub")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Pair devices via Firestore telemetry sync")
                        .font(.system(size: 11))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DisciplineTheme.textTertiary)
            }
            .padding(14)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: 12) {
            Button {
                dataStore.resetOnboarding()
                HapticFeedbackManager.shared.buttonTap()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Re-run Guided Setup Flow")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(DisciplineTheme.accent)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(DisciplineTheme.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
            }
            
            Text("Digital Discipline v1.0.0 (Native Swift 6)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textTertiary)
            Text("Apple Screen Time & Vision AI Powered • 42 Interventions")
                .font(.system(size: 10))
                .foregroundColor(DisciplineTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }
}
