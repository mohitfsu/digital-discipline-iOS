import Foundation
import SwiftUI

/// All 8 neuro-behavioral intervention categories
public enum InterventionCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case movement = "Movement & Calisthenics"
    case upperBody = "Upper Body"
    case breathing = "Breathing & Autonomic"
    case meditation = "Meditation & Mindful"
    case yoga = "Yoga & Mobility"
    case simpleResets = "Simple Physical Resets"
    case cognitive = "Cognitive & Executive Control"
    case creative = "Creative & Artistic Expression"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .movement: return "figure.run"
        case .upperBody: return "figure.climbing"
        case .breathing: return "wind"
        case .meditation: return "sparkles"
        case .yoga: return "figure.mind.and.body"
        case .simpleResets: return "figure.walk"
        case .cognitive: return "brain.head.profile"
        case .creative: return "paintpalette.fill"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .movement: return DisciplineTheme.primary
        case .upperBody: return DisciplineTheme.accent
        case .breathing: return DisciplineTheme.accent
        case .meditation: return Color(hex: "A855F7")
        case .yoga: return DisciplineTheme.success
        case .simpleResets: return DisciplineTheme.warning
        case .cognitive: return Color(hex: "EC4899")
        case .creative: return Color(hex: "06B6D4")
        }
    }
}

/// The complete enum of all 42 neuro-behavioral and creative interventions
public enum InterventionType: String, Codable, CaseIterable, Identifiable, Sendable {
    // 🏋️ Category 1: Movement & Calisthenics (10)
    case pushUps = "PUSH_UPS"
    case squats = "SQUATS"
    case lunges = "LUNGES"
    case plank = "PLANK"
    case wallSit = "WALL_SIT"
    case jumpingJacks = "JUMPING_JACKS"
    case highKnees = "HIGH_KNEES"
    case calfRaises = "CALF_RAISES"
    case sitToStand = "SIT_TO_STAND"
    case stretch = "STRETCH"
    
    // 🧗 Category 2: Upper Body (1)
    case pullUps = "PULL_UPS"
    
    // 🌬️ Category 3: Breathing & Autonomic Regulation (4)
    case boxBreathing = "BOX_BREATHING"
    case fourTwoSixBreathing = "FOUR_TWO_SIX_BREATHING"
    case oneMinuteBreathingReset = "ONE_MINUTE_BREATHING_RESET"
    case threeBreathReset = "THREE_BREATH_RESET"
    
    // 🪷 Category 4: Meditation & Mindful Pauses (3)
    case thirtySecondMeditation = "THIRTY_SECOND_MEDITATION"
    case oneMinuteMeditation = "ONE_MINUTE_MEDITATION"
    case mindfulPause = "MINDFUL_PAUSE"
    
    // 🧘 Category 5: Yoga & Mobility (6)
    case mountainPose = "MOUNTAIN_POSE"
    case forwardFold = "FORWARD_FOLD"
    case treePose = "TREE_POSE"
    case childPose = "CHILD_POSE"
    case shoulderStretch = "SHOULDER_STRETCH"
    case miniSunSalutation = "MINI_SUN_SALUTATION"
    
    // 🚶 Category 6: Simple Physical Resets (5)
    case standUp = "STAND_UP"
    case walk30Steps = "WALK_30_STEPS"
    case drinkWater = "DRINK_WATER"
    case lookAwayFromScreen = "LOOK_AWAY_FROM_SCREEN"
    case postureReset = "POSTURE_RESET"
    
    // 🧠 Category 7: Cognitive & Executive Control Micro-Challenges (6)
    case stroopTest = "STROOP_TEST"
    case mathSprint = "MATH_SPRINT"
    case memoryMatrix = "MEMORY_MATRIX"
    case reactionTest = "REACTION_TEST"
    case mindfulReading = "MINDFUL_READING"
    case intentionalWriting = "INTENTIONAL_WRITING"
    
    // 🎨 Category 8: Creative & Artistic Expression (7)
    case zenCanvas = "ZEN_CANVAS"
    case scavengerHunt = "SCAVENGER_HUNT"
    case handMudra = "HAND_MUDRA"
    case ambientSoundscape = "AMBIENT_SOUNDSCAPE"
    case haikuPoetry = "HAIKU_POETRY"
    case lateralThinking = "LATERAL_THINKING"
    case perspectiveCards = "PERSPECTIVE_CARDS"
    
    public var id: String { rawValue }
    
