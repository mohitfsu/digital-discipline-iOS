import SwiftUI
import AVFoundation
import Vision

/// Real-World Object Scavenger Hunt using Apple Vision image classification to force 3D physical grounding
public struct RealWorldScavengerView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var targetMission: ScavengerTarget = .book
    @State private var detectedCategory: String = "Scanning environment..."
    @State private var confidence: Float = 0.0
    @State private var isObjectLocked = false
    @State private var lockSeconds = 0.0
    
    public enum ScavengerTarget: String, CaseIterable, Sendable {
        case book = "Physical Book 📖"
        case plant = "Green Plant / Nature 🌿"
        case mug = "Coffee Mug or Cup ☕"
        case pen = "Pen or Pencil ✏️"
        
        public var searchKeywords: [String] {
            switch self {
            case .book: return ["book", "publication", "binder", "notebook", "textbook", "novel", "paper"]
            case .plant: return ["plant", "leaf", "flora", "tree", "vegetation", "flower", "potted"]
            case .mug: return ["cup", "mug", "coffee", "coffeepot", "glass", "water", "beverage", "ceramic"]
            case .pen: return ["pen", "pencil", "quill", "stationery", "writing"]
            }
        }
        
        public var promptGuidance: String {
            switch self {
            case .book: return "Point back camera at any open or closed book in your room"
            case .plant: return "Find any green houseplant, leaf, or nature out your window"
            case .mug: return "Point camera at a coffee mug, tea cup, or drinking glass"
            case .pen: return "Point camera at a pen, pencil, or physical writing tool"
            }
        }
    }
    
    public init(unlockDurationMinutes: Int = 15, onCompleted: @escaping () -> Void = {}) {
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            // Back Camera Live Feed
            ScavengerCameraFeedView { classifications in
                evaluateClassifications(classifications)
            }
            .ignoresSafeArea()
            
            // Dark vignette overlay
            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.clear, Color.black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(DisciplineTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("3D REAL-WORLD GROUNDING")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.success)
                        Text("Scavenger Hunt AI")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Mission Target Banner
                VStack(spacing: 6) {
                    Text("MISSION: FIND THIS OBJECT")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(DisciplineTheme.accent)
                    
                    Text(targetMission.rawValue)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(targetMission.promptGuidance)
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(DisciplineTheme.surface.opacity(0.85))
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(DisciplineTheme.surfaceSecondary, lineWidth: 1)
                )
                
                Spacer()
                
                // Center Targeting Reticle
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isObjectLocked ? DisciplineTheme.success : DisciplineTheme.accent.opacity(0.5),
                            style: StrokeStyle(lineWidth: isObjectLocked ? 4 : 2, dash: isObjectLocked ? [] : [10, 5])
                        )
                        .frame(width: 240, height: 240)
                    
                    VStack(spacing: 8) {
                        Image(systemName: isObjectLocked ? "checkmark.circle.fill" : "viewfinder")
                            .font(.system(size: 44))
                            .foregroundColor(isObjectLocked ? DisciplineTheme.success : DisciplineTheme.accent)
                        
                        Text(isObjectLocked ? "TARGET RECOGNIZED!" : detectedCategory.prefix(25).uppercased())
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(DisciplineTheme.surface.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Shuffle Mission Button
                Button {
                    targetMission = ScavengerTarget.allCases.filter { $0 != targetMission }.randomElement()!
                    HapticFeedbackManager.shared.buttonTap()
                } label: {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Try Different Object")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(DisciplineTheme.surface.opacity(0.8))
                    .cornerRadius(12)
                }
            }
            .padding(24)
            
            if isObjectLocked {
                completionOverlay
            }
        }
        .onAppear {
            targetMission = ScavengerTarget.allCases.randomElement()!
        }
    }
    
    private func evaluateClassifications(_ observations: [VNClassificationObservation]) {
        guard !isObjectLocked else { return }
        guard let top = observations.first else { return }
        
        self.detectedCategory = top.identifier.replacingOccurrences(of: "_", with: " ")
        self.confidence = top.confidence
        
        let targetKeywords = targetMission.searchKeywords
        let matched = observations.prefix(5).contains { obs in
            let label = obs.identifier.lowercased()
            return targetKeywords.contains { kw in label.contains(kw) } && obs.confidence > 0.25
        }
        
        if matched {
            HapticFeedbackManager.shared.workoutCompleted()
            isObjectLocked = true
            SharedDataStore.shared.recordBreathingSessionCompleted()
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.success.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.success)
                }
                
                Text("Physical World Connected!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You found \(targetMission.rawValue) in your physical environment. Real-world grounding verified.")
                    .font(.system(size: 14))
                    .foregroundColor(DisciplineTheme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    ShieldManager.shared.grantTemporaryUnlock(durationMinutes: unlockDurationMinutes)
                    onCompleted()
                    dismiss()
                } label: {
                    Text("Claim \(unlockDurationMinutes)m Unlock")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DisciplineTheme.success)
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .background(DisciplineTheme.surface)
            .cornerRadius(24)
            .padding(24)
        }
    }
}

/// Back Camera view specifically configured for Real-World object taxonomy classification
public struct ScavengerCameraFeedView: UIViewControllerRepresentable {
    public let onClassified: ([VNClassificationObservation]) -> Void
    
    public init(onClassified: @escaping ([VNClassificationObservation]) -> Void) {
        self.onClassified = onClassified
    }
    
    public func makeUIViewController(context: Context) -> ScavengerCameraViewController {
        let controller = ScavengerCameraViewController()
        controller.onClassified = onClassified
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: ScavengerCameraViewController, context: Context) {}
}

public final class ScavengerCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var onClassified: (([VNClassificationObservation]) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let queue = DispatchQueue(label: "com.digitaldiscipline.scavengerQueue", qos: .userInitiated)
    private var classificationRequest: VNClassifyImageRequest?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupClassification()
        setupCamera()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func setupClassification() {
        classificationRequest = VNClassifyImageRequest()
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            if let conn = output.connection(with: .video) {
                conn.videoOrientation = .portrait
            }
        }
        
        captureSession.commitConfiguration()
        
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        self.previewLayer = preview
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request = classificationRequest else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
        
        if let results = request.results {
            DispatchQueue.main.async { [weak self] in
                self?.onClassified?(results)
            }
        }
    }
}
