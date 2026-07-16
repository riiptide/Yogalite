import SwiftUI

struct TagFlowsView: View {
    let tag: String
    var endWorkoutAction: () -> Void = {}
    private let sequences = SunSalutationData.allSequences
    @Environment(\.dismiss) private var dismiss

    private var matchingSequences: [YogaSequence] {
        sequences.filter { sequence in
            normalized(sequence.difficulty) == normalized(tag)
                || sequence.tags.contains { normalized($0) == normalized(tag) }
        }
    }

    private var subtitle: String {
        let noun = matchingSequences.count == 1 ? "flow" : "flows"
        return "\(matchingSequences.count) \(noun) matching this tag"
    }

    var body: some View {
        ZStack {
            FlowDesign.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    results
                }
                .padding(FlowDesign.spacing)
                .padding(.bottom, 22)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(FlowDesign.teal)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground).opacity(0.85))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Back")

            VStack(alignment: .leading, spacing: 12) {
                SequenceTagBadge(tag: tag)

                Text("\(tag) flows")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(FlowDesign.text)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var results: some View {
        if matchingSequences.isEmpty {
            ContentUnavailableView(
                "No matching flows",
                systemImage: "tag",
                description: Text("Try another tag from a sequence detail page.")
            )
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
        } else {
            VStack(spacing: 16) {
                ForEach(matchingSequences) { sequence in
                    TagFlowCard(sequence: sequence, endWorkoutAction: endWorkoutAction)
                }
            }
        }
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .lowercased()
    }
}

private struct TagFlowCard: View {
    let sequence: YogaSequence
    let endWorkoutAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            NavigationLink {
                SequenceDetailView(sequence: sequence, endWorkoutAction: endWorkoutAction)
            } label: {
                SequenceCard(sequence: sequence)
            }
            .buttonStyle(.plain)

            NavigationLink {
                PracticePlayerView(
                    viewModel: PracticePlayerViewModel(sequence: sequence),
                    endWorkoutAction: endWorkoutAction
                )
            } label: {
                Label("Start Practice", systemImage: "play.fill")
                    .font(.subheadline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(FlowDesign.teal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: FlowDesign.cornerMedium, style: .continuous))
            }
        }
    }
}

#Preview("Tag Flows") {
    NavigationStack {
        TagFlowsView(tag: "Core")
    }
}
