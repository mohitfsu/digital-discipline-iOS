import SwiftUI
import Combine

public enum AppDestination: Hashable, Sendable {
    case dashboard
    case workout(type: InterventionType)
    case cloudHub
    case scheduleBuilder
    case geofences
    case catalog
}

/// Central routing engine for deep links and UI navigation
@MainActor
public final class NavigationRouter: ObservableObject {
    public static let shared = NavigationRouter()
    
    @Published public var currentDestination: AppDestination = .dashboard
    @Published public var isWorkoutPresented: Bool = false
    @Published public var activeIntervention: InterventionType = .boxBreathing
    
    private init() {}
    
    /// Parses incoming system and Shield deep links (e.g. `digitaldiscipline://exercise?action=escalated`)
    public func handleDeepLink(url: URL) {
        guard let scheme = url.scheme, scheme.lowercased() == "digitaldiscipline" else {
            return
        }
        
        let host = url.host?.lowercased() ?? ""
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let action = components?.queryItems?.first(where: { $0.name == "action" })?.value
        
        switch host {
        case "exercise":
            if action == "escalated" {
                // Record distraction attempt and fetch escalated tier intervention
                let escalated = DynamicEscalationEngine.shared.recordDistractionAttemptAndGetIntervention()
                self.activeIntervention = escalated
            } else if let act = action, let matched = InterventionType(rawValue: act.uppercased()) {
                self.activeIntervention = matched
            } else {
                self.activeIntervention = .squats
            }
            self.isWorkoutPresented = true
            
        case "catalog":
            self.currentDestination = .catalog
            
        case "cloud":
            self.currentDestination = .cloudHub
            
        case "schedules":
            self.currentDestination = .scheduleBuilder
            
        default:
            self.currentDestination = .dashboard
        }
    }
}
