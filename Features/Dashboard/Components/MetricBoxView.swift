import SwiftUI

/// Glassmorphic metric card displaying telemetry indicators
public struct MetricBoxView: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let iconName: String
    public let accentColor: Color
    
    public init(
        title: String,
        value: String,
        subtitle: String,
        iconName: String,
        accentColor: Color = DisciplineTheme.primary
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.accentColor = accentColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(DisciplineTheme.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(DisciplineTheme.textPrimary)
            
            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DisciplineTheme.textTertiary)
                .lineLimit(1)
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
