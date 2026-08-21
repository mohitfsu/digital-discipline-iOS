import Foundation
import CoreGraphics
import Vision

/// High-performance trigonometric calculator for 2D human pose joint angles
public struct AngleCalculator: Sendable {
    
    /// Calculates the interior angle (in degrees) formed at vertex B by points A, B, and C.
    /// Example: For knee angle: A = Hip, B = Knee, C = Ankle
    public static func angleDegrees(
        pointA: CGPoint,
        vertexB: CGPoint,
        pointC: CGPoint
    ) -> Double {
        let v1 = CGPoint(x: pointA.x - vertexB.x, y: pointA.y - vertexB.y)
        let v2 = CGPoint(x: pointC.x - vertexB.x, y: pointC.y - vertexB.y)
        
        let dotProduct = Double(v1.x * v2.x + v1.y * v2.y)
        let mag1 = Double(sqrt(v1.x * v1.x + v1.y * v1.y))
        let mag2 = Double(sqrt(v2.x * v2.x + v2.y * v2.y))
        
        guard mag1 > 0.0001, mag2 > 0.0001 else { return 180.0 }
        
        let cosine = max(-1.0, min(1.0, dotProduct / (mag1 * mag2)))
        let radians = acos(cosine)
        return radians * 180.0 / .pi
    }
    
    /// Calculates distance between two normalized points
    public static func distance(from p1: CGPoint, to p2: CGPoint) -> Double {
        let dx = Double(p2.x - p1.x)
        let dy = Double(p2.y - p1.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Computes posture alignment angle relative to the vertical axis (0 degrees = perfectly upright)
    public static func verticalAlignmentAngle(top: CGPoint, bottom: CGPoint) -> Double {
        let dx = Double(top.x - bottom.x)
        let dy = Double(top.y - bottom.y)
        let radians = atan2(abs(dx), abs(dy))
        return radians * 180.0 / .pi
    }
    
    /// Helper to safely retrieve recognized points with confidence filter
    public static func pointIfConfident(
        _ point: VNRecognizedPoint?,
        minConfidence: Float = 0.45
    ) -> CGPoint? {
        guard let pt = point, pt.confidence >= minConfidence else {
            return nil
        }
        return CGPoint(x: pt.location.x, y: 1.0 - pt.location.y) // Invert Y for standard SwiftUI screen coordinates
    }
}
