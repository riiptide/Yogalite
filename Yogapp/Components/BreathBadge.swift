import SwiftUI

struct BreathBadge: View {
    let cue: BreathCue

    var body: some View {
        Text(cue.displayName)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(badgeColor.opacity(0.18))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
            .accessibilityLabel("Breath cue: \(cue.displayName)")
    }

    private var badgeColor: Color {
        switch cue {
        case .inhale: FlowDesign.teal
        case .exhale: Color(red: 0.33, green: 0.42, blue: 0.46)
        case .natural: Color.secondary
        }
    }
}

#Preview {
    HStack {
        BreathBadge(cue: .inhale)
        BreathBadge(cue: .exhale)
        BreathBadge(cue: .natural)
    }
    .padding()
}
