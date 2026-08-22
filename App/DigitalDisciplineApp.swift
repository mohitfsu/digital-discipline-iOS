import SwiftUI
import FamilyControls

@main
struct DigitalDisciplineApp: App {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var dataStore = SharedDataStore.shared
    @StateObject private var authManager = ScreenTimeAuthorizationManager.shared
    @StateObject private var shieldManager = ShieldManager.shared
    @StateObject private var geofenceMonitor = GeofenceMonitor.shared
    @StateObject private var wallet = EarnedTimeWallet.shared
    
    init() {
        AppGroupManager.shared.setupAppGroupEnvironment()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !dataStore.hasCompletedOnboarding {
                    Full11ScreenRewireOnboardingView()
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
                // Enforce background Screen Time shields automatically at the OS level
                shieldManager.enforceShields()
                geofenceMonitor.synchronizeGeofences()
                ScheduleActivityManager.shared.registerSchedules(dataStore.activeProfile.schedules)
                wallet.checkMidnightRollover()
            }
        }
    }
}
