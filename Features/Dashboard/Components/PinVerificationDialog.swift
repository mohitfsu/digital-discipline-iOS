import SwiftUI

/// Secure Parent PIN verification dialog modal
public struct PinVerificationDialog: View {
    @Environment(\.dismiss) private var dismiss
    
    public let onSuccess: () -> Void
    
    @State private var enteredPin: String = ""
    @State private var errorMessage: String?
    @State private var isSettingNewPin: Bool = false
    @State private var confirmPin: String = ""
    @State private var step: PinStep = .verify
    
    private enum PinStep {
        case verify
        case enterNew
        case confirmNew
    }
    
    public init(onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Icon & Title
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.primary.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DisciplineTheme.primary)
                }
                
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitleText)
                        .font(.system(size: 13))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // PIN Dots Display
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPin.count ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(DisciplineTheme.primary.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.vertical, 8)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DisciplineTheme.danger)
                        .multilineTextAlignment(.center)
                }
                
                // Number Pad (0-9)
                numberPad
                
                // Cancel / Dismiss
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DisciplineTheme.textTertiary)
                }
            }
            .padding(24)
        }
        .onAppear {
            if !ParentPinManager.shared.isPinSet {
                step = .enterNew
            }
        }
    }
    
    private var titleText: String {
        switch step {
        case .verify: return "Parent PIN Required"
        case .enterNew: return "Create Parent PIN"
        case .confirmNew: return "Confirm Parent PIN"
        }
    }
    
    private var subtitleText: String {
        switch step {
        case .verify: return "Enter your 4-6 digit parent security PIN to proceed."
        case .enterNew: return "Set a 4-6 digit security PIN to lock settings & anti-uninstall rules."
        case .confirmNew: return "Re-enter the PIN to confirm."
        }
    }
    
    private var numberPad: some View {
        VStack(spacing: 12) {
            ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                HStack(spacing: 16) {
                    ForEach(row, id: \.self) { digit in
                        numButton(digit: "\(digit)")
                    }
                }
            }
            HStack(spacing: 16) {
                // Clear button
                Button {
                    enteredPin = ""
                    errorMessage = nil
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    Text("C")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .frame(width: 75, height: 60)
                        .background(DisciplineTheme.surface)
                        .cornerRadius(16)
                }
                
                numButton(digit: "0")
                
                // Backspace button
                Button {
                    if !enteredPin.isEmpty {
                        enteredPin.removeLast()
                        errorMessage = nil
                        HapticFeedbackManager.shared.buttonTap()
                    }
                } label: {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .frame(width: 75, height: 60)
                        .background(DisciplineTheme.surface)
                        .cornerRadius(16)
                }
            }
        }
    }
    
    private func numButton(digit: String) -> some View {
        Button {
            handleDigitInput(digit)
        } label: {
            Text(digit)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 75, height: 60)
                .background(DisciplineTheme.surface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
        }
    }
    
    private func handleDigitInput(_ digit: String) {
        guard enteredPin.count < 6 else { return }
        enteredPin.append(digit)
        HapticFeedbackManager.shared.buttonTap()
        
        if enteredPin.count >= 4 {
            // Auto submit if length 6, or permit verify
            if enteredPin.count == 6 {
                processPinSubmission()
            }
        }
    }
    
    private func processPinSubmission() {
        switch step {
        case .verify:
            let result = ParentPinManager.shared.verifyPin(enteredPin)
            switch result {
            case .success:
                HapticFeedbackManager.shared.workoutCompleted()
                dismiss()
                onSuccess()
            case .invalidPin(let remaining):
                HapticFeedbackManager.shared.securityError()
                errorMessage = "Incorrect PIN. \(remaining) attempts remaining."
                enteredPin = ""
            case .lockedOut(let seconds):
                HapticFeedbackManager.shared.securityError()
                errorMessage = "Too many failed attempts. Locked out for \(seconds)s."
                enteredPin = ""
            case .pinNotConfigured:
                step = .enterNew
                enteredPin = ""
            }
            
        case .enterNew:
            confirmPin = enteredPin
            enteredPin = ""
            step = .confirmNew
            
        case .confirmNew:
            if enteredPin == confirmPin {
                ParentPinManager.shared.setPin(enteredPin)
                HapticFeedbackManager.shared.workoutCompleted()
                dismiss()
                onSuccess()
            } else {
                HapticFeedbackManager.shared.securityError()
                errorMessage = "PINs do not match. Please try again."
                enteredPin = ""
                confirmPin = ""
                step = .enterNew
            }
        }
    }
}
