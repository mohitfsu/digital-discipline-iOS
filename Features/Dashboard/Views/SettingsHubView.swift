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
                Color.ddBgDeep.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Permissions & Shielding Status
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
            Text("PROTECTION & SYSTEM INTEGRATION")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextSecondary)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.ddAccentEmerald)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Focus Shield Protection")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.ddTextPrimary)
                        Text("Active • \(dataStore.shieldedTargetAppNames.count) Apps Protected with Friction")
                            .font(.system(size: 11))
                            .foregroundColor(Color.ddAccentEmerald)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.ddAccentEmerald)
                }
                .padding(14)
                
                Divider()
                    .background(Color.ddBgSubtle)
                
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.ddAccentSky)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Camera AI (Vision)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.ddTextPrimary)
                        Text("On-device Pose & Rep Counter Engine")
                            .font(.system(size: 11))
                            .foregroundColor(Color.ddTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.ddAccentEmerald)
                }
                .padding(14)
            }
            .background(Color.ddBgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ddBorderDefault, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SECURITY & HARD LOCKOUT")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextSecondary)
            
            VStack(spacing: 0) {
                // Anti-Uninstall Lockout Toggle
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.ddAccentRose)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Anti-Uninstall & Tamper Lock")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.ddTextPrimary)
                        Text("Prevents app deletion and date/time modification")
                            .font(.system(size: 11))
                            .foregroundColor(Color.ddTextSecondary)
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
                    .tint(Color.ddAccentRose)
                }
                .padding(14)
                
                Divider()
                    .background(Color.ddBgSubtle)
                
                // Parent PIN Lockout Configuration
                Button {
                    isPinDialogOpen = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.ddAccentAmber)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Parent Security PIN")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.ddTextPrimary)
                            Text("Require 6-digit PIN to modify policies")
                                .font(.system(size: 11))
                                .foregroundColor(Color.ddTextSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.ddTextMuted)
                    }
                    .padding(14)
                }
            }
            .background(Color.ddBgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.ddBorderDefault, lineWidth: 1)
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
                        .fill(Color.ddAccentSky.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.ddAccentSky)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cloud Pairing Hub")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.ddTextPrimary)
                    Text("Pair devices via Firestore telemetry sync")
                        .font(.system(size: 11))
                        .foregroundColor(Color.ddTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.ddTextMuted)
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
                .foregroundColor(Color.ddAccentSky)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.ddBgCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ddBorderDefault, lineWidth: 1)
                )
            }
            
            Text("Digital Discipline v1.0.0 (Native Swift 6)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.ddTextMuted)
            Text("Apple Vision AI Powered • 42 Interventions")
                .font(.system(size: 10))
                .foregroundColor(Color.ddTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }
}
