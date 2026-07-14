import SwiftUI

struct SequenceCard: View {
    let sequence: YogaSequence

    var body: some View {
        HStack(spacing: 16) {
            PoseIllustrationView(pose: sequence.thumbnailPose)
                .frame(width: 88, height: 88)
                .background(FlowDesign.paleAqua.opacity(0.70))
                .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(sequence.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                    .lineLimit(2)
                Text(sequence.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                metadataGrid
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(FlowDesign.teal)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 18, x: 0, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sequence.title), \(sequence.difficulty), about \(sequence.estimatedDuration.minutesText), \(sequence.rounds) rounds")
    }

    private var metadataGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 82), alignment: .leading),
                GridItem(.flexible(minimum: 82), alignment: .leading)
            ],
            alignment: .leading,
            spacing: 6
        ) {
            MetadataLabel(title: sequence.difficulty, systemImage: "chart.bar")
            MetadataLabel(title: sequence.estimatedDuration.minutesText, systemImage: "clock")
            MetadataLabel(title: "\(sequence.rounds) rounds", systemImage: "arrow.triangle.2.circlepath")
        }
        .font(.caption)
    }
}

#Preview {
    SequenceCard(sequence: SunSalutationData.sunSalutationA)
        .padding()
        .background(FlowDesign.background)
}
