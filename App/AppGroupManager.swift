import Foundation

/// Coordinates initialization and synchronicity across the App Group container
public final class AppGroupManager: Sendable {
    public static let shared = AppGroupManager()
    
    public var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppStorageKeys.appGroupName)
    }
    
    private init() {}
    
    /// Initializes base App Group storage directories if needed
    public func setupAppGroupEnvironment() {
        guard let url = sharedContainerURL else {
            print("Warning: App Group container URL is nil. Check App Groups capability in Xcode.")
            return
        }
        
        let logsDirectory = url.appendingPathComponent("Logs", isDirectory: true)
        if !FileManager.default.fileExists(atPath: logsDirectory.path) {
            try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        }
    }
}
