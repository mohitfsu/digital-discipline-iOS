import SwiftUI

/// Rewired-style Analytics & Discipline Insights Screen
public struct InsightsDashboardView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Hero Discipline Score Card
                        disciplineScoreCard
                        
                        // Habit Breakdown Grid
                        habitBreakdownSection
                        
                        // Recent Friction Activity
                        recentActivitySection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Discipline Insights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Discipline Score Card
    private var disciplineScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FOCUS STRENGTH SCORE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                    Text("Top 5% Disciplined")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.accent.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Text("\(max(10, 95 - (dataStore.dailyUnlockCount * 4)))")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(DisciplineTheme.accent)
                }
            }
            
            Divider()
                .background(DisciplineTheme.surfaceSecondary)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("🔥 7-DAY STREAK")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.warning)
                    Text("Clean Routine")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("⚡ INTERCEPTED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.danger)
                    Text("\(dataStore.blockAttemptsCount) Distractions")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(18)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Habit Breakdown Section
    private var habitBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NEURO-RESET BREAKDOWN")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricTile(title: "Squat Reps", value: "\(dataStore.totalSquatReps)", icon: "🏋️", color: DisciplineTheme.primary)
                metricTile(title: "Breathing Sessions", value: "\(dataStore.totalBreathingSessions)", icon: "🌬️", color: DisciplineTheme.accent)
                metricTile(title: "Mindful Pauses", value: "\(dataStore.dailyUnlockCount)", icon: "🪷", color: Color(hex: "A855F7"))
                metricTile(title: "Creative Resets", value: "\(max(1, dataStore.totalBreathingSessions / 2))", icon: "🎨", color: Color(hex: "EC4899"))
            }
        }
    }
    
    private func metricTile(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(icon)
                .font(.system(size: 26))
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DisciplineTheme.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DisciplineTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S FRICTION TIMELINE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(DisciplineTheme.textSecondary)
            
            VStack(spacing: 10) {
                timelineRow(title: "Instagram Shielded", subtitle: "Physical squat friction required", time: "Just now", icon: "shield.fill", color: DisciplineTheme.danger)
                timelineRow(title: "Box Breathing Completed", subtitle: "4-4-4-4 autonomic cycle", time: "25m ago", icon: "wind", color: DisciplineTheme.accent)
                timelineRow(title: "Corporate Schedule Activated", subtitle: "Office perimeter geofence match", time: "9:00 AM", icon: "briefcase.fill", color: DisciplineTheme.primary)
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
    
    private func timelineRow(title: String, subtitle: String, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(DisciplineTheme.textTertiary)
        }
    }
}