    public var number: Int {
        switch self {
        case .pushUps: return 1
        case .squats: return 2
        case .lunges: return 3
        case .plank: return 4
        case .wallSit: return 5
        case .jumpingJacks: return 6
        case .highKnees: return 7
        case .calfRaises: return 8
        case .sitToStand: return 9
        case .stretch: return 10
        case .pullUps: return 11
        case .boxBreathing: return 12
        case .fourTwoSixBreathing: return 13
        case .oneMinuteBreathingReset: return 14
        case .threeBreathReset: return 15
        case .thirtySecondMeditation: return 16
        case .oneMinuteMeditation: return 17
        case .mindfulPause: return 18
        case .mountainPose: return 19
        case .forwardFold: return 20
        case .treePose: return 21
        case .childPose: return 22
        case .shoulderStretch: return 23
        case .miniSunSalutation: return 24
        case .standUp: return 25
        case .walk30Steps: return 26
        case .drinkWater: return 27
        case .lookAwayFromScreen: return 28
        case .postureReset: return 29
        case .stroopTest: return 30
        case .mathSprint: return 31
        case .memoryMatrix: return 32
        case .reactionTest: return 33
        case .mindfulReading: return 34
        case .intentionalWriting: return 35
        case .zenCanvas: return 36
        case .scavengerHunt: return 37
        case .handMudra: return 38
        case .ambientSoundscape: return 39
        case .haikuPoetry: return 40
        case .lateralThinking: return 41
        case .perspectiveCards: return 42
        }
    }
    
    public var displayName: String {
        switch self {
        case .pushUps: return "Push-ups"
        case .squats: return "Bodyweight Squats"
        case .lunges: return "Alternating Lunges"
        case .plank: return "Core Plank Hold"
        case .wallSit: return "Wall Sit"
        case .jumpingJacks: return "Jumping Jacks"
        case .highKnees: return "High Knees"
        case .calfRaises: return "Calf Raises"
        case .sitToStand: return "Sit-to-Stand"
        case .stretch: return "Full Body Stretch"
        case .pullUps: return "Pull-ups"
        case .boxBreathing: return "Box Breathing (4-4-4-4)"
        case .fourTwoSixBreathing: return "4-2-6 Calming Breath"
        case .oneMinuteBreathingReset: return "1-Minute Breathing Reset"
        case .threeBreathReset: return "30s Deep Breath Reset"
        case .thirtySecondMeditation: return "30-Second Meditation"
        case .oneMinuteMeditation: return "1-Minute Meditation"
        case .mindfulPause: return "30s Mindful Pause"
        case .mountainPose: return "Mountain Pose (Tadasana)"
        case .forwardFold: return "Standing Forward Fold"
        case .treePose: return "Tree Pose (Vrksasana)"
        case .childPose: return "Child's Pose (Balasana)"
        case .shoulderStretch: return "Cross-Body Shoulder Stretch"
        case .miniSunSalutation: return "Mini Sun Salutation"
        case .standUp: return "Stand Up & Shake Off"
        case .walk30Steps: return "Walk 30 Steps"
        case .drinkWater: return "Drink a Glass of Water"
        case .lookAwayFromScreen: return "30s Eye Relief (20-20-20)"
        case .postureReset: return "Posture Alignment"
        case .stroopTest: return "30s Stroop Conflict Test"
        case .mathSprint: return "30s Mental Math Sprint"
        case .memoryMatrix: return "30s Working Memory Matrix"
        case .reactionTest: return "30s Reaction Control Test"
        case .mindfulReading: return "30s Wisdom Reflection"
        case .intentionalWriting: return "30s Purpose Journal"
        case .zenCanvas: return "Zen Enso Canvas"
        case .scavengerHunt: return "Real-World Scavenger Hunt"
        case .handMudra: return "Hand Mudra & Dexterity"
        case .ambientSoundscape: return "Ambient Focus Synthesizer"
        case .haikuPoetry: return "5-7-5 Haiku Crafter"
        case .lateralThinking: return "Divergent Thinking Sprint"
        case .perspectiveCards: return "Perspective Shift Cards"
        }
    }
    
