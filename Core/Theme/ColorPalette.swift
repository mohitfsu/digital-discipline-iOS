import SwiftUI

/// Defines the enterprise-grade dark theme color palette for Digital Discipline
public enum DisciplineTheme {
    /// Background base: #090D16
    public static let background = Color(hex: "090D16")
    
    /// Elevated card surface: #0F172A
    public static let surface = Color(hex: "0F172A")
    
    /// Secondary card surface / stroke: #1E293B
    public static let surfaceSecondary = Color(hex: "1E293B")
    
    /// Primary brand blue: #0284C7
    public static let primary = Color(hex: "0284C7")
    
    /// Sky blue accent: #38BDF8
    public static let accent = Color(hex: "38BDF8")
    
    /// Success emerald: #10B981
    public static let success = Color(hex: "10B981")
    
    /// Danger / Lockout Red: #EF4444
    public static let danger = Color(hex: "EF4444")
    
    /// Warning amber: #F59E0B
    public static let warning = Color(hex: "F59E0B")
    
    /// Text primary: Pure White
    public static let textPrimary = Color.white
    
    /// Text secondary: Slate 400 (#94A3B8)
    public static let textSecondary = Color(hex: "94A3B8")
    
    /// Text tertiary: Slate 500 (#64748B)
    public static let textTertiary = Color(hex: "64748B")
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
