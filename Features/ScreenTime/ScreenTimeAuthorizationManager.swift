import Foundation
import UIKit
import FamilyControls
import Combine

/// Authorization manager for Apple's Screen Time FamilyControls framework
@MainActor
public final class ScreenTimeAuthorizationManager: ObservableObject {
    public static let shared = ScreenTimeAuthorizationManager()
    
    @Published public var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published public var isAuthorized: Bool = false
    @Published public var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        updateStatus()
        observeAuthorizationCenter()
    }
    
    public func updateStatus() {
        #if targetEnvironment(simulator)
        self.authorizationStatus = .approved
        self.isAuthorized = true
        #else
        self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        self.isAuthorized = (AuthorizationCenter.shared.authorizationStatus == .approved)
        #endif
    }
    
    private func observeAuthorizationCenter() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.updateStatus()
            }
            .store(in: &cancellables)
    }
    
    /// Requests Screen Time authorization for Individual usage
    public func requestIndividualAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            updateStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Screen Time Authorization: \(error.localizedDescription)"
            updateStatus()
        }
    }
    
    /// Requests Screen Time authorization for Child device management (Parental Control mode)
    public func requestChildAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .child)
            updateStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Child Screen Time Authorization: \(error.localizedDescription)"
            updateStatus()
        }
    }
    
    /// Revokes authorization (if supported by system)
    public func revokeAuthorization() {
        AuthorizationCenter.shared.revokeAuthorization { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.updateStatus()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
