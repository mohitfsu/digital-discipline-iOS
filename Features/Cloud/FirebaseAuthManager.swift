import Foundation
import Combine
import AuthenticationServices

public enum AuthState: Equatable, Sendable {
    case signedOut
    case authenticated(userId: String, email: String?)
    case loading
}

/// Firebase Auth & Apple Sign-In wrapper for Parent & Child Cloud authentication
@MainActor
public final class FirebaseAuthManager: ObservableObject {
    public static let shared = FirebaseAuthManager()
    
    @Published public var authState: AuthState = .signedOut
    @Published public var currentUserId: String?
    @Published public var currentUserEmail: String?
    @Published public var errorMessage: String?
    
    private init() {
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        if let token = KeychainManager.shared.loadString(key: "digitaldiscipline.auth.token"),
           let userId = KeychainManager.shared.loadString(key: "digitaldiscipline.auth.userid") {
            let email = KeychainManager.shared.loadString(key: "digitaldiscipline.auth.email")
            self.currentUserId = userId
            self.currentUserEmail = email
            self.authState = .authenticated(userId: userId, email: email)
        }
    }
    
    public func signIn(email: String, password: String) async -> Bool {
        authState = .loading
        errorMessage = nil
        
        // Simulating robust auth endpoint / Firebase Auth signIn
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        guard email.contains("@") && password.count >= 6 else {
            errorMessage = "Invalid credentials. Password must be at least 6 characters."
            authState = .signedOut
            return false
        }
        
        let mockUserId = "usr_\(abs(email.hashValue))"
        self.currentUserId = mockUserId
        self.currentUserEmail = email
        self.authState = .authenticated(userId: mockUserId, email: email)
        
        KeychainManager.shared.save(key: "digitaldiscipline.auth.token", string: UUID().uuidString)
        KeychainManager.shared.save(key: "digitaldiscipline.auth.userid", string: mockUserId)
        KeychainManager.shared.save(key: "digitaldiscipline.auth.email", string: email)
        
        return true
    }
    
    public func signUp(email: String, password: String) async -> Bool {
        return await signIn(email: email, password: password)
    }
    
    public func signOut() {
        KeychainManager.shared.delete(key: "digitaldiscipline.auth.token")
        KeychainManager.shared.delete(key: "digitaldiscipline.auth.userid")
        KeychainManager.shared.delete(key: "digitaldiscipline.auth.email")
        
        self.currentUserId = nil
        self.currentUserEmail = nil
        self.authState = .signedOut
    }
}
