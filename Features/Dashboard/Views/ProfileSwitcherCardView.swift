import SwiftUI

/// Profile switcher card allowing 1-tap persona switching
public struct ProfileSwitcherCardView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var templateManager = ProfileTemplateManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ACTIVE POLICY PROFILE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text(dataStore.activeProfile.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(dataStore.activeProfile.type.themeColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: dataStore.activeProfile.type.iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(dataStore.activeProfile.type.themeColor)
                }
            }
            
            Text(dataStore.activeProfile.description)
                .font(.system(size: 13))
                .foregroundColor(DisciplineTheme.textSecondary)
                .lineLimit(2)
            
            // Profile Selector Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ProfileType.allCases) { type in
                        let isSelected = dataStore.activeProfile.type == type
                        Button {
                            templateManager.applyPresetType(type)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: type.iconName)
                                    .font(.system(size: 14))
                                Text(type.displayName)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(isSelected ? .white : DisciplineTheme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? type.themeColor : DisciplineTheme.surfaceSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? type.themeColor : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            // Quick Rules Summary
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "figure.cross.training")
                        .foregroundColor(DisciplineTheme.accent)
                    Text("\(dataStore.activeProfile.requiredSquatReps) Reps to Unlock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .foregroundColor(DisciplineTheme.warning)
                    Text("\(dataStore.activeProfile.temporaryUnlockMinutes)m Duration")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                if dataStore.activeProfile.isStrictAntiTamperEnabled {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(DisciplineTheme.danger)
                        Text("Anti-Uninstall")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DisciplineTheme.danger)
                    }
                }
            }
            .padding(.top, 4)
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
