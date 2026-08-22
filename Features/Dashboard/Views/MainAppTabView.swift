import SwiftUI

/// Master Rewired-style Tab View routing between the 5 primary experiences
public struct MainAppTabView: View {
    @State private var selectedTab: TabItem = .focus
    
    public enum TabItem: Hashable {
        case focus
        case resets
        case schedules
        case insights
        case settings
    }
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            FocusHomeView()
                .tabItem {
                    Label("Focus", systemImage: "shield.fill")
                }
                .tag(TabItem.focus)
            
            UnifiedFrictionHubView()
                .tabItem {
                    Label("Resets", systemImage: "bolt.heart.fill")
                }
                .tag(TabItem.resets)
            
            SchedulesAndZonesView()
                .tabItem {
                    Label("Schedules", systemImage: "calendar.badge.clock")
                }
                .tag(TabItem.schedules)
            
            InsightsDashboardView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(TabItem.insights)
            
            SettingsHubView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(TabItem.settings)
        }
        .tint(DisciplineTheme.accent)
    }
}
