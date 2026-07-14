import Foundation

enum PracticeStepKind: String, Codable, CaseIterable {
    case hold
    case transition
}

enum BreathCue: String, Codable, CaseIterable {
    case inhale
    case exhale
    case natural

    var displayName: String {
        switch self {
        case .inhale: "Inhale"
        case .exhale: "Exhale"
        case .natural: "Natural"
        }
    }
}

enum PracticeSide: String, Codable, CaseIterable {
    case none
    case left
    case right

    var displayName: String? {
        switch self {
        case .none: nil
        case .left: "Left"
        case .right: "Right"
        }
    }
}

struct Pose: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let assetName: String
}

struct PracticeStep: Identifiable, Codable {
    let id: UUID
    let kind: PracticeStepKind
    let title: String
    let startPose: Pose
    let endPose: Pose?
    let duration: TimeInterval
    let breathCue: BreathCue
    let instruction: String
    let side: PracticeSide
    let endSide: PracticeSide

    init(
        id: UUID = UUID(),
        kind: PracticeStepKind,
        title: String,
        startPose: Pose,
        endPose: Pose? = nil,
        duration: TimeInterval,
        breathCue: BreathCue,
        instruction: String,
        side: PracticeSide = .none,
        endSide: PracticeSide = .none
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.startPose = startPose
        self.endPose = endPose
        self.duration = duration
        self.breathCue = breathCue
        self.instruction = instruction
        self.side = side
        self.endSide = endSide
    }
}

struct YogaSequence: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let difficulty: String
    let rounds: Int
    let steps: [PracticeStep]
    let safetyNotes: [String]
    let onboardingNote: String
    let tags: [String]

    init(
        id: String,
        title: String,
        subtitle: String,
        difficulty: String,
        rounds: Int,
        steps: [PracticeStep],
        safetyNotes: [String] = [
            "Move within a pain-free range and pause if anything feels sharp or unstable.",
            "Keep your breath steady and choose the gentler option whenever needed."
        ],
        onboardingNote: String = "Move at a steady pace, follow the timer, and pause whenever you need more time.",
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.difficulty = difficulty
        self.rounds = rounds
        self.steps = steps
        self.safetyNotes = safetyNotes
        self.onboardingNote = onboardingNote
        self.tags = tags
    }

    var estimatedDuration: TimeInterval {
        steps.reduce(0) { $0 + $1.duration } * Double(rounds)
    }

    var estimatedMinutes: Int {
        max(1, Int((estimatedDuration / 60).rounded()))
    }

    var thumbnailPose: Pose {
        let uniqueHoldPoses = steps.reduce(into: [Pose]()) { poses, step in
            guard step.kind == .hold, !poses.contains(where: { $0.id == step.startPose.id }) else { return }
            poses.append(step.startPose)
        }

        let fallbackPoses = steps.reduce(into: [Pose]()) { poses, step in
            guard !poses.contains(where: { $0.id == step.startPose.id }) else { return }
            poses.append(step.startPose)
            if let endPose = step.endPose, !poses.contains(where: { $0.id == endPose.id }) {
                poses.append(endPose)
            }
        }

        let poses = uniqueHoldPoses.isEmpty ? fallbackPoses : uniqueHoldPoses
        guard !poses.isEmpty else {
            return Pose(id: "mountain", name: "Mountain Pose", assetName: "mountain_pose")
        }

        let thumbnailCandidates = poses.count > 1 ? Array(poses.dropFirst()) : poses
        let seed = "\(id)-\(title)".unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return thumbnailCandidates[seed % thumbnailCandidates.count]
    }
}