    public var emoji: String {
        switch self {
        case .pushUps: return "💪"
        case .squats: return "🏋️"
        case .lunges: return "🦵"
        case .plank: return "🧘"
        case .wallSit: return "🧱"
        case .jumpingJacks: return "⭐"
        case .highKnees: return "🏃"
        case .calfRaises: return "🦶"
        case .sitToStand: return "🪑"
        case .stretch: return "🙆"
        case .pullUps: return "🧗"
        case .boxBreathing: return "🌬️"
        case .fourTwoSixBreathing: return "🌊"
        case .oneMinuteBreathingReset: return "🍃"
        case .threeBreathReset: return "✨"
        case .thirtySecondMeditation: return "🪷"
        case .oneMinuteMeditation: return "🕯️"
        case .mindfulPause: return "⚡"
        case .mountainPose: return "🏔️"
        case .forwardFold: return "🙇"
        case .treePose: return "🌳"
        case .childPose: return "🕊️"
        case .shoulderStretch: return "🎗️"
        case .miniSunSalutation: return "☀️"
        case .standUp: return "🧍"
        case .walk30Steps: return "🚶"
        case .drinkWater: return "💧"
        case .lookAwayFromScreen: return "👀"
        case .postureReset: return "📐"
        case .stroopTest: return "🧠"
        case .mathSprint: return "🧮"
        case .memoryMatrix: return "🧩"
        case .reactionTest: return "🎯"
        case .mindfulReading: return "📖"
        case .intentionalWriting: return "✍️"
        case .zenCanvas: return "🎨"
        case .scavengerHunt: return "📸"
        case .handMudra: return "✋"
        case .ambientSoundscape: return "🎹"
        case .haikuPoetry: return "📜"
        case .lateralThinking: return "💡"
        case .perspectiveCards: return "🔮"
        }
    }
    
    public var category: InterventionCategory {
        switch self {
        case .pushUps, .squats, .lunges, .plank, .wallSit, .jumpingJacks, .highKnees, .calfRaises, .sitToStand, .stretch:
            return .movement
        case .pullUps:
            return .upperBody
        case .boxBreathing, .fourTwoSixBreathing, .oneMinuteBreathingReset, .threeBreathReset:
            return .breathing
        case .thirtySecondMeditation, .oneMinuteMeditation, .mindfulPause:
            return .meditation
        case .mountainPose, .forwardFold, .treePose, .childPose, .shoulderStretch, .miniSunSalutation:
            return .yoga
        case .standUp, .walk30Steps, .drinkWater, .lookAwayFromScreen, .postureReset:
            return .simpleResets
        case .stroopTest, .mathSprint, .memoryMatrix, .reactionTest, .mindfulReading, .intentionalWriting:
            return .cognitive
        case .zenCanvas, .scavengerHunt, .handMudra, .ambientSoundscape, .haikuPoetry, .lateralThinking, .perspectiveCards:
            return .creative
        }
    }
    
    public var targetValidation: String {
        switch self {
        case .pushUps: return "10 Reps (Sensor/Floor AI)"
        case .squats: return "10 Reps (Camera AI Pose)"
        case .lunges: return "10 Reps (Camera AI Pose)"
        case .plank: return "30s Timer Hold"
        case .wallSit: return "30s Timer Hold"
        case .jumpingJacks: return "15 Reps (Accelerometer AI)"
        case .highKnees: return "20 Reps (Accelerometer AI)"
        case .calfRaises: return "15 Reps (Pose Tracking)"
        case .sitToStand: return "10 Reps (Desk/Chair AI)"
        case .stretch: return "30s Timer Guided"
        case .pullUps: return "5 Reps (Manual Confirm)"
        case .boxBreathing: return "32s Guided Cycles"
        case .fourTwoSixBreathing: return "36s Guided Breath"
        case .oneMinuteBreathingReset: return "60s Natural Rhythm"
        case .threeBreathReset: return "30s Abdominal Breath"
        case .thirtySecondMeditation: return "30s Silence Timer"
        case .oneMinuteMeditation: return "60s Mindful Silence"
        case .mindfulPause: return "30s Reflection Delay"
        case .mountainPose: return "30s Posture Hold"
        case .forwardFold: return "30s Gravity Stretch"
        case .treePose: return "30s Balance Hold"
        case .childPose: return "30s Restorative Hold"
        case .shoulderStretch: return "30s Bilateral Stretch"
        case .miniSunSalutation: return "30s Vinyasa Flow"
        case .standUp: return "30s Camera AI Verification"
        case .walk30Steps: return "30 Steps (Pedometer AI)"
        case .drinkWater: return "Physical Hydration Confirm"
        case .lookAwayFromScreen: return "30s Distant Gaze Timer"
        case .postureReset: return "30s Alignment Timer"
        case .stroopTest: return "6 Conflict Trials"
        case .mathSprint: return "5 Multi-step Equations"
        case .memoryMatrix: return "3 Progressive Pattern Levels"
        case .reactionTest: return "3 Timed Reaction Rounds"
        case .mindfulReading: return "25s Read + Comprehension Check"
        case .intentionalWriting: return "Intention + Task Declaration"
        case .zenCanvas: return "1-Stroke Continuous Enso Drawing"
        case .scavengerHunt: return "Point Camera at Real-World Object"
        case .handMudra: return "4 Finger Mudra Cycles (Hand AI)"
        case .ambientSoundscape: return "20s Active Binaural Beat Mix"
        case .haikuPoetry: return "Compose 5-7-5 Syllable Poem"
        case .lateralThinking: return "Submit 3 Non-obvious Uses"
        case .perspectiveCards: return "Interactive Stoic Card Flip"
        }
    }
    
