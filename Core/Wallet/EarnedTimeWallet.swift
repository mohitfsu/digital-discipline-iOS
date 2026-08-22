import Foundation
import Combine

/// Double-entry transaction model for the Earned Screen Time Economy
public struct WalletTransaction: Identifiable, Codable, Sendable {
    public let id: String
    public let timestamp: Date
    public let type: TransactionType
    public let amountSeconds: Int
    public let description: String
    
    public enum TransactionType: String, Codable, Sendable {
        case credit // Earned from physical, mindful, or cognitive intervention
        case debit  // Consumed during temporary app session
        case expire // Daily midnight expiration / reset
    }
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        type: TransactionType,
        amountSeconds: Int,
        description: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.amountSeconds = amountSeconds
        self.description = description
    }
}

/// Authoritative Double-Entry Time Banking Ledger
@MainActor
public final class EarnedTimeWallet: ObservableObject {
    public static let shared = EarnedTimeWallet()
    
    @Published public var availableSeconds: Int = 0
    @Published public var dailyEarnedSeconds: Int = 0
    @Published public var transactions: [WalletTransaction] = []
    
    public let dailyEarnCapSeconds: Int = 3600 // Max 60 minutes earn cap per day
    public let maxSessionSeconds: Int = 900    // Max 15 minutes per unlock session
    
    private let walletBalanceKey = "digitaldiscipline.wallet.available_seconds"
    private let dailyEarnedKey = "digitaldiscipline.wallet.daily_earned_seconds"
    private let ledgerTransactionsKey = "digitaldiscipline.wallet.ledger_transactions"
    private let lastResetDateKey = "digitaldiscipline.wallet.last_reset_date"
    
    private let defaults = UserDefaults(suiteName: AppStorageKeys.appGroupName)
    
    private init() {
        loadState()
        checkMidnightRollover()
    }
    
    private func loadState() {
        guard let defaults = defaults else { return }
        self.availableSeconds = defaults.integer(forKey: walletBalanceKey)
        self.dailyEarnedSeconds = defaults.integer(forKey: dailyEarnedKey)
        
        if let data = defaults.data(forKey: ledgerTransactionsKey),
           let list = try? JSONDecoder().decode([WalletTransaction].self, from: data) {
            self.transactions = list
        }
    }
    
    private func saveState() {
        guard let defaults = defaults else { return }
        defaults.set(availableSeconds, forKey: walletBalanceKey)
        defaults.set(dailyEarnedSeconds, forKey: dailyEarnedKey)
        
        if let data = try? JSONEncoder().encode(transactions) {
            defaults.set(data, forKey: ledgerTransactionsKey)
        }
    }
    
    /// Credits earned seconds from completing an intervention challenge
    @discardableResult
    public func credit(seconds: Int, reason: String) -> Bool {
        checkMidnightRollover()
        
        let remainingCap = max(0, dailyEarnCapSeconds - dailyEarnedSeconds)
        let creditedAmount = min(seconds, remainingCap)
        guard creditedAmount > 0 else { return false }
        
        availableSeconds += creditedAmount
        dailyEarnedSeconds += creditedAmount
        
        let transaction = WalletTransaction(
            type: .credit,
            amountSeconds: creditedAmount,
            description: reason
        )
        transactions.insert(transaction, at: 0)
        saveState()
        return true
    }
    
    /// Debits seconds from the wallet when an app unlock session is claimed
    @discardableResult
    public func debit(seconds: Int, reason: String) -> Bool {
        let debitedAmount = min(seconds, availableSeconds)
        guard debitedAmount > 0 else { return false }
        
        availableSeconds -= debitedAmount
        
        let transaction = WalletTransaction(
            type: .debit,
            amountSeconds: debitedAmount,
            description: reason
        )
        transactions.insert(transaction, at: 0)
        saveState()
        return true
    }
    
    /// Checks and executes daily midnight rollover reset
    public func checkMidnightRollover() {
        guard let defaults = defaults else { return }
        let now = Date()
        let calendar = Calendar.current
        
        if let lastReset = defaults.object(forKey: lastResetDateKey) as? Date {
            if !calendar.isDate(now, inSameDayAs: lastReset) {
                // Reset daily counters
                self.dailyEarnedSeconds = 0
                defaults.set(now, forKey: lastResetDateKey)
                saveState()
            }
        } else {
            defaults.set(now, forKey: lastResetDateKey)
        }
    }
    
    public var availableMinutes: Int {
        availableSeconds / 60
    }
}
