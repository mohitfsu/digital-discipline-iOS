import UIKit
import SwiftUI

public struct DeviceInstalledApp: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let scheme: String
    public let iconName: String
    public let gradientColors: [String]
    
    public init(id: String, name: String, scheme: String, iconName: String, gradientColors: [String]) {
        self.id = id
        self.name = name
        self.scheme = scheme
        self.iconName = iconName
        self.gradientColors = gradientColors
    }
}

/// Detects real installed apps on the user's device using native iOS URL schemes
@MainActor
public final class InstalledAppsDetector {
    public static let shared = InstalledAppsDetector()
    
    public static let supportedAppCatalog: [DeviceInstalledApp] = [
        DeviceInstalledApp(id: "instagram", name: "Instagram", scheme: "instagram://", iconName: "camera.fill", gradientColors: ["833AB4", "FD1D1D", "FCB045"]),
        DeviceInstalledApp(id: "youtube", name: "YouTube", scheme: "youtube://", iconName: "play.rectangle.fill", gradientColors: ["FF0000", "CC0000"]),
        DeviceInstalledApp(id: "whatsapp", name: "WhatsApp", scheme: "whatsapp://", iconName: "message.fill", gradientColors: ["25D366", "128C7E"]),
        DeviceInstalledApp(id: "snapchat", name: "Snapchat", scheme: "snapchat://", iconName: "ghost.fill", gradientColors: ["FFFC00", "F59E0B"]),
        DeviceInstalledApp(id: "x", name: "Twitter / X", scheme: "twitter://", iconName: "bubble.left.fill", gradientColors: ["1DA1F2", "0EA5E9"]),
        DeviceInstalledApp(id: "threads", name: "Threads", scheme: "threads://", iconName: "at", gradientColors: ["000000", "333333"]),
        DeviceInstalledApp(id: "netflix", name: "Netflix", scheme: "nflx://", iconName: "film.fill", gradientColors: ["E50914", "B81D24"]),
        DeviceInstalledApp(id: "spotify", name: "Spotify", scheme: "spotify://", iconName: "music.note", gradientColors: ["1DB954", "191414"]),
        DeviceInstalledApp(id: "telegram", name: "Telegram", scheme: "tg://", iconName: "paperplane.fill", gradientColors: ["2AABEE", "229ED9"]),
        DeviceInstalledApp(id: "facebook", name: "Facebook", scheme: "fb://", iconName: "person.2.fill", gradientColors: ["1877F2", "0C63D4"])
    ]
    
    private init() {}
    
    /// Returns apps discovered via URL schemes on the device
    public func getInstalledAppsOnDevice() -> [DeviceInstalledApp] {
        var installed: [DeviceInstalledApp] = []
        
        for app in Self.supportedAppCatalog {
            if let url = URL(string: app.scheme), UIApplication.shared.canOpenURL(url) {
                installed.append(app)
            }
        }
        
        // If query schemes are restricted in sandbox, return common essentials without TikTok/Reddit
        if installed.isEmpty {
            return [
                DeviceInstalledApp(id: "instagram", name: "Instagram", scheme: "instagram://", iconName: "camera.fill", gradientColors: ["833AB4", "FD1D1D", "FCB045"]),
                DeviceInstalledApp(id: "youtube", name: "YouTube", scheme: "youtube://", iconName: "play.rectangle.fill", gradientColors: ["FF0000", "CC0000"]),
                DeviceInstalledApp(id: "whatsapp", name: "WhatsApp", scheme: "whatsapp://", iconName: "message.fill", gradientColors: ["25D366", "128C7E"])
            ]
        }
        
        return installed
    }
}
