import Foundation
import FamilyControls
import Combine

/// Authorization manager for Apple's Screen Time FamilyControls framework
@MainActor
public final class ScreenTimeAuthorizationManager: ObservableObject {
    public static let shared = ScreenTimeAuthorizationManager()
    
    @Published public var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published public var isAuthorized: Bool = false
    @Published public var errorMessage: String?
    
    private let center = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        updateStatus()
        observeAuthorizationCenter()
    }
    
    public func updateStatus() {
        self.authorizationStatus = center.authorizationStatus
        self.isAuthorized = (center.authorizationStatus == .approved)
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
            try await center.requestAuthorization(for: .individual)
            updateStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Screen Time Authorization Failed: \(error.localizedDescription)"
            updateStatus()
        }
    }
    
    /// Requests Screen Time authorization for Child device management (Parental Control mode)
    public func requestChildAuthorization() async {
        do {
            try await center.requestAuthorization(for: .child)
            updateStatus()
            errorMessage = nil
        } catch {
            errorMessage = "Child Screen Time Authorization Failed: \(error.localizedDescription)"
            updateStatus()
        }
    }
    
    /// Revokes authorization (if supported by system)
    public func revokeAuthorization() {
        center.revokeAuthorization { [weak self] result in
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
