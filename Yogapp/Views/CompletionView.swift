import SwiftUI

struct CompletionView: View {
    let sequence: YogaSequence
    let restartAction: () -> Void
    let exitAction: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(FlowDesign.paleAqua)
                    .frame(width: 170, height: 170)
                Image(systemName: "checkmark")
                    .font(.system(size: 58, weight: .bold))
                    .foregroundStyle(FlowDesign.teal)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Practice Complete")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(FlowDesign.text)
                Text("You completed \(sequence.rounds.roundsText) of \(sequence.title).")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                summaryTile(title: sequence.estimatedDuration.minutesText, subtitle: "practiced", systemImage: "clock")
                summaryTile(title: sequence.difficulty, subtitle: "difficulty", systemImage: "chart.bar")
            }

            VStack(spacing: 12) {
                PrimaryButton("Practice Again", systemImage: "arrow.counterclockwise", action: restartAction)
                Button(action: exitAction) {
                    Text("Back to Flow")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .foregroundStyle(FlowDesign.teal)
                        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
                }
                .accessibilityLabel("Back to Flow")
            }

            Spacer()
        }
        .padding(FlowDesign.spacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlowDesign.background)
    }

    private func summaryTile(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
            Text(title)
                .font(.headline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(subtitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color(.systemBackground).opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
    }
}

#Preview("Completion") {
    CompletionView(sequence: SunSalutationData.sunSalutationA, restartAction: {}, exitAction: {})
}
