import SwiftUI
import FamilyControls

/// App Selector & OS-level Shield Controller Card
public struct AppSelectorCardView: View {
    @ObservedObject var shieldManager = ShieldManager.shared
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var authManager = ScreenTimeAuthorizationManager.shared
    
    @State private var isPickerPresented = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("APPLE MANAGED SETTINGS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text("OS-Level App Shielding")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.danger.opacity(0.2) : DisciplineTheme.surfaceSecondary)
                        .frame(width: 40, height: 40)
                    Image(systemName: shieldManager.isShieldCurrentlyActive ? "shield.fill" : "shield.slash")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.danger : DisciplineTheme.textSecondary)
                }
            }
            
            // Shield Metrics Grid
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(shieldManager.activitySelection.applicationTokens.count)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("APPS BLOCKED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DisciplineTheme.surfaceSecondary.opacity(0.6))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(shieldManager.activitySelection.categoryTokens.count)")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("CATEGORIES")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DisciplineTheme.surfaceSecondary.opacity(0.6))
                .cornerRadius(12)
            }
            
            // Anti-Tamper Toggle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(DisciplineTheme.danger)
                        Text("Anti-Uninstall & Tamper Lock")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Blocks app removal, date tampering, and account signouts.")
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
            .padding(12)
            .background(DisciplineTheme.surfaceSecondary.opacity(0.4))
            .cornerRadius(12)
            
            // Action Buttons
            HStack(spacing: 10) {
                Button {
                    isPickerPresented = true
                } label: {
                    HStack {
                        Image(systemName: "plus.app.fill")
                        Text("Select Apps")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(DisciplineTheme.primary)
                    .cornerRadius(12)
                }
                
                Button {
                    if shieldManager.isShieldCurrentlyActive {
                        shieldManager.clearShields()
                    } else {
                        shieldManager.enforceShields()
                    }
                    HapticFeedbackManager.shared.profileSwitched()
                } label: {
                    HStack {
                        Image(systemName: shieldManager.isShieldCurrentlyActive ? "lock.open.fill" : "lock.fill")
                        Text(shieldManager.isShieldCurrentlyActive ? "Lift Shield" : "Enforce Shield")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(shieldManager.isShieldCurrentlyActive ? DisciplineTheme.surfaceSecondary : DisciplineTheme.danger)
                    .cornerRadius(12)
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
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $shieldManager.activitySelection
        )
    }
}
