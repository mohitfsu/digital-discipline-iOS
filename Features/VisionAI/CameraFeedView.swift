import SwiftUI
import AVFoundation
import Vision

/// UIKit wrapper providing a high-performance 60 FPS front camera feed and ANE pose estimation with safe permission guards
public struct CameraFeedView: UIViewControllerRepresentable {
    public let onFrameDetected: (BodyPoseFrame) -> Void
    
    public init(onFrameDetected: @escaping (BodyPoseFrame) -> Void) {
        self.onFrameDetected = onFrameDetected
    }
    
    public func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onFrameDetected = onFrameDetected
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

public final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var onFrameDetected: ((BodyPoseFrame) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoOutputQueue = DispatchQueue(label: "com.digitaldiscipline.videoOutputQueue", qos: .userInteractive)
    private var isConfigured = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(DisciplineTheme.background)
        checkPermissionsAndSetup()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isConfigured && !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    private func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                        DispatchQueue.global(qos: .userInitiated).async {
                            self?.captureSession.startRunning()
                        }
                    }
                }
            }
        default:
            print("Camera access denied or restricted")
        }
    }
    
    private func setupCamera() {
        guard !isConfigured else { return }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .hd1280x720
        
        // Setup Front-Facing Camera with safety fallback
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ?? AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            captureSession.commitConfiguration()
            print("Failed to initialize camera input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Attempt to configure 60 FPS if supported safely
        if (try? frontCamera.lockForConfiguration()) != nil {
            for range in frontCamera.activeFormat.videoSupportedFrameRateRanges {
                if range.maxFrameRate >= 60.0 {
                    frontCamera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                    frontCamera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
                    break
                }
            }
            frontCamera.unlockForConfiguration()
        }
        
        // Video Output Setup
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
                if frontCamera.position == .front {
                    connection.isVideoMirrored = true
                }
            }
        }
        
        captureSession.commitConfiguration()
        
        // Setup Preview Layer
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        self.previewLayer = preview
        self.isConfigured = true
    }
    
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let poseFrame = PoseDetector.shared.processFrame(sampleBuffer: sampleBuffer) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.onFrameDetected?(poseFrame)
        }
    }
}
