import UIKit
import ManagedSettings
import ManagedSettingsUI

/// Customizes the system Shield screen with dark-mode styling and physical reset calls to action
public class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    public override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? "This Application"
        return makeShieldConfig(
            title: "DIGITAL DISCIPLINE ACTIVE",
            subtitle: "\(appName) is shielded by policy. Reclaim your focus or earn screen time with a physical reset."
        )
    }
    
    public override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domain = webDomain.domain ?? "This Website"
        return makeShieldConfig(
            title: "DOMAIN SHIELDED",
            subtitle: "\(domain) is blocked during your focus window. Complete a physical reset to unlock."
        )
    }
    
    public override func configuration(shielding category: ActivityCategory) -> ShieldConfiguration {
        let categoryName = category.localizedDisplayName ?? "This Category"
        return makeShieldConfig(
            title: "CATEGORY RESTRICTED",
            subtitle: "\(categoryName) apps are currently locked by your active Digital Discipline policy."
        )
    }
    
    private func makeShieldConfig(title: String, subtitle: String) -> ShieldConfiguration {
        let darkBg = UIColor(red: 9.0/255.0, green: 13.0/255.0, blue: 22.0/255.0, alpha: 1.0)
        let primaryColor = UIColor(red: 2.0/255.0, green: 132.0/255.0, blue: 199.0/255.0, alpha: 1.0)
        let secondaryColor = UIColor(red: 148.0/255.0, green: 163.0/255.0, blue: 184.0/255.0, alpha: 1.0)
        
        return ShieldConfiguration(
            backgroundColor: darkBg,
            title: ShieldConfiguration.Label(
                text: title,
                color: primaryColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitle,
                color: UIColor.lightGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "⚡ Start 30s Physical Reset",
                color: UIColor.white
            ),
            primaryButtonBackgroundColor: primaryColor,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with Parent PIN",
                color: secondaryColor
            )
        )
    }
}
