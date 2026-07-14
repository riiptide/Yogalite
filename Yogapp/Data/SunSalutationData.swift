import Foundation

enum SunSalutationData {
    static let mountain = Pose(id: "mountain", name: "Mountain Pose", assetName: "mountain_pose")
    static let upwardSalute = Pose(id: "upward-salute", name: "Upward Salute", assetName: "upward_salute")
    static let forwardFold = Pose(id: "forward-fold", name: "Forward Fold", assetName: "forward_fold")
    static let halfwayLift = Pose(id: "halfway-lift", name: "Halfway Lift", assetName: "halfway_lift")
    static let plank = Pose(id: "plank", name: "Plank", assetName: "plank")
    static let chaturanga = Pose(id: "chaturanga", name: "Chaturanga", assetName: "chaturanga")
    static let upwardDog = Pose(id: "upward-facing-dog", name: "Upward-Facing Dog", assetName: "upward_dog")
    static let downwardDog = Pose(id: "downward-facing-dog", name: "Downward-Facing Dog", assetName: "downward_dog")
    static let tabletop = Pose(id: "tabletop", name: "Tabletop", assetName: "figure.core.training")
    static let cow = Pose(id: "cow", name: "Cow Pose", assetName: "figure.yoga")
    static let birdDog = Pose(id: "bird-dog", name: "Bird Dog", assetName: "figure.core.training")
    static let threadNeedle = Pose(id: "thread-needle", name: "Thread the Needle", assetName: "figure.flexibility")
    static let lowLunge = Pose(id: "low-lunge", name: "Low Lunge", assetName: "figure.yoga")
    static let warriorTwo = Pose(id: "warrior-two", name: "Warrior II", assetName: "figure.yoga")
    static let sideAngle = Pose(id: "side-angle", name: "Side Angle", assetName: "figure.flexibility")
    static let triangle = Pose(id: "triangle", name: "Triangle Pose", assetName: "figure.flexibility")
    static let pyramid = Pose(id: "pyramid", name: "Pyramid Pose", assetName: "figure.flexibility")
    static let seatedFold = Pose(id: "seated-fold", name: "Seated Fold", assetName: "figure.flexibility")
    static let bridge = Pose(id: "bridge", name: "Bridge Pose", assetName: "figure.yoga")
    static let shoulderStand = Pose(id: "shoulder-stand", name: "Supported Shoulder Stand", assetName: "figure.cooldown")
    static let childPose = Pose(id: "child-pose", name: "Child's Pose", assetName: "figure.cooldown")
    static let threeLeggedDog = Pose(id: "three-legged-dog", name: "Three-Legged Dog", assetName: "figure.yoga")
    static let kneeToNose = Pose(id: "knee-to-nose", name: "Knee to Nose", assetName: "figure.core.training")
    static let halfSplit = Pose(id: "half-split", name: "Half Split", assetName: "figure.flexibility")
    static let chair = Pose(id: "chair", name: "Chair Pose", assetName: "figure.strengthtraining.traditional")
    static let boat = Pose(id: "boat", name: "Boat Pose", assetName: "figure.core.training")
    static let sphinx = Pose(id: "sphinx", name: "Sphinx Pose", assetName: "figure.yoga")

    static let allSequences = [
        sunSalutationA,
        christmasStressRelief,
        consciousTransitions
    ]

