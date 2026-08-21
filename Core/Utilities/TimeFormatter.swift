import Foundation

/// Utility for formatting dates, time windows, durations, and day-of-week bitmasks
public struct TimeFormatter: Sendable {
    
    private static let timeDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let iso8601Formatter = ISO8601DateFormatter()
    
    public static func formatTime(hour: Int, minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            return timeDisplayFormatter.string(from: date)
        }
        return String(format: "%02d:%02d", hour, minute)
    }
    
    public static func formatDuration(seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        let remainingSec = seconds % 60
        if remainingSec == 0 {
            return "\(minutes)m"
        }
        return "\(minutes)m \(remainingSec)s"
    }
    
    public static func formatDuration(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) mins"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours) hr\(hours > 1 ? "s" : "")"
        }
        return "\(hours)h \(mins)m"
    }
    
    public static func formatDaysOfWeek(bitmask: Int) -> String {
        // Bit 1 = Sun, 2 = Mon, 4 = Tue, 8 = Wed, 16 = Thu, 32 = Fri, 64 = Sat
        if bitmask == 0b1111111 {
            return "Every Day"
        }
        if bitmask == 0b0111110 {
            return "Mon – Fri (Weekdays)"
        }
        if bitmask == 0b1000001 {
            return "Sat – Sun (Weekends)"
        }
        
        let days = [
            (1, "Sun"), (2, "Mon"), (4, "Tue"), (8, "Wed"),
            (16, "Thu"), (32, "Fri"), (64, "Sat")
        ]
        let active = days.filter { (bitmask & $0.0) != 0 }.map { $0.1 }
        if active.isEmpty {
            return "None"
        }
        return active.joined(separator: ", ")
    }
    
    public static func currentIso8601() -> String {
        return iso8601Formatter.string(from: Date())
    }
}
