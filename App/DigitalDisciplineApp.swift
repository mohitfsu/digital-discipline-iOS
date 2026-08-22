import SwiftUI
import FamilyControls

@main
struct DigitalDisciplineApp: App {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var dataStore = SharedDataStore.shared
    @StateObject private var authManager = ScreenTimeAuthorizationManager.shared
    @StateObject private var geofenceMonitor = GeofenceMonitor.shared
    
    init() {
        AppGroupManager.shared.setupAppGroupEnvironment()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !dataStore.hasCompletedOnboarding {
                    OnboardingFlowView()
                        .transition(.opacity)
                } else {
                    MainAppTabView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.4), value: dataStore.hasCompletedOnboarding)
            .onOpenURL { url in
                router.handleDeepLink(url: url)
            }
            .fullScreenCover(isPresented: $router.isWorkoutPresented) {
                InterventionRunnerView(
                    intervention: router.activeIntervention,
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
            .task {
                // Initialize background services safely after UI mounts
                geofenceMonitor.synchronizeGeofences()
                ScheduleActivityManager.shared.registerSchedules(dataStore.activeProfile.schedules)
            }
        }
    }
}