    static let sunSalutationA = YogaSequence(
        id: "sun-salutation-a",
        title: "Sun Salutation A",
        subtitle: "A simple breath-led flow that warms the body and builds mobility.",
        difficulty: "Beginner",
        rounds: 4,
        steps: [
            hold(mountain, duration: 8, breath: .natural, "Stand tall and ground through both feet."),
            move("Mountain Pose to Upward Salute", mountain, upwardSalute, duration: 3, breath: .inhale, "Sweep your arms overhead."),
            hold(upwardSalute, duration: 3, breath: .inhale, "Reach upward through your fingertips."),
            move("Upward Salute to Forward Fold", upwardSalute, forwardFold, duration: 4, breath: .exhale, "Hinge from your hips and fold forward."),
            hold(forwardFold, duration: 5, breath: .exhale, "Relax your neck and soften your knees."),
            move("Forward Fold to Halfway Lift", forwardFold, halfwayLift, duration: 3, breath: .inhale, "Lengthen your spine forward."),
            hold(halfwayLift, duration: 3, breath: .inhale, "Keep your spine long."),
            move("Halfway Lift to Plank", halfwayLift, plank, duration: 4, breath: .exhale, "Plant your hands and step back."),
            hold(plank, duration: 4, breath: .natural, "Press the floor away and engage your core."),
            move("Plank to Chaturanga", plank, chaturanga, duration: 3, breath: .exhale, "Lower halfway with control."),
            hold(chaturanga, duration: 2, breath: .exhale, "Keep your elbows close to your ribs."),
            move("Chaturanga to Upward-Facing Dog", chaturanga, upwardDog, duration: 3, breath: .inhale, "Roll over your toes and open your chest."),
            hold(upwardDog, duration: 4, breath: .inhale, "Lift through your sternum."),
            move("Upward-Facing Dog to Downward-Facing Dog", upwardDog, downwardDog, duration: 4, breath: .exhale, "Lift your hips up and back."),
            hold(downwardDog, duration: 15, breath: .natural, "Lengthen your spine and take several breaths."),
            move("Downward-Facing Dog to Halfway Lift", downwardDog, halfwayLift, duration: 4, breath: .inhale, "Step or lightly hop toward your hands."),
            hold(halfwayLift, duration: 3, breath: .inhale, "Extend your chest forward."),
            move("Halfway Lift to Forward Fold", halfwayLift, forwardFold, duration: 2, breath: .exhale, "Release into the fold."),
            hold(forwardFold, duration: 3, breath: .exhale, "Relax your head toward your legs."),
            move("Forward Fold to Upward Salute", forwardFold, upwardSalute, duration: 4, breath: .inhale, "Press through your feet and rise with a long spine."),
            hold(upwardSalute, duration: 3, breath: .inhale, "Reach your arms overhead."),
            move("Upward Salute to Mountain Pose", upwardSalute, mountain, duration: 3, breath: .exhale, "Bring your hands down by your sides."),
            hold(mountain, duration: 5, breath: .natural, "Stand tall and complete the round.")
        ],
        safetyNotes: [
            "Bend your knees in folds if your hamstrings or low back feel tight.",
            "Lower through Chaturanga with control, or skip it and move gently to the floor.",
            "Keep shoulders broad in Plank and Downward-Facing Dog."
        ],
        onboardingNote: "This sequence repeats automatically for four rounds. Follow the breath cue, pause when needed, and use skip controls if a transition needs adjusting."
    )

