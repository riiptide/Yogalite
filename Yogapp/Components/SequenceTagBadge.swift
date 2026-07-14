import SwiftUI

struct SequenceTagBadge: View {
    let tag: String

    var body: some View {
        Text(tag)
            .font(.caption.weight(.bold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(style.background)
            .foregroundStyle(style.foreground)
            .clipShape(Capsule())
            .accessibilityLabel("Tag: \(tag)")
    }

    private var style: SequenceTagStyle {
        SequenceTagStyle.style(for: tag)
    }
}

private struct SequenceTagStyle {
    let foreground: Color
    let background: Color

    static func style(for tag: String) -> SequenceTagStyle {
        let normalizedTag = tag.normalizedSequenceTag

        switch normalizedTag {
        case "quick", "under 10 minutes", "10-15 minutes", "15-20 minutes", "20 minutes", "20-30 minutes", "30 minutes":
            return .time
        case "morning", "midday", "evening", "bedtime", "anytime":
            return .schedule
        case "energizing", "calming", "focus", "mindfulness", "stress relief", "recovery", "gentle", "restorative":
            return .mood
        case "beginner", "beginner-intermediate", "intermediate", "beginner-friendly", "challenging":
            return .level
        case "sun salutation", "slow flow", "vinyasa", "power yoga", "standing flow", "floor practice", "full practice", "no mat":
            return .format
        case "hips", "hamstrings", "core", "shoulders", "chest", "upper back", "legs", "glutes", "wrists", "spine", "side body", "hip flexors", "calves", "full body", "backbends", "twists", "arm balances", "inversions":
            return .bodyArea
        case "mobility", "strength", "flexibility", "balance", "stability", "posture", "stretching", "low impact", "wrist-free", "knee-friendly", "peak pose":
            return .focusArea
        default:
            return .general
        }
    }

    private static let level = SequenceTagStyle(
        foreground: FlowDesign.teal,
        background: FlowDesign.paleAqua
    )
    private static let time = SequenceTagStyle(
        foreground: Color(red: 0.18, green: 0.36, blue: 0.66),
        background: Color(red: 0.84, green: 0.90, blue: 0.99)
    )
    private static let schedule = SequenceTagStyle(
        foreground: Color(red: 0.66, green: 0.38, blue: 0.02),
        background: Color(red: 1.00, green: 0.91, blue: 0.72)
    )
    private static let mood = SequenceTagStyle(
        foreground: Color(red: 0.39, green: 0.29, blue: 0.64),
        background: Color(red: 0.91, green: 0.87, blue: 0.98)
    )
    private static let format = SequenceTagStyle(
        foreground: Color(red: 0.14, green: 0.43, blue: 0.36),
        background: Color(red: 0.84, green: 0.94, blue: 0.89)
    )
    private static let bodyArea = SequenceTagStyle(
        foreground: Color(red: 0.60, green: 0.18, blue: 0.23),
        background: Color(red: 0.98, green: 0.86, blue: 0.86)
    )
    private static let focusArea = SequenceTagStyle(
        foreground: Color(red: 0.24, green: 0.42, blue: 0.45),
        background: Color(red: 0.84, green: 0.94, blue: 0.95)
    )
    private static let general = SequenceTagStyle(
        foreground: FlowDesign.secondaryText,
        background: Color(.secondarySystemBackground)
    )
}

private extension String {
    var normalizedSequenceTag: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .lowercased()
    }
}

#Preview {
    HStack(spacing: 8) {
        SequenceTagBadge(tag: "Morning")
        SequenceTagBadge(tag: "Energizing")
        SequenceTagBadge(tag: "Hips")
        SequenceTagBadge(tag: "10-15 Minutes")
    }
    .padding()
}