    public var mechanismDescription: String {
        switch self {
        case .pushUps: return "Upper-body compound activation; forces hands off screen."
        case .squats: return "ML Kit pose angle tracking (hip-knee-ankle) to spike circulation."
        case .lunges: return "Balance and lower-body stability under camera tracking."
        case .plank: return "Isometric core activation; physically grounds the body."
        case .wallSit: return "Quadricep endurance hold away from the phone."
        case .jumpingJacks: return "Cardiovascular shake-off to eliminate lethargy."
        case .highKnees: return "Rapid tempo cardio activation."
        case .calfRaises: return "Smooth ankle/calf extensions."
        case .sitToStand: return "Chair-based functional movement for office workers."
        case .stretch: return "Overhead reach and spine decompression."
        case .pullUps: return "High-effort physical reset using a pull-up bar."
        case .boxBreathing: return "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s; regulates autonomic system."
        case .fourTwoSixBreathing: return "Prolonged 6s exhale triggers parasympathetic nervous response."
        case .oneMinuteBreathingReset: return "Sixty-second conscious breathing pause."
        case .threeBreathReset: return "Rapid centering before accessing device apps."
        case .thirtySecondMeditation: return "Eyes closed; brings total stillness to attention."
        case .oneMinuteMeditation: return "Silent pause to disconnect from digital noise."
        case .mindfulPause: return "Conscious pause asking: 'Do I really need this right now?'"
        case .mountainPose: return "Grounded posture alignment with feet even and spine tall."
        case .forwardFold: return "Hinge at hips to release hamstrings and lower back tension."
        case .treePose: return "Single-leg balance requiring undivided mental focus."
        case .childPose: return "Kneeling forward fold to release neck/shoulder tension."
        case .shoulderStretch: return "Arm across chest to release desk-worker shoulder tightness."
        case .miniSunSalutation: return "4-step breath-synchronized movement sequence."
        case .standUp: return "Step back into camera frame, stand up, and shake out tension."
        case .walk30Steps: return "Walk around the room until 30 physical steps are counted."
        case .drinkWater: return "Step away from screen to drink a full glass of water."
        case .lookAwayFromScreen: return "Look at an object 20 feet away to relax ciliary eye muscles."
        case .postureReset: return "Roll shoulders back, tuck chin, align cervical spine."
        case .stroopTest: return "Match ink color vs. text word under time pressure to stimulate inhibitory control."
        case .mathSprint: return "Solve timed arithmetic equations to awaken logical reasoning."
        case .memoryMatrix: return "Memorize and repeat spatial tile patterns in exact sequence."
        case .reactionTest: return "Inhibitory impulse control: wait on red, tap instantly on green."
        case .mindfulReading: return "25-second Stoic philosophical reading followed by verification."
        case .intentionalWriting: return "Type specific intended task before opening any entertainment app."
        case .zenCanvas: return "Shifts brain from passive consumer to active creator via continuous stroke drawing."
        case .scavengerHunt: return "Apple Vision detects real-world physical objects to break screen myopia."
        case .handMudra: return "Hand pose AI guides finger mudras to release thumb scrolling tendon strain."
        case .ambientSoundscape: return "40Hz Gamma & Alpha wave synthesizer anchors deep focus audio channels."
        case .haikuPoetry: return "Structured 5-7-5 micro-poetry requires deliberate language retrieval."
        case .lateralThinking: return "Alternative Uses task sparks divergent creativity and prefrontal elasticity."
        case .perspectiveCards: return "3D interactive Stoic tarot deck shatters dopamine tunnel vision."
        }
    }
}