    static let christmasStressRelief = YogaSequence(
        id: "christmas-stress-relief",
        title: "Christmas Stress Relief",
        subtitle: "A grounding mobility flow for easing tension through the back, hips, and shoulders.",
        difficulty: "Gentle",
        rounds: 2,
        steps: [
            hold(tabletop, duration: 8, breath: .natural, "Set your hands and knees down and soften your shoulders."),
            move("Tabletop to Cow Pose", tabletop, cow, duration: 3, breath: .inhale, "Lift your chest and lengthen the front body."),
            hold(cow, duration: 5, breath: .inhale, "Open across your collarbones without forcing the neck."),
            move("Cow Pose to Bird Dog", cow, birdDog, duration: 4, breath: .exhale, "Reach your right arm and left leg long.", endSide: .right),
            hold(birdDog, duration: 8, breath: .natural, "Steady your center and keep your hips level.", side: .right),
            move("Bird Dog to Thread the Needle", birdDog, threadNeedle, duration: 4, breath: .exhale, "Thread your right arm under your chest and lower gently.", side: .right, endSide: .right),
            hold(threadNeedle, duration: 10, breath: .natural, "Let the upper back unwind with easy breaths.", side: .right),
            move("Thread the Needle to Low Lunge", threadNeedle, lowLunge, duration: 5, breath: .inhale, "Step your right foot forward and lift through your chest.", side: .right, endSide: .right),
            hold(lowLunge, duration: 10, breath: .natural, "Release the front of the back hip.", side: .right),
            move("Low Lunge to Warrior II", lowLunge, warriorTwo, duration: 4, breath: .inhale, "Open your hips and reach through both arms.", side: .right, endSide: .right),
            hold(warriorTwo, duration: 10, breath: .natural, "Ground through your feet and soften your jaw.", side: .right),
            move("Warrior II to Side Angle", warriorTwo, sideAngle, duration: 3, breath: .exhale, "Lean over the front thigh and lengthen your side body.", side: .right, endSide: .right),
            hold(sideAngle, duration: 8, breath: .natural, "Create space from your back foot to your top hand.", side: .right),
            move("Side Angle to Triangle Pose", sideAngle, triangle, duration: 4, breath: .inhale, "Straighten the front leg and rotate your chest open.", side: .right, endSide: .right),
            hold(triangle, duration: 8, breath: .natural, "Keep both sides of your waist long.", side: .right),
            move("Triangle Pose to Pyramid Pose", triangle, pyramid, duration: 4, breath: .exhale, "Square your hips and fold over the front leg.", side: .right, endSide: .right),
            hold(pyramid, duration: 10, breath: .natural, "Relax your neck and breathe into the back body.", side: .right),
            move("Pyramid Pose to Bird Dog", pyramid, birdDog, duration: 5, breath: .inhale, "Return to hands and knees and extend the second side.", side: .right, endSide: .left),
            hold(birdDog, duration: 8, breath: .natural, "Reach your left arm and right leg long.", side: .left),
            move("Bird Dog to Thread the Needle", birdDog, threadNeedle, duration: 4, breath: .exhale, "Thread your left arm under your chest.", side: .left, endSide: .left),
            hold(threadNeedle, duration: 10, breath: .natural, "Soften the shoulders and breathe into the twist.", side: .left),
            move("Thread the Needle to Low Lunge", threadNeedle, lowLunge, duration: 5, breath: .inhale, "Step your left foot forward and lift your chest.", side: .left, endSide: .left),
            hold(lowLunge, duration: 10, breath: .natural, "Let the second side settle.", side: .left),
            move("Low Lunge to Seated Fold", lowLunge, seatedFold, duration: 6, breath: .exhale, "Come down to sit and extend your legs.", side: .left),
            hold(seatedFold, duration: 12, breath: .natural, "Fold forward with a soft spine and steady breath."),
            move("Seated Fold to Bridge Pose", seatedFold, bridge, duration: 5, breath: .inhale, "Lie back, plant your feet, and lift your hips."),
            hold(bridge, duration: 10, breath: .natural, "Press evenly through your feet and broaden your chest."),
            move("Bridge Pose to Supported Shoulder Stand", bridge, shoulderStand, duration: 5, breath: .exhale, "Support your back and lift your legs with care."),
            hold(shoulderStand, duration: 10, breath: .natural, "Keep the breath calm and the neck quiet."),
            move("Supported Shoulder Stand to Child's Pose", shoulderStand, childPose, duration: 6, breath: .exhale, "Lower down slowly and fold back to rest."),
            hold(childPose, duration: 15, breath: .natural, "Rest your forehead down and let your body settle.")
        ],
        safetyNotes: [
            "Keep the neck neutral in Supported Shoulder Stand and skip it if it feels uncomfortable.",
            "Use padding under knees for kneeling shapes.",
            "Move slowly through twists and avoid forcing range."
        ],
        onboardingNote: "This is a gentle two-round flow with right and left side cues. Let the timer guide you, but pause anytime you want a longer release."
    )

