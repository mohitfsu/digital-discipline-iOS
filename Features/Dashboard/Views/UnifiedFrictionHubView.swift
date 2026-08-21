import SwiftUI

/// Unified Intervention Hub offering all 42 Physical, Mindful, Cognitive, and Creative Resets with Dynamic Escalation
public struct UnifiedFrictionHubView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var escalationEngine = DynamicEscalationEngine.shared
    
    @State private var showingCatalogPicker = false
    @State private var selectedInterventionToRun: InterventionType?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Dynamic Escalation Status Card
                        dynamicEscalationCard
                        
                        // 42-Intervention Catalog Banner
                        catalogPickerBanner
                        
                        // Featured Category Quick Picks
                        featuredInterventionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Friction & Focus Hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingCatalogPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                            Text("All 42")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(DisciplineTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingCatalogPicker) {
                InterventionCatalogPickerView()
            }
            .fullScreenCover(item: $selectedInterventionToRun) { item in
                InterventionRunnerView(
                    intervention: item,
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
        }
    }
    
    // MARK: - Dynamic Escalation Card
    private var dynamicEscalationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DYNAMIC ESCALATION TIER")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                    Text(escalationEngine.currentEscalationLevelName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Attempt #\(escalationEngine.consecutiveAttemptCount)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(DisciplineTheme.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DisciplineTheme.warning.opacity(0.15))
                    .cornerRadius(8)
            }
            
            Text("Attempts escalate automatically: Level 1 (Mindful Pause) → Level 2 (Physical Movement) → Level 3 (Cognitive Focus).")
                .font(.system(size: 12))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            // Quick Launch Current Escalated Intervention
            Button {
                selectedInterventionToRun = escalationEngine.currentEscalationIntervention
                HapticFeedbackManager.shared.buttonTap()
            } label: {
                HStack(spacing: 12) {
                    Text(escalationEngine.currentEscalationIntervention.emoji)
                        .font(.system(size: 28))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LAUNCH ESCALATED RESET")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        Text(escalationEngine.currentEscalationIntervention.displayName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DisciplineTheme.accent)
                }
                .padding(14)
                .background(DisciplineTheme.surfaceSecondary)
                .cornerRadius(14)
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
    
    // MARK: - Catalog Picker Banner
    private var catalogPickerBanner: some View {
        Button {
            showingCatalogPicker = true
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [DisciplineTheme.primary, DisciplineTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("FULL 42-INTERVENTION CATALOG")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Calisthenics • Yoga • Stoic Wisdom • Puzzles • Creative AI")
                        .font(.system(size: 11))
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DisciplineTheme.accent)
            }
            .padding(14)
            .background(DisciplineTheme.surface)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DisciplineTheme.accent.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Featured Interventions Section
    private var featuredInterventionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FEATURED NEURO-RESET MODES")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featuredCard(type: .zenCanvas)
                featuredCard(type: .squats)
                featuredCard(type: .scavengerHunt)
                featuredCard(type: .stroopTest)
                featuredCard(type: .boxBreathing)
                featuredCard(type: .handMudra)
                featuredCard(type: .ambientSoundscape)
                featuredCard(type: .walk30Steps)
            }
        }
    }
    
    private func featuredCard(type: InterventionType) -> some View {
        Button {
            selectedInterventionToRun = type
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(type.emoji)
                        .font(.system(size: 26))
                    Spacer()
                    Text("#\(type.number)")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(type.category.themeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(type.category.themeColor.opacity(0.15))
                        .cornerRadius(4)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(type.targetValidation)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
        }
    }
}
