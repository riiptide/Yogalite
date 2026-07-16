import SwiftUI

struct CompletionView: View {
    let sequence: YogaSequence
    let restartAction: () -> Void
    let exitAction: () -> Void
    @State private var selectedReflection: PracticeReflection?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(FlowDesign.paleAqua)
                        .frame(width: 150, height: 150)
                    Image(systemName: "checkmark")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(FlowDesign.teal)
                }
                .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text("Great job! 🎉\nPractice Complete")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(FlowDesign.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("You completed \(sequence.rounds.roundsText) of \(sequence.title).")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    summaryTile(title: sequence.estimatedDuration.minutesText, subtitle: "practiced", systemImage: "clock")
                    summaryTile(title: sequence.difficulty, subtitle: "difficulty", systemImage: "chart.bar")
                }

                reflectionSection

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
            }
            .padding(FlowDesign.spacing)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FlowDesign.background)
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How do you feel?")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.text)
                if let selectedReflection {
                    Text(selectedReflection.responseText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(PracticeReflection.allCases) { reflection in
                    Button {
                        withAnimation(.snappy) {
                            selectedReflection = reflection
                        }
                    } label: {
                        Label(reflection.title, systemImage: reflection.systemImage)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(selectedReflection == reflection ? FlowDesign.teal : FlowDesign.paleAqua.opacity(0.72))
                            .foregroundStyle(selectedReflection == reflection ? .white : FlowDesign.teal)
                            .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
                    }
                    .accessibilityAddTraits(selectedReflection == reflection ? .isSelected : [])
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerLarge, style: .continuous))
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

private enum PracticeReflection: String, CaseIterable, Identifiable {
    case calm
    case energized
    case sore
    case strong

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: "Calm"
        case .energized: "Energized"
        case .sore: "Sore"
        case .strong: "Strong"
        }
    }

    var systemImage: String {
        switch self {
        case .calm: "leaf"
        case .energized: "bolt"
        case .sore: "heart.text.square"
        case .strong: "flame"
        }
    }

    var responseText: String {
        switch self {
        case .calm: "Lovely. Let that steadiness stay with you."
        case .energized: "Nice. Your body is awake and ready."
        case .sore: "Good to know. Take it easy and recover well."
        case .strong: "Beautiful. Carry that strength forward."
        }
    }
}

#Preview("Completion") {
    CompletionView(sequence: SunSalutationData.sunSalutationA, restartAction: {}, exitAction: {})
}
