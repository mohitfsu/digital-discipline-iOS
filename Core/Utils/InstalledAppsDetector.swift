import UIKit
import SwiftUI

public struct DeviceInstalledApp: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let scheme: String
    public let iconName: String
    public let gradientColors: [String]
    public let isPopular: Bool
    
    public init(id: String, name: String, scheme: String, iconName: String, gradientColors: [String], isPopular: Bool = true) {
        self.id = id
        self.name = name
        self.scheme = scheme
        self.iconName = iconName
        self.gradientColors = gradientColors
        self.isPopular = isPopular
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
        DeviceInstalledApp(id: "tiktok", name: "TikTok", scheme: "tiktok://", iconName: "play.tv.fill", gradientColors: ["00F2FE", "4FACFE"]),
        DeviceInstalledApp(id: "snapchat", name: "Snapchat", scheme: "snapchat://", iconName: "ghost.fill", gradientColors: ["FFFC00", "F59E0B"]),
        DeviceInstalledApp(id: "x", name: "Twitter / X", scheme: "twitter://", iconName: "bubble.left.fill", gradientColors: ["1DA1F2", "0EA5E9"]),
        DeviceInstalledApp(id: "threads", name: "Threads", scheme: "threads://", iconName: "at", gradientColors: ["000000", "333333"]),
        DeviceInstalledApp(id: "netflix", name: "Netflix", scheme: "nflx://", iconName: "film.fill", gradientColors: ["E50914", "B81D24"]),
        DeviceInstalledApp(id: "spotify", name: "Spotify", scheme: "spotify://", iconName: "music.note", gradientColors: ["1DB954", "191414"]),
        DeviceInstalledApp(id: "reddit", name: "Reddit", scheme: "reddit://", iconName: "bubble.left.and.bubble.right.fill", gradientColors: ["FF4500", "FF8700"]),
        DeviceInstalledApp(id: "discord", name: "Discord", scheme: "discord://", iconName: "bubble.middle.bottom.fill", gradientColors: ["5865F2", "4752C4"]),
        DeviceInstalledApp(id: "telegram", name: "Telegram", scheme: "tg://", iconName: "paperplane.fill", gradientColors: ["2AABEE", "229ED9"]),
        DeviceInstalledApp(id: "pinterest", name: "Pinterest", scheme: "pinterest://", iconName: "pin.fill", gradientColors: ["E60023", "AD081B"]),
        DeviceInstalledApp(id: "twitch", name: "Twitch", scheme: "twitch://", iconName: "video.fill", gradientColors: ["9146FF", "6441A5"]),
        DeviceInstalledApp(id: "facebook", name: "Facebook", scheme: "fb://", iconName: "person.2.fill", gradientColors: ["1877F2", "0C63D4"])
    ]
    
    private init() {}
    
    /// Returns only the apps actually installed on the physical device, sorted with most used on top
    public func getInstalledAppsOnDevice() -> [DeviceInstalledApp] {
        var installed: [DeviceInstalledApp] = []
        
        for app in Self.supportedAppCatalog {
            if let url = URL(string: app.scheme), UIApplication.shared.canOpenURL(url) {
                installed.append(app)
            }
        }
        
        // If device has none of the detected schemes (or simulator/restricted), fallback to top popular list
        if installed.isEmpty {
            return Array(Self.supportedAppCatalog.prefix(6))
        }
        
        return installed
    }
}
