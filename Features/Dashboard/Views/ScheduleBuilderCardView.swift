import SwiftUI

/// Schedule builder card for managing time windows and recurring intervals
public struct ScheduleBuilderCardView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @State private var showingAddSheet = false
    @State private var selectedScheduleToEdit: ScheduleModel?
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TIME WINDOW SCHEDULES")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text("Configured Intervals")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DisciplineTheme.primary)
                    .cornerRadius(10)
                }
            }
            
            // List of schedules
            if dataStore.activeProfile.schedules.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.system(size: 28))
                            .foregroundColor(DisciplineTheme.textTertiary)
                        Text("No active schedules")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(dataStore.activeProfile.schedules) { schedule in
                        scheduleRow(schedule)
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
        .sheet(isPresented: $showingAddSheet) {
            TimePickerDialog { newSchedule in
                dataStore.activeProfile.schedules.append(newSchedule)
                ScheduleActivityManager.shared.registerSchedules(dataStore.activeProfile.schedules)
            }
        }
        .sheet(item: $selectedScheduleToEdit) { schedule in
            TimePickerDialog(initialSchedule: schedule) { updated in
                if let index = dataStore.activeProfile.schedules.firstIndex(where: { $0.id == updated.id }) {
                    dataStore.activeProfile.schedules[index] = updated
                    ScheduleActivityManager.shared.registerSchedules(dataStore.activeProfile.schedules)
                }
            }
        }
    }
    
    private func scheduleRow(_ schedule: ScheduleModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(schedule.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    if schedule.isOvernight {
                        Text("OVERNIGHT")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(DisciplineTheme.warning)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DisciplineTheme.warning.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Text("\(schedule.formattedTimeSpan) • \(schedule.formattedDays)")
                    .font(.system(size: 12))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { newValue in
                    if let index = dataStore.activeProfile.schedules.firstIndex(where: { $0.id == schedule.id }) {
                        dataStore.activeProfile.schedules[index].isEnabled = newValue
                        ScheduleActivityManager.shared.registerSchedules(dataStore.activeProfile.schedules)
                        HapticFeedbackManager.shared.buttonTap()
                    }
                }
            ))
            .labelsHidden()
            .tint(DisciplineTheme.primary)
        }
        .padding(12)
        .background(DisciplineTheme.surfaceSecondary.opacity(0.6))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedScheduleToEdit = schedule
        }
    }
}
