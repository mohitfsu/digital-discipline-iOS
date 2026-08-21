import SwiftUI
import CoreLocation

/// Geofence builder card with location fixes and perimeter management
public struct GeofenceBuilderCardView: View {
    @ObservedObject var dataStore = SharedDataStore.shared
    @ObservedObject var locationManager = LocationManager.shared
    
    @State private var showingAddZone = false
    @State private var newZoneName = "My Focus Zone"
    @State private var selectedPreset = GeofencePreset.office
    @State private var zoneRadius: Double = 150.0
    @State private var targetLatitude: Double = 37.7749
    @State private var targetLongitude: Double = -122.4194
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LOCATION & GEOFENCING")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    Text("Workplace & Campus Zones")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    showingAddZone = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add Zone")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DisciplineTheme.accent)
                    .cornerRadius(10)
                }
            }
            
            // Geofence List
            VStack(spacing: 10) {
                ForEach(dataStore.geofences) { zone in
                    geofenceRow(zone)
                }
            }
        }
        .padding(16)
        .background(DisciplineTheme.surface)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
        .sheet(isPresented: $showingAddZone) {
            addZoneSheet
        }
    }
    
    private func geofenceRow(_ zone: GeofenceZone) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(zone.preset.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(Int(zone.radiusMeters))m Radius")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(DisciplineTheme.accent.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Text("Triggers: \(zone.assignedProfileType.displayName)")
                    .font(.system(size: 12))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { zone.isEnabled },
                set: { newValue in
                    if let index = dataStore.geofences.firstIndex(where: { $0.id == zone.id }) {
                        dataStore.geofences[index].isEnabled = newValue
                        GeofenceMonitor.shared.synchronizeGeofences()
                        HapticFeedbackManager.shared.buttonTap()
                    }
                }
            ))
            .labelsHidden()
            .tint(DisciplineTheme.accent)
        }
        .padding(12)
        .background(DisciplineTheme.surfaceSecondary.opacity(0.6))
        .cornerRadius(12)
    }
    
    private var addZoneSheet: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Preset Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SELECT PRESET")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(GeofencePreset.allCases) { preset in
                                    let isSelected = selectedPreset == preset
                                    Button {
                                        selectedPreset = preset
                                        zoneRadius = preset.defaultRadius
                                        newZoneName = preset.rawValue.capitalized
                                    } label: {
                                        Text(preset.title)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(isSelected ? .white : DisciplineTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(isSelected ? DisciplineTheme.primary : DisciplineTheme.surface)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Zone Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ZONE NAME")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            TextField("e.g. Headquarters Campus", text: $newZoneName)
                                .padding()
                                .background(DisciplineTheme.surface)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // 1-Tap "Use Current Location"
                        Button {
                            locationManager.requestCurrentLocation()
                            if let loc = locationManager.currentLocation {
                                targetLatitude = loc.coordinate.latitude
                                targetLongitude = loc.coordinate.longitude
                                HapticFeedbackManager.shared.repCompleted()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(locationManager.isLocating ? "Acquiring GPS..." : "📍 Use Current GPS Location")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DisciplineTheme.surfaceSecondary)
                            .cornerRadius(12)
                        }
                        
                        // Coordinates Display
                        HStack {
                            Text("Lat: \(String(format: "%.4f", targetLatitude)), Lng: \(String(format: "%.4f", targetLongitude))")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            Spacer()
                        }
                        
                        // Radius Slider (50m to 1000m)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("GEOFENCE RADIUS")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(DisciplineTheme.textSecondary)
                                Spacer()
                                Text("\(Int(zoneRadius)) meters")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(DisciplineTheme.accent)
                            }
                            
                            Slider(value: $zoneRadius, in: 50...1000, step: 25)
                                .tint(DisciplineTheme.accent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Geofence Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddZone = false }
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Zone") {
                        saveNewZone()
                    }
                    .foregroundColor(DisciplineTheme.primary)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveNewZone() {
        let zone = GeofenceZone(
            name: newZoneName,
            latitude: targetLatitude,
            longitude: targetLongitude,
            radiusMeters: zoneRadius,
            preset: selectedPreset,
            assignedProfileType: selectedPreset.defaultProfile,
            isEnabled: true
        )
        dataStore.geofences.append(zone)
        GeofenceMonitor.shared.synchronizeGeofences()
        HapticFeedbackManager.shared.repCompleted()
        showingAddZone = false
    }
}