    static let consciousTransitions = YogaSequence(
        id: "conscious-transitions",
        title: "Conscious Transitions",
        subtitle: "A mindful flow that practices smooth changes between strength, balance, and release.",
        difficulty: "Intermediate",
        rounds: 3,
        steps: [
            hold(tabletop, duration: 6, breath: .natural, "Arrive on hands and knees with a steady base."),
            move("Tabletop to Downward-Facing Dog", tabletop, downwardDog, duration: 4, breath: .exhale, "Lift your hips and press the floor away."),
            hold(downwardDog, duration: 8, breath: .natural, "Lengthen through your spine before moving on."),
            move("Downward-Facing Dog to Three-Legged Dog", downwardDog, threeLeggedDog, duration: 3, breath: .inhale, "Float your right leg back and up.", endSide: .right),
            hold(threeLeggedDog, duration: 6, breath: .inhale, "Keep your hands grounded and hips steady.", side: .right),
            move("Three-Legged Dog to Knee to Nose", threeLeggedDog, kneeToNose, duration: 3, breath: .exhale, "Draw your right knee forward with control.", side: .right, endSide: .right),
            hold(kneeToNose, duration: 4, breath: .exhale, "Round through your upper back and stay light.", side: .right),
            move("Knee to Nose to Low Lunge", kneeToNose, lowLunge, duration: 3, breath: .inhale, "Step your right foot through and rise into the front hip.", side: .right, endSide: .right),
            hold(lowLunge, duration: 8, breath: .natural, "Root through your legs and lift your chest.", side: .right),
            move("Low Lunge to Warrior II", lowLunge, warriorTwo, duration: 4, breath: .inhale, "Open to the side with a smooth turn.", side: .right, endSide: .right),
            hold(warriorTwo, duration: 8, breath: .natural, "Stay broad through the shoulders.", side: .right),
            move("Warrior II to Triangle Pose", warriorTwo, triangle, duration: 4, breath: .exhale, "Reach forward and tip into a long side bend.", side: .right, endSide: .right),
            hold(triangle, duration: 8, breath: .natural, "Stack your torso gently and breathe evenly.", side: .right),
            move("Triangle Pose to Half Split", triangle, halfSplit, duration: 5, breath: .exhale, "Lower down and lengthen the front leg.", side: .right, endSide: .right),
            hold(halfSplit, duration: 8, breath: .natural, "Fold only as far as your hamstrings allow.", side: .right),
            move("Half Split to Chair Pose", halfSplit, chair, duration: 5, breath: .inhale, "Step in and bend your knees into a steady seat."),
            hold(chair, duration: 6, breath: .natural, "Draw your ribs in and keep your breath easy."),
            move("Chair Pose to Boat Pose", chair, boat, duration: 5, breath: .exhale, "Come down to sit and lift through your chest."),
            hold(boat, duration: 8, breath: .natural, "Balance tall and keep your belly engaged."),
            move("Boat Pose to Sphinx Pose", boat, sphinx, duration: 5, breath: .inhale, "Roll to your belly and prop onto your forearms."),
            hold(sphinx, duration: 10, breath: .natural, "Draw your chest forward and relax your legs."),
            move("Sphinx Pose to Child's Pose", sphinx, childPose, duration: 4, breath: .exhale, "Press back and fold into rest."),
            hold(childPose, duration: 12, breath: .natural, "Let your breath slow before the next round.")
        ],
        safetyNotes: [
            "Step instead of hopping whenever balance or wrists need a calmer option.",
            "Keep the front knee tracking over the toes in lunges and standing poses.",
            "Pause before transitions that feel rushed."
        ],
        onboardingNote: "This flow emphasizes controlled transitions. Watch for right-side cues, then repeat mindfully across rounds."
    )

    private static func hold(_ pose: Pose, duration: TimeInterval, breath: BreathCue, _ instruction: String, side: PracticeSide = .none) -> PracticeStep {
        PracticeStep(kind: .hold, title: pose.name, startPose: pose, duration: duration, breathCue: breath, instruction: instruction, side: side)
    }

    private static func move(
        _ title: String,
        _ start: Pose,
        _ end: Pose,
        duration: TimeInterval,
        breath: BreathCue,
        _ instruction: String,
        side: PracticeSide = .none,
        endSide: PracticeSide = .none
    ) -> PracticeStep {
        PracticeStep(kind: .transition, title: title, startPose: start, endPose: end, duration: duration, breathCue: breath, instruction: instruction, side: side, endSide: endSide)
    }
}
