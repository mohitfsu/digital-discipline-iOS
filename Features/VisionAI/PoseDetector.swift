import Foundation
import Vision
import CoreGraphics
import CoreMedia

/// Extracted 2D body pose landmark points
public struct BodyPoseFrame: Sendable {
    public let leftHip: CGPoint?
    public let leftKnee: CGPoint?
    public let leftAnkle: CGPoint?
    
    public let rightHip: CGPoint?
    public let rightKnee: CGPoint?
    public let rightAnkle: CGPoint?
    
    public let leftShoulder: CGPoint?
    public let rightShoulder: CGPoint?
    public let neck: CGPoint?
    public let nose: CGPoint?
    public let root: CGPoint?
    
    public let timestamp: TimeInterval
    
    public var hasSquatKeypoints: Bool {
        (leftHip != nil && leftKnee != nil && leftAnkle != nil) ||
        (rightHip != nil && rightKnee != nil && rightAnkle != nil)
    }
    
    public var hasBreathingKeypoints: Bool {
        leftShoulder != nil && rightShoulder != nil && (neck != nil || nose != nil)
    }
}

/// Vision Body Pose Detection Worker utilizing Apple Neural Engine (ANE)
public final class PoseDetector: @unchecked Sendable {
    public static let shared = PoseDetector()
    
    private let request = VNDetectHumanBodyPoseRequest()
    private let minConfidence: Float = 0.45
    
    private init() {}
    
    /// Processes a camera frame sample buffer and extracts recognized body joints
    public func processFrame(sampleBuffer: CMSampleBuffer) -> BodyPoseFrame? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else {
                return nil
            }
            
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
            return extractKeypoints(from: observation, timestamp: timestamp)
        } catch {
            print("Vision pose detection error: \(error)")
            return nil
        }
    }
    
    private func extractKeypoints(from observation: VNHumanBodyPoseObservation, timestamp: TimeInterval) -> BodyPoseFrame {
        let leftHip = try? observation.recognizedPoint(.leftHip)
        let leftKnee = try? observation.recognizedPoint(.leftKnee)
        let leftAnkle = try? observation.recognizedPoint(.leftAnkle)
        
        let rightHip = try? observation.recognizedPoint(.rightHip)
        let rightKnee = try? observation.recognizedPoint(.rightKnee)
        let rightAnkle = try? observation.recognizedPoint(.rightAnkle)
        
        let leftShoulder = try? observation.recognizedPoint(.leftShoulder)
        let rightShoulder = try? observation.recognizedPoint(.rightShoulder)
        let neck = try? observation.recognizedPoint(.neck)
        let nose = try? observation.recognizedPoint(.nose)
        let root = try? observation.recognizedPoint(.root)
        
        return BodyPoseFrame(
            leftHip: AngleCalculator.pointIfConfident(leftHip, minConfidence: minConfidence),
            leftKnee: AngleCalculator.pointIfConfident(leftKnee, minConfidence: minConfidence),
            leftAnkle: AngleCalculator.pointIfConfident(leftAnkle, minConfidence: minConfidence),
            rightHip: AngleCalculator.pointIfConfident(rightHip, minConfidence: minConfidence),
            rightKnee: AngleCalculator.pointIfConfident(rightKnee, minConfidence: minConfidence),
            rightAnkle: AngleCalculator.pointIfConfident(rightAnkle, minConfidence: minConfidence),
            leftShoulder: AngleCalculator.pointIfConfident(leftShoulder, minConfidence: minConfidence),
            rightShoulder: AngleCalculator.pointIfConfident(rightShoulder, minConfidence: minConfidence),
            neck: AngleCalculator.pointIfConfident(neck, minConfidence: minConfidence),
            nose: AngleCalculator.pointIfConfident(nose, minConfidence: minConfidence),
            root: AngleCalculator.pointIfConfident(root, minConfidence: minConfidence),
            timestamp: timestamp
        )
    }
}
