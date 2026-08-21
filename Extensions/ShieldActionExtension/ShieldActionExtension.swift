import Foundation
import ManagedSettings

/// Handles user actions on the system Shield screen with Dynamic Escalation
public class ShieldActionExtension: ShieldActionDelegate {
    
    public override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.deferToApplication)
    }
    
    public override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.deferToApplication)
    }
    
    public override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(.deferToApplication)
    }
}
