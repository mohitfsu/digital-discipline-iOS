import Foundation
import DeviceActivity

/// Schedules time-window background monitors via Apple's DeviceActivity framework
public final class ScheduleActivityManager: @unchecked Sendable {
    public static let shared = ScheduleActivityManager()
    
    private let center = DeviceActivityCenter()
    
    private init() {}
    
    /// Synchronizes and registers all active schedules with DeviceActivityCenter
    public func registerSchedules(_ schedules: [ScheduleModel]) {
        // Stop any previous active monitoring schedules
        stopAllMonitoring()
        
        for schedule in schedules where schedule.isEnabled {
            let activityName = DeviceActivityName("digitaldiscipline.schedule.\(schedule.id)")
            
            var startComponents = DateComponents()
            startComponents.hour = schedule.startHour
            startComponents.minute = schedule.startMinute
            
            var endComponents = DateComponents()
            endComponents.hour = schedule.endHour
            endComponents.minute = schedule.endMinute
            
            let deviceSchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: true,
                warningTime: DateComponents(minute: 5)
            )
            
            do {
                try center.startMonitoring(activityName, during: deviceSchedule)
                print("Successfully registered DeviceActivity schedule: \(schedule.title) (\(schedule.formattedTimeSpan))")
            } catch {
                print("Failed to start monitoring schedule \(schedule.title): \(error)")
            }
        }
    }
    
    /// Stops all registered background schedules
    public func stopAllMonitoring() {
        center.stopMonitoring()
    }
    
    /// Checks if a schedule name is currently being monitored
    public func isMonitoring(activityName: DeviceActivityName) -> Bool {
        return center.activities.contains(activityName)
    }
}
