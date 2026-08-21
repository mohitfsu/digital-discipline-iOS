import SwiftUI
import AVFoundation
import Vision

/// Hand Mudra & Finger Dexterity workout tracking hand pose keypoints to relieve scrolling tendon strain
public struct HandMudraDexterityView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let unlockDurationMinutes: Int
    public let onCompleted: () -> Void
    
    @State private var targetFinger = 1 // 1=Index, 2=Middle, 3=Ring, 4=Pinky
    @State private var cycleCount = 0
    @State private var targetCycles = 4
    @State private var feedbackText = "Touch Thumb to Index Finger (Gyan Mudra)"
    @State private var isCompleted = false
    
    public init(unlockDurationMinutes: Int = 15, onCompleted: @escaping () -> Void = {}) {
        self.unlockDurationMinutes = unlockDurationMinutes
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        ZStack {
            DisciplineTheme.background.ignoresSafeArea()
            
            // Hand Pose Camera Feed
            HandPoseCameraFeedView { handFrame in
                evaluateHandPose(handFrame)
            }
            .ignoresSafeArea()
            
            // Dark Gradient
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
                        Text("HAND DEXTERITY & MUDRA")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(DisciplineTheme.accent)
                        Text("Cycle \(cycleCount)/\(targetCycles)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Guidance Card
                VStack(spacing: 6) {
                    Text(feedbackText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Rhythmic finger sequencing releases thumb scroll stiffness and resets motor pathways.")
                        .font(.system(size: 12))
                        .foregroundColor(DisciplineTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(14)
                .background(DisciplineTheme.surface.opacity(0.85))
                .cornerRadius(18)
                
                Spacer()
                
                // Finger Sequence Visualizer
                HStack(spacing: 14) {
                    fingerNode(number: 1, name: "Index", icon: "hand.point.up.left.fill")
                    fingerNode(number: 2, name: "Middle", icon: "hand.raised.fill")
                    fingerNode(number: 3, name: "Ring", icon: "hand.raised.slash.fill")
                    fingerNode(number: 4, name: "Pinky", icon: "hand.thumbsup.fill")
                }
                
                Spacer()
            }
            .padding(24)
            
            if isCompleted {
                completionOverlay
            }
        }
    }
    
    private func fingerNode(number: Int, name: String, icon: String) -> some View {
        let isCurrent = targetFinger == number
        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCurrent ? DisciplineTheme.accent : DisciplineTheme.surfaceSecondary)
                    .frame(width: 54, height: 54)
                
                Text("\(number)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(isCurrent ? .white : DisciplineTheme.textSecondary)
            }
            
            Text(name)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isCurrent ? DisciplineTheme.accent : DisciplineTheme.textTertiary)
        }
    }
    
    private func evaluateHandPose(_ observation: VNHumanHandPoseObservation?) {
        guard !isCompleted else { return }
        guard let obs = observation else { return }
        
        guard let thumbTip = try? obs.recognizedPoint(.thumbTip),
              let indexTip = try? obs.recognizedPoint(.indexTip),
              let middleTip = try? obs.recognizedPoint(.middleTip),
              let ringTip = try? obs.recognizedPoint(.ringTip),
              let littleTip = try? obs.recognizedPoint(.littleTip) else {
            return
        }
        
        let thumbPt = CGPoint(x: thumbTip.location.x, y: 1.0 - thumbTip.location.y)
        let indexPt = CGPoint(x: indexTip.location.x, y: 1.0 - indexTip.location.y)
        let middlePt = CGPoint(x: middleTip.location.x, y: 1.0 - middleTip.location.y)
        let ringPt = CGPoint(x: ringTip.location.x, y: 1.0 - ringTip.location.y)
        let littlePt = CGPoint(x: littleTip.location.x, y: 1.0 - littleTip.location.y)
        
        let threshold = 0.08
        
        switch targetFinger {
        case 1:
            if AngleCalculator.distance(from: thumbPt, to: indexPt) < threshold {
                advanceFinger()
            }
        case 2:
            if AngleCalculator.distance(from: thumbPt, to: middlePt) < threshold {
                advanceFinger()
            }
        case 3:
            if AngleCalculator.distance(from: thumbPt, to: ringPt) < threshold {
                advanceFinger()
            }
        case 4:
            if AngleCalculator.distance(from: thumbPt, to: littlePt) < threshold {
                advanceFinger()
            }
        default:
            break
        }
    }
    
    private func advanceFinger() {
        HapticFeedbackManager.shared.repCompleted()
        if targetFinger < 4 {
            targetFinger += 1
        } else {
            targetFinger = 1
            cycleCount += 1
            if cycleCount >= targetCycles {
                isCompleted = true
                HapticFeedbackManager.shared.workoutCompleted()
                SharedDataStore.shared.recordBreathingSessionCompleted()
            }
        }
        
        switch targetFinger {
        case 1: feedbackText = "Touch Thumb to Index Finger (Gyan Mudra)"
        case 2: feedbackText = "Touch Thumb to Middle Finger (Shuni Mudra)"
        case 3: feedbackText = "Touch Thumb to Ring Finger (Surya Mudra)"
        case 4: feedbackText = "Touch Thumb to Pinky Finger (Varun Mudra)"
        default: break
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(DisciplineTheme.accent.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 40))
                        .foregroundColor(DisciplineTheme.accent)
                }
                
                Text("Hand Dexterity Restored!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("All 4 mudra finger cycles completed. Scrolling tendon tension relieved.")
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
                        .background(DisciplineTheme.accent)
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

/// Front Camera feed with `VNDetectHumanHandPoseRequest`
public struct HandPoseCameraFeedView: UIViewControllerRepresentable {
    public let onHandDetected: (VNHumanHandPoseObservation?) -> Void
    
    public init(onHandDetected: @escaping (VNHumanHandPoseObservation?) -> Void) {
        self.onHandDetected = onHandDetected
    }
    
    public func makeUIViewController(context: Context) -> HandPoseCameraViewController {
        let controller = HandPoseCameraViewController()
        controller.onHandDetected = onHandDetected
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: HandPoseCameraViewController, context: Context) {}
}

public final class HandPoseCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var onHandDetected: ((VNHumanHandPoseObservation?) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let queue = DispatchQueue(label: "com.digitaldiscipline.handQueue", qos: .userInteractive)
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        handPoseRequest.maximumHandCount = 1
        setupCamera()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
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
                conn.isVideoMirrored = true
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
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([handPoseRequest])
        
        let observation = handPoseRequest.results?.first
        DispatchQueue.main.async { [weak self] in
            self?.onHandDetected?(observation)
        }
    }
}
