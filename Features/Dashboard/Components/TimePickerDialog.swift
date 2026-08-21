import SwiftUI

/// Dialog sheet for creating or editing time-window schedules
public struct TimePickerDialog: View {
    @Environment(\.dismiss) private var dismiss
    
    public let initialSchedule: ScheduleModel?
    public let onSave: (ScheduleModel) -> Void
    
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600 * 2)
    @State private var daysBitmask: Int = 0b0111110 // Mon-Fri default
    
    private let dayOptions: [(mask: Int, label: String)] = [
        (2, "M"), (4, "T"), (8, "W"), (16, "T"), (32, "F"), (64, "S"), (1, "S")
    ]
    
    public init(initialSchedule: ScheduleModel? = nil, onSave: @escaping (ScheduleModel) -> Void) {
        self.initialSchedule = initialSchedule
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SCHEDULE LABEL")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            TextField("e.g. Focus Session, Study Lock", text: $title)
                                .padding()
                                .background(DisciplineTheme.surface)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                                )
                        }
                        
                        // Start Time & End Time Pickers
                        VStack(spacing: 12) {
                            DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(.white)
                                .padding()
                                .background(DisciplineTheme.surface)
                                .cornerRadius(12)
                            
                            DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                                .foregroundColor(.white)
                                .padding()
                                .background(DisciplineTheme.surface)
                                .cornerRadius(12)
                        }
                        
                        // Active Days of Week
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ACTIVE DAYS")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                ForEach(dayOptions, id: \.mask) { day in
                                    let isSelected = (daysBitmask & day.mask) != 0
                                    Button {
                                        toggleDay(mask: day.mask)
                                    } label: {
                                        Text(day.label)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(isSelected ? .white : DisciplineTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(isSelected ? DisciplineTheme.primary : DisciplineTheme.surface)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Quick Day Presets
                        HStack(spacing: 10) {
                            Button("Weekdays") {
                                daysBitmask = 0b0111110
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DisciplineTheme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(DisciplineTheme.surface)
                            .cornerRadius(8)
                            
                            Button("Every Day") {
                                daysBitmask = 0b1111111
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DisciplineTheme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(DisciplineTheme.surface)
                            .cornerRadius(8)
                            
                            Button("Weekends") {
                                daysBitmask = 0b1000001
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DisciplineTheme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(DisciplineTheme.surface)
                            .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(initialSchedule == nil ? "New Schedule" : "Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSchedule()
                    }
                    .foregroundColor(DisciplineTheme.primary)
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || daysBitmask == 0)
                }
            }
        }
        .onAppear {
            if let sched = initialSchedule {
                title = sched.title
                daysBitmask = sched.daysOfWeekBitmask
                
                var startComp = DateComponents()
                startComp.hour = sched.startHour
                startComp.minute = sched.startMinute
                if let s = Calendar.current.date(from: startComp) {
                    startTime = s
                }
                
                var endComp = DateComponents()
                endComp.hour = sched.endHour
                endComp.minute = sched.endMinute
                if let e = Calendar.current.date(from: endComp) {
                    endTime = e
                }
            } else {
                title = "Focus Window"
            }
        }
    }
    
    private func toggleDay(mask: Int) {
        if (daysBitmask & mask) != 0 {
            daysBitmask &= ~mask
        } else {
            daysBitmask |= mask
        }
        HapticFeedbackManager.shared.buttonTap()
    }
    
    private func saveSchedule() {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let startMin = calendar.component(.minute, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let endMin = calendar.component(.minute, from: endTime)
        
        let newSchedule = ScheduleModel(
            id: initialSchedule?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            startHour: startHour,
            startMinute: startMin,
            endHour: endHour,
            endMinute: endMin,
            daysOfWeekBitmask: daysBitmask,
            isEnabled: initialSchedule?.isEnabled ?? true
        )
        
        onSave(newSchedule)
        HapticFeedbackManager.shared.repCompleted()
        dismiss()
    }
}
