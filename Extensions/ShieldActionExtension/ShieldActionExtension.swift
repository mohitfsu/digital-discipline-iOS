import Foundation
import ManagedSettings
import UIKit

/// Handles user actions on the system Shield screen with Dynamic Escalation and deep-link routing
public class ShieldActionExtension: ShieldActionDelegate {
    
    public override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // "⚡ Start 30s Physical Reset" or "Solve Brain Puzzle" tapped
            // Dispatches deep link opening the app directly to Dynamic Escalation / Workout Hub
            if let deepLinkURL = URL(string: "digitaldiscipline://exercise?action=escalated") {
                Task { @MainActor in
                    UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
                }
            }
            completionHandler(.deferToApplication)
            
        case .secondaryButtonPressed:
            // "Unlock with Parent PIN" tapped
            if let pinURL = URL(string: "digitaldiscipline://dashboard?action=pin") {
                Task { @MainActor in
                    UIApplication.shared.open(pinURL, options: [:], completionHandler: nil)
                }
            }
            completionHandler(.deferToApplication)
            
        @unknown default:
            completionHandler(.none)
        }
    }
    
    public override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        if action == .primaryButtonPressed {
            if let deepLinkURL = URL(string: "digitaldiscipline://exercise?action=escalated") {
                Task { @MainActor in
                    UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
                }
            }
            completionHandler(.deferToApplication)
        } else {
            completionHandler(.none)
        }
    }
    
    public override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        if action == .primaryButtonPressed {
            if let deepLinkURL = URL(string: "digitaldiscipline://exercise?action=escalated") {
                Task { @MainActor in
                    UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
                }
            }
            completionHandler(.deferToApplication)
        } else {
            completionHandler(.none)
        }
    }
}
