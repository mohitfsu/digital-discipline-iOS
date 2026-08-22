import SwiftUI

/// Rewired-style Schedules & Geofencing Management Screen
public struct SchedulesAndZonesView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Schedules Section
                        ScheduleBuilderCardView()
                        
                        // Geofence Zones Section
                        GeofenceBuilderCardView()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Schedules & Zones")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
