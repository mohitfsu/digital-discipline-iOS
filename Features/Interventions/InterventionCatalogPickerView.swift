import SwiftUI

/// Full 35-Intervention Catalog Picker with search, category filtering, and 1-tap test execution
public struct InterventionCatalogPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataStore = SharedDataStore.shared
    
    @State private var searchText = ""
    @State private var selectedCategory: InterventionCategory?
    @State private var activeInterventionToRun: InterventionType?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DisciplineTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Search Bar
                        searchBar
                        
                        // Category Horizontal Chips
                        categoryChips
                        
                        // Count Header
                        HStack {
                            Text("\(filteredInterventions.count) INTERVENTIONS AVAILABLE")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(DisciplineTheme.textSecondary)
                            Spacer()
                        }
                        
                        // Interventions List
                        LazyVStack(spacing: 12) {
                            ForEach(filteredInterventions) { item in
                                interventionRow(item)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Intervention Catalog (35)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
            .fullScreenCover(item: $activeInterventionToRun) { item in
                InterventionRunnerView(
                    intervention: item,
                    unlockDurationMinutes: dataStore.activeProfile.temporaryUnlockMinutes
                )
            }
        }
    }
    
    private var filteredInterventions: [InterventionType] {
        InterventionType.allCases.filter { item in
            let matchesCategory = selectedCategory == nil || item.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                item.displayName.localizedCaseInsensitiveContains(searchText) ||
                item.mechanismDescription.localizedCaseInsensitiveContains(searchText) ||
                item.targetValidation.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DisciplineTheme.textSecondary)
            TextField("Search 35 interventions...", text: $searchText)
                .foregroundColor(.white)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DisciplineTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(DisciplineTheme.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
        )
    }
    
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedCategory = nil
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Text("All (35)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(selectedCategory == nil ? .white : DisciplineTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? DisciplineTheme.primary : DisciplineTheme.surfaceSecondary)
                        .cornerRadius(10)
                }
                
                ForEach(InterventionCategory.allCases) { cat in
                    let isSelected = selectedCategory == cat
                    Button {
                        selectedCategory = cat
                        HapticFeedbackManager.shared.buttonTap()
                    } label: {
                        HStack(spacing: 4) {
                            Text(cat.rawValue)
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? .white : DisciplineTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? cat.themeColor : DisciplineTheme.surfaceSecondary)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private func interventionRow(_ item: InterventionType) -> some View {
        Button {
            activeInterventionToRun = item
            HapticFeedbackManager.shared.buttonTap()
        } label: {
            HStack(spacing: 14) {
                // Number & Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.category.themeColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text(item.emoji)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("#\(item.number)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(item.category.themeColor)
                        
                        Text(item.displayName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(item.targetValidation)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.textSecondary)
                    
                    Text(item.mechanismDescription)
                        .font(.system(size: 11))
                        .foregroundColor(DisciplineTheme.textTertiary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(item.category.themeColor)
            }
            .padding(14)
            .background(DisciplineTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
            )
        }
    }
}
