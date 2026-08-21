import Foundation
import ManagedSettings

/// Handles user actions on the system Shield screen with Dynamic Escalation
public class ShieldActionExtension: ShieldActionDelegate {
    
    public init() {}
    
    public func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // "⚡ Start 30s Physical Reset" tapped -> Defers to main app to open Camera AI workout
            completionHandler(.deferToApplication)
            
        case .secondaryButtonPressed:
            // "Unlock with Parent PIN" tapped -> Defers to main app PIN modal
            completionHandler(.deferToApplication)
            
        @unknown default:
            completionHandler(.none)
        }
    }
    
    public func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        if action == .primaryButtonPressed || action == .secondaryButtonPressed {
            completionHandler(.deferToApplication)
        } else {
            completionHandler(.none)
        }
    }
    
    public func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        if action == .primaryButtonPressed || action == .secondaryButtonPressed {
            completionHandler(.deferToApplication)
        } else {
            completionHandler(.none)
        }
    }
}
